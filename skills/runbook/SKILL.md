---
name: runbook
description: Gera, consulta e executa runbooks operacionais — procedimentos passo-a-passo com comandos de verificação para operações de infraestrutura. Use para documentar procedimentos, criar playbooks de emergência, ou ser guiado por um procedimento. Exemplo - /runbook deploy Node.js em produção ou /runbook gerar rollback procedure
allowed-tools: Agent(*) Read(*) Glob(*) Grep(*) Write(*) Edit(*) Bash(*) WebSearch(*)
argument-hint: <operação a documentar ou consultar>
effort: high
---

# /runbook — Operational Runbook Engine

Runbooks são procedimentos operacionais executáveis. Cada passo tem: ação, comando, output esperado, verificação, e rollback.

## Operação
$ARGUMENTS

---

## FASE 0: Modo de operação

```
INTENT
   │
   ├─ "gerar" / "criar" / "documentar" ────► MODO GENERATE
   │   Analisar infra, produzir runbook novo
   │
   ├─ "executar" / "rodar" / "seguir" ─────► MODO EXECUTE
   │   Ler runbook existente, executar passo-a-passo com verificação
   │
   └─ "consultar" / nome de operação ──────► MODO CONSULT
       Buscar template adequado, adaptar ao contexto
```

---

## MODO GENERATE — Criar runbook novo

### Step 1 — Análise de contexto

Antes de escrever, ler:
- Estrutura do projeto (`package.json`, `docker-compose.yml`, `Dockerfile`, configs)
- Infraestrutura disponível (`docker ps`, `pm2 list`, `systemctl`, etc.)
- Processos existentes (`CLAUDE.md`, `README.md`, docs/)
- Runbooks existentes em `runbooks/` (evitar duplicação)

### Step 2 — Selecionar template base

| Operação | Template | Pre-requisitos típicos |
|----------|----------|----------------------|
| Deploy aplicação | `DEPLOY` | Container registry, servidor alvo, health check |
| Rollback | `ROLLBACK` | Versão anterior identificada, backup |
| Database migration | `DB_MIGRATE` | Backup, janela de manutenção, rollback SQL |
| Database backup/restore | `DB_BACKUP` | Storage destino, retenção definida |
| Certificado SSL | `CERT_RENEW` | Certbot/acme.sh, domínio, DNS |
| Scaling horizontal | `SCALE_H` | Load balancer, novo nó, health check |
| Scaling vertical | `SCALE_V` | Janela de manutenção, novo spec |
| Failover/DR | `DR_FAILOVER` | Réplica pronta, DNS TTL baixo |
| Key/secret rotation | `SECRET_ROTATE` | Novo secret gerado, todos os consumers |
| Monitoring setup | `MONITOR_SETUP` | Prometheus/Grafana, alertmanager |
| Incident containment | `CONTAIN` | Acesso firewall, identificação do vetor |
| User access management | `ACCESS_MGMT` | Lista de usuários, RBAC policy |
| Log rotation | `LOG_ROTATE` | Logrotate config, disco monitorado |
| Cleanup operacional | `CLEANUP` | Identificação de recursos orphan |

### Step 3 — Escrever runbook

Formato obrigatório:

```markdown
# Runbook — [Operação]

## Metadata
- **ID**: RB-[YYYY-MM-DD]-[slug]
- **Criticidade**: [routine / planned-maintenance / emergency]
- **Tempo estimado**: [duração]
- **Requer janela de manutenção**: [sim/não]
- **Rollback disponível**: [sim/não — se não, marcar PONTO SEM RETORNO]
- **Última revisão**: [data]
- **Autor**: [nome]

## Pre-requisitos
- [ ] [cada pre-requisito como checklist]
- [ ] Backup verificado: `[comando de verificação]`
- [ ] Comunicação enviada: [canal]
- [ ] Janela de manutenção confirmada: [horário]

## Procedimento

### Passo 1 — [Nome do passo]
**Ação**: [descrição clara do que fazer]
**Comando**:
```bash
[comando exato a executar]
```
**Output esperado**:
```
[o que deve aparecer se OK]
```
**Verificação**:
```bash
[comando que confirma sucesso]
```
**Se falhar**: [ação alternativa ou "ABORTAR — ir para Rollback"]

---

### Passo 2 — [Nome]
[mesma estrutura]

---

### ⚠️ PONTO SEM RETORNO
> A partir daqui, rollback parcial. Documentar estado antes de prosseguir.

### Passo N — [Nome]
[...]

---

## Verificação final
```bash
[série de comandos que confirmam sucesso total]
```
**Critério de sucesso**: [o que define "operação completa"]

## Rollback
### Se falhou no Passo 1-N:
```bash
[comandos de rollback por passo]
```

### Se falhou após PONTO SEM RETORNO:
```bash
[procedimento de recovery]
```

## Comunicação pós-operação
- [ ] Notificar equipe: [canal]
- [ ] Atualizar docs: [onde]
- [ ] Fechar a issue no tracker: [id]

## Lições e notas
[espaço para anotar problemas encontrados durante execução]
```

### Step 4 — Salvar

Salvar em `runbooks/RB-[date]-[slug].md` na raiz do projeto.
Se `runbooks/` não existe, criar.

---

## MODO EXECUTE — Executar runbook existente

### Workflow

1. **Ler** o runbook especificado
2. **Verificar pre-requisitos** (executar cada check, reportar status)
3. **Executar passo-a-passo**:
   - Apresentar o passo ao usuário
   - Executar o comando (com confirmação para comandos destrutivos)
   - Verificar output contra esperado
   - Se divergir: PARAR, avaliar, decidir (continuar / adaptar / abortar)
4. **Verificação final**: executar todos os checks de sucesso
5. **Atualizar runbook**: anotar qualquer desvio encontrado

### Regras de execução

- **NUNCA executar automaticamente** comandos destrutivos (DROP, DELETE, rm -rf, restart de prod). Sempre pedir confirmação.
- **Verificar CADA passo** antes de ir ao próximo.
- **Documentar desvios** — se algo diferiu do esperado, anotar no runbook.
- **Abortar sem vergonha** — se algo está errado, parar é melhor que forçar.

---

## MODO CONSULT — Buscar e adaptar

### Workflow

1. **Identificar** a operação desejada
2. **Buscar** runbooks existentes em `runbooks/` que correspondam
3. **Se encontrou**: apresentar resumo + perguntar se quer executar
4. **Se não encontrou**: oferecer gerar novo com MODO GENERATE
5. **Se operação é genérica**: buscar best practices via WebSearch e adaptar ao contexto

---

## Template Library — Snippets Reutilizáveis

### Deploy com Docker

```markdown
### Passo — Pull nova imagem
**Comando**:
```bash
docker pull [REGISTRY]/[IMAGE]:[TAG]
```
**Verificação**:
```bash
docker images [REGISTRY]/[IMAGE] --format '{{.Tag}} {{.CreatedSince}}'
```

### Passo — Parar container atual
**Comando**:
```bash
docker stop [CONTAINER] && docker rename [CONTAINER] [CONTAINER]-old
```
**Verificação**:
```bash
docker ps -a --filter name=[CONTAINER] --format '{{.Names}} {{.Status}}'
```

### Passo — Iniciar novo container
**Comando**:
```bash
docker run -d --name [CONTAINER] --restart unless-stopped \
  -p [HOST_PORT]:[CONTAINER_PORT] \
  -v [VOLUME_MAP] \
  --env-file [ENV_FILE] \
  [REGISTRY]/[IMAGE]:[TAG]
```
**Verificação**:
```bash
docker logs --tail 20 [CONTAINER]
curl -sf http://localhost:[PORT]/health && echo "OK" || echo "FAIL"
```

### Rollback
```bash
docker stop [CONTAINER] && docker rm [CONTAINER]
docker rename [CONTAINER]-old [CONTAINER]
docker start [CONTAINER]
```
```

### Database Backup (PostgreSQL)

```markdown
### Passo — Backup completo
**Comando**:
```bash
pg_dump -h [HOST] -U [USER] -d [DB] -F c -f /backup/[DB]-$(date +%Y%m%d-%H%M).dump
```
**Verificação**:
```bash
pg_restore --list /backup/[DB]-*.dump | head -5
ls -lh /backup/[DB]-*.dump
```
```

### Certificate Renewal (Certbot)

```markdown
### Passo — Renovar certificado
**Comando**:
```bash
certbot renew --cert-name [DOMAIN] --dry-run  # teste primeiro
certbot renew --cert-name [DOMAIN]             # renovação real
```
**Verificação**:
```bash
openssl x509 -in /etc/letsencrypt/live/[DOMAIN]/cert.pem -noout -dates
nginx -t && systemctl reload nginx
```
```

---

## Regras do runbook engine

- **Executável > legível**. Cada passo tem comando copy-paste. Nunca "ajustar conforme necessário" sem dizer O QUE ajustar.
- **Verificação é obrigatória**. Passo sem verificação = passo que pode falhar silenciosamente.
- **Rollback é obrigatório**. Runbook sem rollback = aposta, não procedimento.
- **PONTO SEM RETORNO explícito**. Se existe um ponto onde rollback muda de natureza, MARCAR.
- **Tempo estimado realista**. Incluir tempo de verificação, não só execução.
- **Contexto-aware**. Ler a infra real antes de gerar. Não gerar runbook genérico quando pode ser específico.

---

## Integração com outros skills

| Situação | Skill |
|----------|-------|
| Runbook de incident containment | Chamado por `/incident` Fase 2 |
| Remediação pós-audit | Chamado por `/infra-audit` Fase 5 |
| Procedimento precisa security review | `/squad` com @security-auditor |
| Procedimento complexo multi-sistema | `/squad` com agentes relevantes |
