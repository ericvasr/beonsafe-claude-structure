---
name: sec-scan
description: Orquestra scanning de segurança completo — containers, filesystem, IaC, secrets, dependências, SBOM. Usa Trivy como engine principal + checks nativos. Gera relatório consolidado com severidades e remediações actionable. Exemplo - /sec-scan imagem docker myapp:latest ou /sec-scan repo . ou /sec-scan tudo
allowed-tools: Agent(*) Read(*) Glob(*) Grep(*) Write(*) Edit(*) Bash(*)
argument-hint: <alvo do scan - imagem, path, repo, ou 'tudo'>
effort: high
---

# /sec-scan — Security Scanning Orchestrator

Engine de scanning que orquestra Trivy + checks nativos em paralelo, consolida resultados, e produz relatório actionable.

## Alvo
$ARGUMENTS

---

## FASE 0: Detecção de Alvos

Detectar automaticamente o que escanear:

```bash
# Detectar alvos disponíveis
echo "=== Docker images ===" && docker images --format '{{.Repository}}:{{.Tag}} ({{.Size}})' 2>/dev/null | head -20
echo "=== Containers running ===" && docker ps --format '{{.Image}} → {{.Names}}' 2>/dev/null
echo "=== Dockerfiles ===" && find . -name "Dockerfile*" -o -name "docker-compose*.yml" 2>/dev/null | head -10
echo "=== IaC files ===" && find . -name "*.tf" -o -name "*.tfvars" -o -name "*.yaml" -o -name "*.yml" 2>/dev/null | grep -E 'terraform|k8s|kube|helm|ansible' | head -10
echo "=== Package managers ===" && ls package.json requirements.txt Gemfile go.mod pom.xml build.gradle Cargo.toml 2>/dev/null
echo "=== .env files ===" && find . -name ".env*" -not -path "*/node_modules/*" 2>/dev/null
```

### Classificação de alvos

| Alvo detectado | Scan type | Trivy mode |
|----------------|-----------|------------|
| Docker image | `IMAGE` | `trivy image` |
| Running container | `CONTAINER` | `trivy image` (da imagem) |
| Dockerfile / docker-compose | `CONFIG` | `trivy config` |
| Terraform / K8s manifests | `IAC` | `trivy config` |
| package.json / requirements.txt | `DEPS` | `trivy fs --scanners vuln` |
| Source code directory | `FILESYSTEM` | `trivy fs --scanners vuln,secret,misconfig` |
| .env files | `SECRETS` | `trivy fs --scanners secret` + check nativo |
| "tudo" / não especificado | `FULL` | Todos os acima que existem |

---

## FASE 1: Scanning Paralelo

Executar TODOS os scans aplicáveis em PARALELO via Agent tool ou Bash.

### Scan 1 — Vulnerabilidades (dependências)

```bash
# Filesystem vulnerability scan
trivy fs --scanners vuln --severity HIGH,CRITICAL --format json . 2>/dev/null | \
  python3 -c "
import json,sys
d=json.load(sys.stdin)
results=d.get('Results',[])
total={'CRITICAL':0,'HIGH':0,'MEDIUM':0,'LOW':0}
for r in results:
    for v in r.get('Vulnerabilities',[]):
        sev=v.get('Severity','UNKNOWN')
        if sev in total: total[sev]+=1
print(f'Vulnerabilities: {total}')
for r in results:
    for v in r.get('Vulnerabilities',[]):
        if v.get('Severity') in ('CRITICAL','HIGH'):
            pkg=v.get('PkgName','?')
            ver=v.get('InstalledVersion','?')
            fix=v.get('FixedVersion','none')
            cve=v.get('VulnerabilityID','?')
            print(f'  [{v[\"Severity\"]}] {cve}: {pkg} {ver} → fix: {fix}')
" 2>/dev/null
```

### Scan 2 — Secrets

```bash
# Trivy secret scan
trivy fs --scanners secret --format json . 2>/dev/null | \
  python3 -c "
import json,sys
d=json.load(sys.stdin)
for r in d.get('Results',[]):
    for s in r.get('Secrets',[]):
        print(f'  [{s.get(\"Severity\",\"?\")}] {s.get(\"Title\",\"?\")} in {r.get(\"Target\",\"?\")}:{s.get(\"StartLine\",\"?\")}')
" 2>/dev/null

# Check nativo: .env files com secrets
find . -name ".env*" -not -path "*/node_modules/*" -exec sh -c '
  echo "--- $1 ---"
  grep -inE "(password|secret|token|key|api_key|private)=" "$1" 2>/dev/null | \
    sed "s/=.*/=<REDACTED>/"
' _ {} \; 2>/dev/null

# Check: hardcoded secrets em código
grep -rn --include="*.js" --include="*.ts" --include="*.py" --include="*.java" --include="*.go" \
  -iE "(password|secret|api.?key|token)\s*[:=]\s*['\"][^'\"]{8,}" . 2>/dev/null | \
  grep -v node_modules | grep -v ".min." | head -20
```

### Scan 3 — Container Images

```bash
# Para cada imagem relevante
for img in $(docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -v '<none>' | head -5); do
  echo "=== Scanning: $img ==="
  trivy image --severity HIGH,CRITICAL --format table "$img" 2>/dev/null | tail -30
done
```

### Scan 4 — IaC / Configuration

```bash
# Scan de misconfiguration
trivy config --severity HIGH,CRITICAL --format json . 2>/dev/null | \
  python3 -c "
import json,sys
d=json.load(sys.stdin)
for r in d.get('Results',[]):
    for m in r.get('Misconfigurations',[]):
        if m.get('Severity') in ('CRITICAL','HIGH'):
            print(f'  [{m[\"Severity\"]}] {m.get(\"ID\",\"?\")} — {m.get(\"Title\",\"?\")}')
            print(f'    File: {r.get(\"Target\",\"?\")}')
            print(f'    Fix: {m.get(\"Resolution\",\"?\")}')
" 2>/dev/null
```

### Scan 5 — Checks Nativos (sem Trivy)

```bash
# Permissões perigosas
find . -perm -o+w -type f -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | head -20

# Portas expostas em docker-compose
grep -rn "ports:" docker-compose*.yml 2>/dev/null | head -10

# TODO/FIXME/HACK com contexto security
grep -rn --include="*.js" --include="*.ts" --include="*.py" --include="*.go" \
  -iE "(TODO|FIXME|HACK|XXX).*(security|auth|password|token|vuln)" . 2>/dev/null | \
  grep -v node_modules | head -10
```

---

## FASE 2: SBOM Generation (se solicitado ou FULL scan)

```bash
# CycloneDX SBOM do filesystem
trivy fs --format cyclonedx --output sbom-cyclonedx.json . 2>/dev/null && \
  echo "SBOM gerado: sbom-cyclonedx.json" && \
  python3 -c "
import json
d=json.load(open('sbom-cyclonedx.json'))
comps=d.get('components',[])
print(f'Components: {len(comps)}')
by_type={}
for c in comps:
    t=c.get('type','unknown')
    by_type[t]=by_type.get(t,0)+1
for t,n in sorted(by_type.items()):
    print(f'  {t}: {n}')
" 2>/dev/null

# SBOM de container image (se alvo específico)
# trivy image --format cyclonedx --output sbom-image.json [IMAGE]
```

---

## FASE 3: Consolidação & Priorização

Após todos os scans, consolidar:

### Deduplicação
- Mesma CVE em múltiplos targets → agrupar, mostrar uma vez com lista de affected targets
- Mesmo secret em múltiplos files → agrupar

### Priorização (ordem de fix)

1. **CRITICAL vulnerabilities com fix disponível** → fix imediato (update dependency)
2. **Secrets expostos em código** → remover e rotacionar AGORA
3. **CRITICAL sem fix** → avaliar workaround ou substituição
4. **HIGH vulnerabilities com fix** → planejar fix (próximo sprint)
5. **IaC misconfigurations CRITICAL/HIGH** → corrigir config
6. **HIGH sem fix** → monitorar, avaliar risco
7. **MEDIUM** → backlog

### Métricas

```
Total findings: [N]
  CRITICAL: [N] ([N] with fix, [N] without)
  HIGH:     [N] ([N] with fix, [N] without)
  MEDIUM:   [N]
  LOW:      [N]

Secrets exposed: [N]
IaC misconfigs:  [N]
SBOM components: [N]
```

---

## FASE 4: Relatório

Gerar em `[PROJECT_ROOT]/security-reports/sec-scan-[date].md`:

```markdown
# Security Scan Report

## Metadata
- **Data**: [YYYY-MM-DD HH:MM UTC]
- **Alvo**: [o que foi escaneado]
- **Engine**: Trivy [version] + checks nativos
- **Scope**: [FULL / IMAGE / FILESYSTEM / CONFIG / ...]

## Resumo Executivo

| Categoria | CRITICAL | HIGH | MEDIUM | LOW |
|-----------|----------|------|--------|-----|
| Vulnerabilidades | [N] | [N] | [N] | [N] |
| Secrets | [N] | [N] | — | — |
| Misconfigs (IaC) | [N] | [N] | [N] | [N] |
| **TOTAL** | **[N]** | **[N]** | **[N]** | **[N]** |

**Risk rating**: [CRITICAL / HIGH / MEDIUM / LOW / CLEAN]

## Top 10 Findings (by priority)

| # | Severity | Type | ID | Description | Fix available | Target |
|---|----------|------|----|-------------|---------------|--------|
| 1 | CRITICAL | vuln | CVE-XXXX-YYYY | [desc] | Yes: [version] | [file/image] |
[...]

## Detailed Findings

### Vulnerabilities
[tabela completa com CVE, package, installed version, fixed version, target]

### Secrets Exposed
[lista com file:line, tipo de secret (REDACTED value), recomendação]

### IaC Misconfigurations
[lista com file, check ID, title, resolution]

### Native Checks
[permissões, portas expostas, TODOs de security]

## Remediação

### Quick Wins (< 30 min)
[lista de fixes simples: update dependency, remove .env, fix permission]

### Planned Fixes (next sprint)
[lista de fixes que requerem mais trabalho]

### Accept / Monitor
[findings sem fix disponível que precisam monitoramento]

## SBOM Summary
- Total components: [N]
- By type: [library: N, framework: N, ...]
- File: `sbom-cyclonedx.json`
```

---

## FASE 5: Fix Assistido

Para findings com fix disponível, oferecer comandos prontos:

### Dependency updates
```bash
# Node.js
npm audit fix
# ou específico:
npm install [package]@[fixed-version]

# Python
pip install [package]==[fixed-version]
# ou:
pip-audit --fix

# Go
go get [package]@[fixed-version]
```

### Secret removal
```bash
# Remover secret do código e adicionar ao .env
# 1. Identificar
grep -rn "API_KEY.*=.*\"sk-" . --include="*.js"
# 2. Mover para .env
echo "API_KEY=sk-..." >> .env
# 3. Atualizar código para usar env var
# 4. Verificar .gitignore inclui .env
# 5. ROTACIONAR o secret (o antigo está no git history!)
```

### IaC fixes
```bash
# Dockerfile: add non-root user
# Append after last RUN:
RUN addgroup --system app && adduser --system --ingroup app app
USER app

# docker-compose: remove privileged
# Remove: privileged: true
# Add specific caps: cap_add: [NET_ADMIN] (only what's needed)
```

---

## Modos de execução

### Quick scan (padrão)
```
/sec-scan .
```
Scan filesystem com Trivy (vuln + secret + misconfig). Relatório resumido.

### Image scan
```
/sec-scan image myapp:latest
```
Scan específico de container image. Inclui SBOM.

### Full scan
```
/sec-scan tudo
```
Todos os scans: filesystem, todas as imagens Docker, configs, secrets, SBOM. Relatório completo.

### CI mode (output parseable)
```
/sec-scan ci .
```
Output em formato JSON/SARIF para integração com CI/CD. Exit code não-zero se CRITICAL/HIGH.

---

## Integração com outros skills

| Situação | Skill |
|----------|-------|
| Scan revela breach ativo | `/incident` para resposta |
| Findings precisam audit mais amplo | `/infra-audit` completo |
| Fix precisa procedimento documentado | `/runbook` para gerar playbook |
| Multi-repo scan com análise cruzada | `/squad` com @security-auditor |
| Dashboard de vulnerabilidades | `/front` para visualização |

---

## Regras do scanner

- **Scan é read-only**. Nunca modificar código/config durante scan. Só reportar.
- **Redact secrets**. Nunca mostrar o valor completo de um secret no relatório. Usar `<REDACTED>`.
- **Fix > report**. Relatório sem remediação = relatório inútil. Cada finding tem fix sugerido.
- **Context matters**. Dev dependencies com vuln HIGH ≠ prod dependencies com vuln HIGH. Anotar contexto.
- **SBOM é deliverable**. Para scans FULL, sempre gerar CycloneDX SBOM.
- **Rerun after fix**. Após correções, re-executar scan para confirmar. Sugerir isso no relatório.
