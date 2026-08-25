---
name: incident
description: Workflow completo de incident response — do alerta ao postmortem. Use quando há incidente ativo, outage, degradação de serviço, alerta crítico, investigação de problema em produção, ou para criar/revisar processos de incident management. Exemplo - /incident P1 API principal retornando 503 desde 14:30
allowed-tools: Agent(*) Read(*) Glob(*) Grep(*) Write(*) Edit(*) Bash(*) WebFetch(*) WebSearch(*)
argument-hint: <severidade P1-P4 e descrição do incidente>
effort: xhigh
---

# /incident — Incident Response Engine

Você é o **Incident Commander (IC)** automatizado. Sua missão: conduzir o incidente do alerta à resolução com velocidade, rigor e comunicação clara.

Baseado em: Google SRE Book, PagerDuty Incident Response, Atlassian Incident Management.

## Incidente
$ARGUMENTS

---

## FASE 0: Classificação & Declaração

### Tabela de severidade

| Nível | Critério | SLA resposta | SLA resolução | Escalonamento |
|-------|----------|-------------|---------------|---------------|
| **P1 — Crítico** | Serviço principal down, data loss, breach de segurança, impacto em todos os usuários | Imediato | 1h | CTO + equipe inteira |
| **P2 — Alto** | Funcionalidade major degradada, impacto parcial, workaround difícil | 15min | 4h | Tech Lead + SRE |
| **P3 — Médio** | Funcionalidade minor afetada, workaround disponível, impacto limitado | 30min | 24h | SRE + dev responsável |
| **P4 — Baixo** | Bug cosmético, alerta informativo, sem impacto direto em usuários | 2h | 72h | Dev responsável |

### Ações imediatas

1. **Classificar** o incidente baseado na descrição (P1-P4)
2. **Registrar timestamp** de início: `INCIDENT_START=$(date -u +%Y-%m-%dT%H:%M:%SZ)`
3. **Criar timeline** em memória:
   ```
   ## Timeline — INC-[YYYY-MM-DD]-[slug]
   | Timestamp (UTC) | Evento | Autor |
   |-----------------|--------|-------|
   | [start] | Incidente declarado: [descrição] | IC |
   ```
4. **Se P1/P2**: comunicação IMEDIATA antes de investigar

### Template de comunicação inicial

```markdown
## 🔴 INCIDENTE DECLARADO — [P-level]

**Status**: Investigando
**Início**: [timestamp UTC]
**Impacto**: [descrição do impacto observado]
**Serviços afetados**: [lista]
**IC**: <seu nome>
**Próxima atualização**: em [15min P1 / 30min P2]

---
Atualizações seguem neste thread.
```

---

## FASE 1: Triage Automatizado

Execute TODOS os checks aplicáveis em PARALELO usando Agent tool ou Bash:

### Check 1 — Saúde dos serviços
```bash
# Docker containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null
docker ps -a --filter "status=exited" --filter "status=dead" --format "{{.Names}}: {{.Status}}" 2>/dev/null

# PM2 processes (se disponível)
pm2 list 2>/dev/null || true

# Systemd services críticos
systemctl --type=service --state=failed 2>/dev/null || true
```

### Check 2 — Recursos do sistema
```bash
# CPU, memória, disco
echo "=== CPU ===" && top -bn1 | head -5
echo "=== MEMÓRIA ===" && free -h
echo "=== DISCO ===" && df -h | grep -E '^/dev|Filesystem'
echo "=== LOAD ===" && uptime
echo "=== PROCESSOS TOP ===" && ps aux --sort=-%mem | head -10
```

### Check 3 — Rede & conectividade
```bash
# Portas abertas
ss -tlnp 2>/dev/null | head -20

# DNS resolution
dig +short google.com 2>/dev/null || nslookup google.com 2>/dev/null

# Conectividade externa
curl -sf -o /dev/null -w "%{http_code} %{time_total}s" https://google.com 2>/dev/null && echo " OK" || echo " FAIL"
```

### Check 4 — Logs recentes
```bash
# Últimas linhas de logs de erro (adaptar ao serviço afetado)
journalctl --since "30 min ago" --priority=err --no-pager 2>/dev/null | tail -30
docker logs --since 30m [CONTAINER] 2>/dev/null | tail -50
```

### Check 5 — Mudanças recentes
```bash
# Git: últimos commits no repo relevante
git log --oneline -10 --since="24 hours ago" 2>/dev/null

# Docker: imagens recentes
docker images --format "{{.Repository}}:{{.Tag}} {{.CreatedSince}}" 2>/dev/null | head -10

# Deploys recentes (adaptar ao sistema de deploy)
```

### Check 6 — Tracker: issues relacionadas
Declare aqui o seu tracker e o caminho de acesso (`gh issue list --paginate`, CLI
próprio, API). Buscar:
- Issues BLOCKED nos projetos afetados
- Issues modificadas nas últimas 2h
- Incidentes anteriores similares

Se o tracker estiver fora do ar — plausível, já que ele mesmo pode ser o
incidente — pule este check e registre a lacuna no triage. Nunca bloqueie o
triage esperando o tracker.

### Síntese do triage

Após todos os checks, produzir:
```markdown
## Triage Summary
**Timestamp**: [now]
**Hipótese principal**: [baseada nos dados coletados]
**Hipóteses alternativas**: [2-3 outras possibilidades]
**Evidências**: [lista de dados que suportam a hipótese]
**Contradições**: [dados que NÃO se encaixam]
**Próximo passo recomendado**: [ação específica]
```

Adicionar à timeline.

---

## FASE 2: Mitigação

### Árvore de decisão por tipo de falha

```
TIPO DE FALHA
   │
   ├─ Container/serviço down ──────────► Restart Strategy
   │   ├─ docker restart [container]
   │   ├─ pm2 restart [app]
   │   └─ systemctl restart [service]
   │
   ├─ Disco cheio ─────────────────────► Space Recovery
   │   ├─ docker system prune -f
   │   ├─ Limpar logs: truncate -s 0 [logfile]
   │   ├─ Remover temp: find /tmp -mtime +7 -delete
   │   └─ Identificar: du -sh /* | sort -rh | head -10
   │
   ├─ OOM / memória ───────────────────► Memory Recovery
   │   ├─ Identificar processo: ps aux --sort=-%mem | head -5
   │   ├─ Kill + restart se necessário
   │   └─ Ajustar limits se container
   │
   ├─ Rede / DNS / TLS ────────────────► Network Recovery
   │   ├─ Verificar resolução DNS
   │   ├─ Verificar certificado: openssl s_client -connect host:443
   │   ├─ Verificar firewall: iptables -L -n / ufw status
   │   └─ Verificar NGINX/proxy: nginx -t && nginx -s reload
   │
   ├─ Database ────────────────────────► DB Recovery
   │   ├─ Conexões: verificar pool exhaustion
   │   ├─ Locks: verificar deadlocks
   │   ├─ Replication lag: verificar slave status
   │   └─ Último backup: verificar integridade
   │
   ├─ Segurança / breach ──────────────► Security Containment
   │   ├─ ISOLAR o sistema afetado (firewall block)
   │   ├─ Revogar credenciais comprometidas
   │   ├─ Preservar evidências (NÃO deletar logs)
   │   ├─ /sec-scan no sistema afetado
   │   └─ Notificar stakeholders (compliance)
   │
   └─ Desconhecido ────────────────────► Deep Investigation
       ├─ Expandir janela de logs (últimas 24h)
       ├─ Comparar metrics antes/depois
       ├─ Bisect: qual mudança recente?
       └─ Spawnar @infra-sre + @security-auditor via /squad
```

### Regras de mitigação

1. **Rollback > fix forward** em P1/P2. Restaurar serviço primeiro, investigar depois.
2. **Documentar TUDO** na timeline. Cada ação, cada resultado.
3. **Comunicar antes de agir** em mudanças destrutivas (restart DB, rollback deploy).
4. **Preservar evidências** — nunca deletar logs de um incidente de segurança.
5. **Verificar após cada ação** — confirmar que a mitigação funcionou antes de declarar resolvido.

---

## FASE 3: Resolução & Verificação

1. **Verificar resolução**:
   - Re-executar os checks da Fase 1 que falharam
   - Confirmar que o serviço está respondendo normalmente
   - Verificar métricas estabilizaram

2. **Comunicar resolução**:
   ```markdown
   ## ✅ INCIDENTE RESOLVIDO — [P-level]

   **Status**: Resolvido
   **Início**: [timestamp]
   **Resolução**: [timestamp]
   **Duração total**: [HH:MM]
   **Causa raiz**: [descrição concisa]
   **Mitigação aplicada**: [o que foi feito]
   **Impacto real**: [número de usuários/serviços/duração]
   **Ações pendentes**: [lista ou "nenhuma"]

   Postmortem será publicado em [prazo: 24h P1, 48h P2, 1 semana P3].
   ```

3. **Atualizar timeline** com resolução

---

## FASE 4: Postmortem (Blameless)

### Gerar em até 24h (P1) / 48h (P2) / 1 semana (P3)

Escrever postmortem em `[PROJECT_ROOT]/postmortems/INC-[date]-[slug].md` ou no wiki se disponível.

### Template de postmortem

```markdown
# Postmortem — INC-[YYYY-MM-DD]-[slug]

## Metadata
- **Severidade**: P[n]
- **Data**: [YYYY-MM-DD]
- **Duração**: [HH:MM] ([start] → [end] UTC)
- **IC**: [quem coordena]
- **Autores**: [quem participou]

## Resumo executivo
[2-3 frases: o que aconteceu, qual foi o impacto, como foi resolvido]

## Impacto
- **Usuários afetados**: [número ou percentual]
- **Serviços afetados**: [lista]
- **Duração do impacto**: [tempo que usuários sentiram]
- **Dados perdidos**: [sim/não, detalhes]
- **SLA violado**: [sim/não]

## Timeline
| Timestamp (UTC) | Evento |
|-----------------|--------|
[copiar da timeline mantida durante o incidente]

## Causa raiz
[Descrição técnica detalhada. NÃO culpar pessoas. Focar em sistemas, processos e condições.]

## Análise — 5 Whys
1. **Por que** [o sintoma aconteceu]? Porque [causa direta].
2. **Por que** [causa direta]? Porque [causa mais profunda].
3. **Por que** [causa mais profunda]? Porque [causa sistêmica].
4. **Por que** [causa sistêmica]? Porque [gap no processo/design].
5. **Por que** [gap]? Porque [causa raiz fundamental].

## O que funcionou
- [lista de coisas que ajudaram na resposta]

## O que NÃO funcionou
- [lista de coisas que atrapalharam ou falharam]

## O que tivemos sorte
- [lista de coisas que poderiam ter sido piores]

## Action Items
| # | Ação | Tipo | Responsável | Prazo | Issue |
|---|------|------|-------------|-------|------|
| 1 | [ação concreta] | prevent/detect/mitigate | [pessoa] | [data] | [ticket] |
| 2 | ... | | | | |

Tipos de ação:
- **prevent**: evitar que aconteça de novo
- **detect**: detectar mais rápido da próxima vez
- **mitigate**: reduzir impacto se acontecer de novo

## Lições aprendidas
[Insights que vão além deste incidente específico]
```

### Regras do postmortem

- **Blameless**: nunca "fulano fez X". Sempre "o sistema permitiu que X acontecesse".
- **Specific**: action items com dono, prazo e issue aberta no tracker
- **Honest**: documentar sorte e falhas, não só sucessos
- **Actionable**: cada finding vira prevent/detect/mitigate action

---

## Integração com outros skills

| Situação | Skill |
|----------|-------|
| Incidente precisa análise multi-domínio | `/squad` com @infra-sre + @security-auditor |
| Incidente de segurança precisa scan | `/sec-scan` no sistema afetado |
| Mitigação segue procedimento documentado | `/runbook` para o procedimento |
| Action item gera auditoria | `/infra-audit` no sistema |
| Dashboard de incidentes precisa UI | `/front` para visualização |

---

## Regras do IC

- **Velocidade > perfeição** em P1/P2. Mitigar primeiro, entender depois.
- **Comunicar proativamente**. Silêncio = pânico. Updates a cada 15min (P1) / 30min (P2).
- **Delegar investigação** via Agent tool. IC coordena, não investiga sozinho.
- **Documentar em tempo real**. Timeline é artefato #1 — sem ela, postmortem é ficção.
- **Escalar sem medo**. Melhor escalar e não precisar do que precisar e não ter escalado.
- **Nunca culpar**. Sistemas falham, pessoas respondem. Foco em tornar o sistema mais resiliente.
