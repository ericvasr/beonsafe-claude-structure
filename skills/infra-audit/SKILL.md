---
name: infra-audit
description: Auditoria completa de infraestrutura — segurança, hardening, compliance, performance. Use para auditar servidores, containers, repositórios, configurações de rede, certificados, ou gerar relatório de postura de segurança. Exemplo - /infra-audit servidor de produção ou /infra-audit Dockerfile do projeto
allowed-tools: Agent(*) Read(*) Glob(*) Grep(*) Write(*) Edit(*) Bash(*)
argument-hint: <alvo da auditoria - servidor, container, repo, config>
effort: xhigh
---

# /infra-audit — Infrastructure Security Audit

Auditoria sistemática baseada em CIS Benchmarks, NIST Cybersecurity Framework e best practices de hardening.

## Alvo
$ARGUMENTS

---

## FASE 0: Identificação do Alvo

Detectar automaticamente o que auditar:

```
ALVO
   │
   ├─ Servidor local (WSL/Linux) ──────► Audit Type: HOST
   ├─ Servidor remoto (SSH) ───────────► Audit Type: REMOTE
   ├─ Container Docker ────────────────► Audit Type: CONTAINER
   ├─ Dockerfile / docker-compose ─────► Audit Type: CONTAINER_CONFIG
   ├─ Repositório de código ───────────► Audit Type: REPO
   ├─ Arquivos de IaC (Terraform, K8s) ► Audit Type: IAC
   ├─ Configuração NGINX/Apache ───────► Audit Type: WEBSERVER
   └─ Misto / não especificado ────────► Perguntar ao user (uma vez)
```

Registrar: `AUDIT_TARGET`, `AUDIT_TYPE`, `AUDIT_TIMESTAMP`

---

## FASE 1: Scanning Automatizado

Executar em PARALELO todos os scans aplicáveis ao tipo de alvo:

### Scan A — Trivy (sempre, adaptar target)

```bash
# Container image
trivy image --severity HIGH,CRITICAL --format json [IMAGE] 2>/dev/null

# Filesystem / repo
trivy fs --severity HIGH,CRITICAL --scanners vuln,secret,misconfig --format json [PATH] 2>/dev/null

# IaC / config
trivy config --severity HIGH,CRITICAL --format json [PATH] 2>/dev/null

# Secrets scan
trivy fs --scanners secret --format json [PATH] 2>/dev/null
```

### Scan B — Network (HOST/REMOTE)

```bash
# Portas abertas (local)
ss -tlnp 2>/dev/null

# Nmap scan se alvo é remoto (requer autorização)
nmap -sV -sC --top-ports 1000 [TARGET] 2>/dev/null

# Firewall status
iptables -L -n 2>/dev/null || ufw status verbose 2>/dev/null
```

### Scan C — SSL/TLS (WEBSERVER/REMOTE)

```bash
# Certificado e cadeia
echo | openssl s_client -connect [HOST]:443 -servername [HOST] 2>/dev/null | openssl x509 -noout -dates -subject -issuer

# Protocolos e ciphers
nmap --script ssl-enum-ciphers -p 443 [HOST] 2>/dev/null
```

### Scan D — Docker (CONTAINER/CONTAINER_CONFIG)

```bash
# Containers rodando como root
docker ps --format '{{.Names}}' | while read c; do
  user=$(docker inspect --format='{{.Config.User}}' "$c" 2>/dev/null)
  echo "$c: user=${user:-ROOT}"
done

# Capabilities perigosas
docker ps --format '{{.Names}}' | while read c; do
  caps=$(docker inspect --format='{{.HostConfig.CapAdd}}' "$c" 2>/dev/null)
  privs=$(docker inspect --format='{{.HostConfig.Privileged}}' "$c" 2>/dev/null)
  echo "$c: caps=$caps privileged=$privs"
done

# Volumes sensíveis montados
docker ps --format '{{.Names}}' | while read c; do
  mounts=$(docker inspect --format='{{range .Mounts}}{{.Source}}→{{.Destination}} {{end}}' "$c" 2>/dev/null)
  echo "$c: $mounts"
done

# Imagens sem tag (dangling)
docker images --filter "dangling=true" --format '{{.Repository}}:{{.Tag}} {{.Size}}'
```

---

## FASE 2: Checklist Manual (por tipo de alvo)

### HOST — Linux Hardening (CIS L1)

| # | Check | Comando | Critério PASS |
|---|-------|---------|---------------|
| H01 | SSH: PermitRootLogin | `grep -i PermitRootLogin /etc/ssh/sshd_config` | `no` |
| H02 | SSH: PasswordAuthentication | `grep -i PasswordAuthentication /etc/ssh/sshd_config` | `no` (key-only) |
| H03 | SSH: porta não-padrão | `grep -i "^Port" /etc/ssh/sshd_config` | ≠ 22 (recomendado) |
| H04 | SSH: Protocol 2 only | `grep -i Protocol /etc/ssh/sshd_config` | `2` ou ausente (default=2) |
| H05 | SSH: MaxAuthTries | `grep -i MaxAuthTries /etc/ssh/sshd_config` | ≤ 4 |
| H06 | Firewall ativo | `ufw status \|\| iptables -L` | ACTIVE com regras |
| H07 | Atualizações de segurança | `apt list --upgradable 2>/dev/null \| grep -i security` | Nenhum pendente |
| H08 | Usuários sem senha | `awk -F: '($2==""){print $1}' /etc/shadow 2>/dev/null` | Nenhum |
| H09 | SUID binaries | `find / -perm -4000 -type f 2>/dev/null` | Lista conhecida |
| H10 | Cron jobs de root | `crontab -l 2>/dev/null && ls /etc/cron.d/` | Apenas esperados |
| H11 | Partição /tmp separada | `mount \| grep /tmp` | Montada com noexec,nosuid |
| H12 | Kernel parameters | `sysctl net.ipv4.ip_forward` | 0 (exceto roteadores) |
| H13 | Unattended upgrades | `dpkg -l unattended-upgrades` | Instalado e configurado |
| H14 | fail2ban / rate limiting | `systemctl is-active fail2ban` | Active |
| H15 | Audit logging | `systemctl is-active auditd` | Active |

### CONTAINER_CONFIG — Dockerfile Best Practices

| # | Check | O que verificar | Critério PASS |
|---|-------|-----------------|---------------|
| D01 | Base image pinned | `FROM image:tag` | Tag específica, não `:latest` |
| D02 | Non-root user | `USER` instruction | Presente, não root |
| D03 | Multi-stage build | Múltiplos `FROM` | Sim p/ images de produção |
| D04 | COPY vs ADD | Instruções `ADD` | Nenhum ADD (exceto tar extraction) |
| D05 | Healthcheck | `HEALTHCHECK` | Presente |
| D06 | .dockerignore | Arquivo presente | .git, node_modules, .env excluídos |
| D07 | Secrets no build | `ARG` ou `ENV` com secrets | Nenhum (usar build secrets) |
| D08 | Camadas otimizadas | RUN combinados | Sim (menos camadas) |
| D09 | Scan vulnerabilidades | Trivy result | Zero CRITICAL |

### WEBSERVER — NGINX/Apache

| # | Check | O que verificar | Critério PASS |
|---|-------|-----------------|---------------|
| W01 | TLS 1.2+ only | `ssl_protocols` | TLSv1.2 TLSv1.3 |
| W02 | HSTS header | `add_header Strict-Transport-Security` | max-age ≥ 31536000 |
| W03 | X-Frame-Options | Response headers | DENY ou SAMEORIGIN |
| W04 | X-Content-Type-Options | Response headers | nosniff |
| W05 | CSP header | `Content-Security-Policy` | Presente e restritivo |
| W06 | Server header oculto | `server_tokens off` | Sim |
| W07 | Redirect HTTP→HTTPS | Config | Sim |
| W08 | Rate limiting | `limit_req_zone` | Configurado |
| W09 | Access logs | `access_log` | Ativo com rotação |
| W10 | Error pages custom | `error_page` | Sem stack traces |

### REPO — Código fonte

| # | Check | O que verificar | Critério PASS |
|---|-------|-----------------|---------------|
| R01 | Secrets no código | Trivy secret scan | Zero findings |
| R02 | .env no .gitignore | `.gitignore` | .env, *.key, *.pem listados |
| R03 | Dependências | Trivy vuln scan | Zero CRITICAL |
| R04 | Lock file presente | package-lock.json / yarn.lock | Presente e atualizado |
| R05 | SAST basics | Trivy misconfig | Zero HIGH+ |

---

## FASE 3: Scoring & Classificação

### Sistema de scoring

Cada check recebe:
- **PASS** (0 pts) — conforme
- **LOW** (1 pt) — risco baixo, best practice
- **MEDIUM** (3 pts) — risco real, prioridade média
- **HIGH** (7 pts) — risco significativo, corrigir em dias
- **CRITICAL** (15 pts) — risco imediato, corrigir agora

### Score total → classificação

| Score | Rating | Significado |
|-------|--------|-------------|
| 0-5 | **A — Excelente** | Postura sólida, manter monitoramento |
| 6-15 | **B — Bom** | Pequenas melhorias, sem urgência |
| 16-35 | **C — Aceitável** | Riscos reais, planejar correções |
| 36-70 | **D — Preocupante** | Riscos significativos, corrigir em dias |
| 71+ | **F — Crítico** | Exposição ativa, corrigir AGORA |

---

## FASE 4: Relatório

Gerar relatório em `[PROJECT_ROOT]/audit-reports/audit-[date]-[target-slug].md`:

```markdown
# Infrastructure Audit Report

## Metadata
- **Alvo**: [target]
- **Tipo**: [HOST/CONTAINER/REPO/IAC/WEBSERVER]
- **Data**: [YYYY-MM-DD HH:MM UTC]
- **Auditor**: Claude (IC: <seu nome>)
- **Ferramentas**: Trivy [version], nmap, checks manuais

## Resumo Executivo
- **Rating**: [A-F] ([score] pontos)
- **Findings**: [N] CRITICAL, [N] HIGH, [N] MEDIUM, [N] LOW
- **Top 3 riscos**:
  1. [risco + impacto]
  2. [risco + impacto]
  3. [risco + impacto]

## Scan Automatizado — Resultados
### Trivy
[resumo: vulnerabilidades por severidade, secrets encontrados, misconfigs]

### Network
[resumo: portas abertas, serviços expostos]

### SSL/TLS
[resumo: certificado válido, protocolos, ciphers]

## Checklist Detalhado
| # | Check | Status | Severidade | Detalhe |
|---|-------|--------|-----------|---------|
| H01 | SSH PermitRootLogin | FAIL | HIGH | Valor: yes → recomendado: no |
| H02 | SSH PasswordAuth | PASS | — | Desabilitado ✓ |
[... todos os checks aplicáveis]

## Findings por Severidade

### CRITICAL
[lista detalhada com evidência e impacto]

### HIGH
[lista detalhada]

### MEDIUM
[lista]

### LOW
[lista]

## Remediação Prioritizada

| # | Finding | Fix | Comando / Ação | Esforço | Impacto |
|---|---------|-----|----------------|---------|---------|
| 1 | [finding] | [fix description] | `[comando]` | [min/h/d] | [score reduction] |
[... ordenado por impacto/esforço]

## Próximos Passos
- [ ] Corrigir CRITICAL findings (prazo: imediato)
- [ ] Corrigir HIGH findings (prazo: [X] dias)
- [ ] Gerar runbooks para remediação: `/runbook [procedimento]`
- [ ] Re-audit após correções: `/infra-audit [mesmo alvo]`
- [ ] Abrir issues no tracker para acompanhamento
```

---

## FASE 5: Remediação Assistida

Para cada finding CRITICAL/HIGH, oferecer:

1. **Comando de fix** pronto p/ executar
2. **Verificação** p/ confirmar que fix funcionou
3. **Rollback** se fix causar problema
4. **Runbook reference** se procedimento é complexo (sugerir `/runbook`)

Exemplo:
```
FINDING: SSH PermitRootLogin = yes
FIX:     sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && systemctl restart sshd
VERIFY:  grep PermitRootLogin /etc/ssh/sshd_config && ssh root@localhost (deve falhar)
ROLLBACK: sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && systemctl restart sshd
```

---

## Integração com outros skills

| Situação | Skill |
|----------|-------|
| Vulnerabilidade precisa scan profundo | `/sec-scan` com Trivy detalhado |
| Remediação precisa procedimento | `/runbook` para gerar runbook |
| Audit revela incidente ativo | `/incident` para resposta |
| Multi-sistema precisa análise cruzada | `/squad` com @infra-sre + @security-auditor |
| Dashboard de compliance | `/front` para visualização |

---

## Regras do auditor

- **Evidência > opinião**. Cada finding tem comando que o prova.
- **Contexto importa**. Um servidor dev não precisa do mesmo hardening que prod.
- **Não quebrar nada**. Scans são read-only. Nunca modificar o alvo durante audit.
- **Completude**. Rodar TODOS os checks aplicáveis, não pular por preguiça.
- **Actionable**. Cada finding tem fix. Relatório sem fix = relatório inútil.
