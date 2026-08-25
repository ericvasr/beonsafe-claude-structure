#!/usr/bin/env bash
# =============================================================================
# install.sh — configura o Claude Code do zero, passo a passo
# =============================================================================
# Guiado por padrão: pergunta o seu nome, sugere onde ficam projetos e wiki, e
# apresenta cada agente, skill e hook antes de instalar — dizendo o que cada um
# passa a fazer sozinho na sua máquina.
#
#   ./install.sh                 instalação guiada (recomendado)
#   ./install.sh --yes           aceita todos os padrões, sem perguntar
#   ./install.sh --dry-run       mostra o que faria, sem escrever
#   ./install.sh --force         sobrescreve arquivos que você editou
#
# Idempotente: rodar de novo produz o mesmo estado. Nunca apaga agente, skill ou
# hook seu, nunca sobrescreve seu CLAUDE.md, nunca toca em credencial.
# =============================================================================
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DST="${CLAUDE_HOME:-$HOME/.claude}"
STAMP="$(date -u +%Y%m%d-%H%M%S)"
BACKUP="$DST/backups/install-$STAMP"

DRY=0; FORCE=0; YES=0
for a in "$@"; do
  case "$a" in
    --yes|-y)              YES=1 ;;
    --dry-run)             DRY=1 ;;
    --force)               FORCE=1 ;;
    -h|--help)             sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "opção desconhecida: $a" >&2; exit 2 ;;
  esac
done
# Sem terminal (pipe, CI, curl|bash) não há como perguntar nada: assume padrões.
[ -t 0 ] || YES=1

# --- aparência ----------------------------------------------------------------
if [ -t 1 ]; then
  B=$'\033[1m'; DIM=$'\033[90m'; GRN=$'\033[32m'; YLW=$'\033[33m'; RED=$'\033[31m'
  CYN=$'\033[36m'; OFF=$'\033[0m'
else
  B=""; DIM=""; GRN=""; YLW=""; RED=""; CYN=""; OFF=""
fi
ok()   { printf '  %s✔%s %s\n' "$GRN" "$OFF" "$1"; }
skip() { printf '  %s·%s %s%s%s\n' "$DIM" "$OFF" "$DIM" "$1" "$OFF"; }
warn() { printf '  %s!%s %s\n' "$YLW" "$OFF" "$1"; }
die()  { printf '\n%s✘ %s%s\n' "$RED" "$1" "$OFF"; exit 1; }
step() { printf '\n%s%s%s\n%s%s%s\n' "$B" "$1" "$OFF" "$DIM" "$(printf '─%.0s' $(seq 1 ${#1}))" "$OFF"; }
note() { printf '  %s%s%s\n' "$DIM" "$1" "$OFF"; }

run() { if [ "$DRY" = 1 ]; then printf '  %s[dry] %s%s\n' "$DIM" "$*" "$OFF"; else "$@"; fi; }

# ask_yn "pergunta" "S|N"  → 0 = sim, 1 = não
ask_yn() {
  local q="$1" def="${2:-S}" hint ans
  [ "$def" = "S" ] && hint="[S/n]" || hint="[s/N]"
  if [ "$YES" = 1 ]; then [ "$def" = "S" ] && return 0 || return 1; fi
  while true; do
    printf '  %s%s%s %s ' "$CYN" "$q" "$OFF" "$hint"
    read -r ans </dev/tty || ans=""
    ans="${ans:-$def}"
    case "$ans" in
      [SsYy]*) return 0 ;;
      [NnFf]*) return 1 ;;
      *) warn "responda s ou n" ;;
    esac
  done
}

# ask_text "pergunta" "default" → ecoa a resposta
ask_text() {
  local q="$1" def="${2:-}" ans
  if [ "$YES" = 1 ]; then printf '%s' "$def"; return; fi
  printf '  %s%s%s %s[%s]%s ' "$CYN" "$q" "$OFF" "$DIM" "$def" "$OFF" >&2
  read -r ans </dev/tty || ans=""
  printf '%s' "${ans:-$def}"
}

# =============================================================================
step "Claude Code — instalação guiada"
cat <<FIM
  Este instalador monta uma configuração global de Claude Code: agentes que se
  acionam por domínio, skills próprias, hooks que rodam em toda sessão e um
  pipeline de conhecimento em dois vaults do Obsidian.

  ${B}Global quer dizer global.${OFF} O que entra aqui vale em ${B}qualquer${OFF} diretório
  onde você abrir o Claude Code, não só neste projeto. Por isso cada peça é
  apresentada antes de ser instalada, com o que ela passa a fazer sozinha.

  Nada é destruído: o que já existe vira backup antes de qualquer escrita.
FIM
[ "$YES" = 1 ] && note "modo --yes: aceitando todos os padrões"
[ "$DRY" = 1 ] && warn "modo dry-run: nada será escrito"
ask_yn "Seguir?" S || { echo; note "Cancelado. Nada foi alterado."; exit 0; }

# =============================================================================
step "1/8 · Pré-requisitos"
command -v jq >/dev/null || die "jq não encontrado. Instale antes: apt install jq · brew install jq"
ok "jq $(jq --version)"
if command -v git >/dev/null; then ok "git $(git --version | awk '{print $3}')"
else warn "git ausente — o gate de code review e o esteira-gate dependem dele"; fi
if command -v claude >/dev/null; then ok "claude CLI presente"
else warn "claude CLI fora do PATH — instale em https://claude.com/claude-code"; fi
if command -v rsync >/dev/null; then ok "rsync presente"; else note "rsync ausente (uso cp, tudo bem)"; fi

# =============================================================================
step "2/8 · Quem é você"
cat <<FIM
  O nome serve para duas coisas concretas, não para enfeite:

    · o guard de voz bloqueia comentários de PR que citem você em terceira
      pessoa ("o fulano pediu") — sem o nome, ele não tem como saber;
    · o CLAUDE.md instalado já sai com o seu nome no lugar do placeholder.
FIM
OWNER="$(ask_text 'Seu primeiro nome (ou o apelido que usa no trabalho):' "${OWNER_NAME:-$USER}")"
ok "voz configurada para: $OWNER"

# =============================================================================
step "3/8 · Onde ficam os seus projetos"
cat <<FIM
  Uma pasta única para código é o que faz os agentes de operação e o pipeline de
  conhecimento acharem as coisas sem você dizer o caminho toda vez.
FIM
PROJECTS="$(ask_text 'Pasta de projetos:' "${PROJECTS_ROOT:-$HOME/Projects}")"
if [ -d "$PROJECTS" ]; then
  ok "$PROJECTS já existe ($(find "$PROJECTS" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l) pastas)"
elif ask_yn "Criar $PROJECTS?" S; then
  run mkdir -p "$PROJECTS"; ok "$PROJECTS criada"
else
  skip "pasta de projetos não criada"
fi

# =============================================================================
step "4/8 · Os dois vaults de conhecimento"
cat <<FIM
  O pipeline de conhecimento escreve em ${B}dois${OFF} vaults, e a separação é o ponto
  inteiro — não é organização, é sobrevivência do conhecimento:

    ${B}pessoal${OFF}   padrão, armadilha, ofício. O que ainda vale se você trocar de
              emprego amanhã. Nunca recebe IP de cliente, credencial ou contrato.

    ${B}empresa${OFF}   SSOT operacional: host, decisão de arquitetura, topologia,
              versão. Morre junto com o sistema que descreve.

  O destino de cada aprendizado é decidido pelo ${B}conteúdo${OFF}, na hora de ingerir —
  nunca pelo diretório onde a sessão rodou. O mesmo incidente costuma virar duas
  páginas com recortes diferentes, uma linkando a outra.

  São pastas comuns. O Obsidian abre cada uma como um vault (docs/obsidian.md).
FIM
VAULTS_ROOT="$(ask_text 'Onde criar os vaults:' "${VAULTS_ROOT:-$HOME/vaults}")"
MAKE_VAULTS=0
ask_yn "Criar os dois vaults em $VAULTS_ROOT?" S && MAKE_VAULTS=1 || skip "vaults não criados"

make_vault() {
  local root="$1" id="$2" desc="$3"
  if [ -f "$root/.wikiconfig.json" ]; then skip "$root já é um vault"; return; fi
  run mkdir -p "$root/wiki/meta/inbox" "$root/raw"
  local d
  for d in projetos-pessoais projetos-trabalho leituras metas temas domains desenvolvimento atividades feedbacks; do
    run mkdir -p "$root/wiki/$d"
  done
  for d in artigos leituras notas feedbacks videos; do run mkdir -p "$root/raw/$d"; done
  if [ "$DRY" = 0 ]; then
    jq --arg id "$id" --arg desc "$desc" '.id=$id | .desc=$desc' \
      "$SRC/wiki/wikiconfig.example.json" > "$root/.wikiconfig.json"
    [ -f "$root/wiki/index.md" ] || printf '# Índice\n\nPáginas deste vault, mantidas pelo /ingerir.\n' > "$root/wiki/index.md"
    [ -f "$root/wiki/log.md" ]   || printf '# Log\n\nUma linha por ingestão, mais recente no topo.\n' > "$root/wiki/log.md"
  fi
  ok "$root  ($id)"
}
if [ "$MAKE_VAULTS" = 1 ]; then
  make_vault "$VAULTS_ROOT/conhecimento-pessoal" pessoal "Wiki de conhecimento pessoal. Padrão, armadilha, ofício — o que sobrevive a trocar de emprego."
  make_vault "$VAULTS_ROOT/conhecimento-empresa" empresa "SSOT operacional. Host, ADR, topologia, decisão de negócio — morre com o sistema."
fi

# =============================================================================
step "5/8 · Backup do que já existe"
if [ -d "$DST" ]; then
  run mkdir -p "$BACKUP"
  for d in agents skills commands hooks policies docs wiki examples; do
    [ -e "$DST/$d" ] && run cp -a "$DST/$d" "$BACKUP/" || true
  done
  for f in settings.json CLAUDE.md; do
    [ -f "$DST/$f" ] && run cp -a "$DST/$f" "$BACKUP/" || true
  done
  ok "backup em $BACKUP"
  # Backup a cada rodada cresce sem limite e ninguém percebe até o disco reclamar.
  if [ "$DRY" = 0 ]; then
    n_old=$(ls -1d "$DST"/backups/install-* 2>/dev/null | head -n -5 | wc -l)
    if [ "$n_old" -gt 0 ]; then
      ls -1d "$DST"/backups/install-* | head -n -5 | xargs rm -rf
      note "$n_old backup(s) antigo(s) removido(s); mantidos os 5 mais recentes"
    fi
  fi
else
  run mkdir -p "$DST"; ok "criado $DST"
fi

# --- cópia de um arquivo, preservando o que você editou -----------------------
copy_one() {
  local rel="$1" s="$SRC/$1" d="$DST/$1"
  if [ -f "$d" ]; then
    if cmp -s "$s" "$d"; then skip "$rel (igual)"; return 0; fi
    if [ "$FORCE" = 1 ]; then run cp "$s" "$d"; ok "$rel (sobrescrito)"; return 0; fi
    warn "$rel difere do seu — preservado (use --force para sobrescrever)"
    return 0
  fi
  run mkdir -p "$(dirname "$d")"
  run cp "$s" "$d"
  return 0
}
copy_group() { local rel; for rel in "$@"; do copy_one "$rel"; done; }

# =============================================================================
step "6/8 · Agentes"
cat <<FIM
  Agentes se acionam ${B}por domínio${OFF}: você descreve a tarefa, o Claude escolhe o
  especialista. Cada família abaixo é um bloco — instale a que fizer sentido.
FIM

offer_family() {
  local titulo="$1" descricao="$2" dir="$3" default="$4"; shift 4
  printf '\n  %s%s%s\n' "$B" "$titulo" "$OFF"
  printf '  %s%s%s\n' "$DIM" "$descricao" "$OFF"
  local a
  for a in "$@"; do printf '    %s· %s%s\n' "$DIM" "$a" "$OFF"; done
  if ask_yn "Instalar?" "$default"; then
    local rel
    while IFS= read -r rel; do copy_one "$rel"; done < <(cd "$SRC" && find "$dir" -name '*.md' | sort)
    ok "$titulo instalada"
  else
    skip "$titulo pulada"
  fi
}

offer_family "Infra e segurança" \
  "Roda antes de clonar código de terceiro: o gate de licença é obrigatório." \
  agents/infra S \
  "security-auditor — OWASP, secrets, gate de licença SPDX, escalada para pentest" \
  "infra-sre — servidor, rede, container, observabilidade, capacidade" \
  "devops-pipeline — Actions, Docker, deploy e rollback declarado"

offer_family "Desenvolvimento" \
  "Entram antes do código: contrato, schema e modelo de domínio decididos primeiro." \
  agents/dev S \
  "dev-fullstack — arquitetura, refactor, revisão, performance" \
  "api-designer — contrato de endpoint antes do handler" \
  "db-expert — schema, índice, migration, EXPLAIN (read-only em produção)" \
  "domain-modeler — regra de negócio, máquina de estados, vocabulário" \
  "test-engineer — o que testar, flaky, suíte lenta"

offer_family "Frontend" \
  "front-scout busca referência real antes; front-critic julga com screenshot depois." \
  agents/front S \
  "front-scout — busca e destila referências visuais reais (WebFetch/Playwright)" \
  "front-critic — Stranger Test e caça a slop de IA em 3 viewports"

offer_family "Operação — medem produção" \
  "Read-only por trava de hook. Precisam de examples/products.json com os SEUS produtos." \
  agents/operacao S \
  "liveness-auditor — o dado ainda está entrando?" \
  "esteira-gate — o CI valida o que diz validar?" \
  "release-conductor — o que está pronto e não protege ninguém?" \
  "prod-posture — o host está exposto? credencial default? compose untracked?" \
  "slo-keeper — SLI, SLO e orçamento de erro"

offer_family "Arquitetura de IA" \
  "Para quem constrói com LLM: RAG, agentes, custo de inferência, eval." \
  agents/base S \
  "ai-architect — orquestração, retrieval, prompt, skills e hooks"

# =============================================================================
step "7/8 · Skills, commands e hooks"
cat <<FIM
  ${B}Skill${OFF} é um procedimento que o Claude carrega quando a tarefa casa com a
  descrição dela. ${B}Command${OFF} é o que você dispara por /nome. ${B}Hook${OFF} é diferente
  dos dois: roda ${B}sozinho${OFF}, em toda sessão, sem você pedir — por isso cada um
  aparece aqui com o gatilho e o custo declarados.
FIM

offer_one() {
  local titulo="$1" descricao="$2" default="$3"; shift 3
  printf '\n  %s%s%s\n  %s%s%s\n' "$B" "$titulo" "$OFF" "$DIM" "$descricao" "$OFF"
  if ask_yn "Instalar?" "$default"; then copy_group "$@"; ok "$titulo"; else skip "$titulo pulada"; fi
}

offer_one "/squad" \
  "Despacha vários agentes em paralelo na mesma tarefa multi-domínio e sintetiza." \
  S skills/squad/SKILL.md
offer_one "/incident" \
  "Do alerta ao postmortem: triagem, mitigação, timeline e ações com dono." \
  S skills/incident/SKILL.md
offer_one "/runbook" \
  "Gera e executa procedimento passo a passo com comando de verificação." \
  S skills/runbook/SKILL.md
offer_one "/infra-audit" \
  "Auditoria de host, container, rede e certificado, com relatório." \
  S skills/infra-audit/SKILL.md
offer_one "/sec-scan" \
  "Scanning consolidado: imagem, filesystem, IaC, segredo, dependência, SBOM." \
  S skills/sec-scan/SKILL.md
offer_one "humanizer" \
  "Tira o registro de texto de IA da prosa que outra pessoa vai ler. Auto-aciona em README, changelog e copy." \
  S skills/humanizer/SKILL.md
printf '\n  %sFrontend — a skill front e as três de animação%s\n' "$B" "$OFF"
note "front é uma composição que integra 4 projetos de terceiros — crédito em skills/front/PROCEDENCIA.md"
if ask_yn "Instalar a skill front (SKILL.md + 22 referências)?" S; then
  while IFS= read -r rel; do copy_one "$rel"; done < <(cd "$SRC" && find skills/front -type f -name '*.md' | sort)
  ok "front instalada"
else
  skip "front pulada"
  note "sem ela, front-scout e front-critic perdem as referências que citam"
fi
offer_one "gsap" \
  "Timeline, ScrollTrigger, pin e scrub — quando a animação É o produto. Autoral, MIT." \
  S skills/gsap/SKILL.md
offer_one "motion" \
  "Animação declarativa em React: variants, AnimatePresence, layout animation. Autoral, MIT." \
  S skills/motion/SKILL.md
offer_one "threejs" \
  "Cena 3D e WebGL: partículas, shader, GLTF, dispose, fill rate. Autoral, MIT." \
  S skills/threejs/SKILL.md

offer_one "/consultar, /ingerir, /lint" \
  "O pipeline de conhecimento: consulta o vault, ingere aprendizado, revisa a wiki." \
  S commands/consultar.md commands/ingerir.md commands/lint.md

printf '\n  %sHooks — rodam sozinhos, em toda sessão%s\n' "$B" "$OFF"
offer_one "statusline" \
  "Mostra na barra o modelo, o diretório e o modo ativo. Custo: um processo por render." \
  S hooks/statusline.sh
offer_one "session-brief" \
  "No início da sessão, avisa se a wiki já tem página sobre este diretório. Silencioso quando não tem." \
  S hooks/session-brief.sh
offer_one "librarian (fim de sessão)" \
  "Bloqueia o encerramento e força a síntese do que foi aprendido para a wiki. É o que impede o conhecimento de morrer no scrollback." \
  S hooks/librarian-session-end.sh hooks/librarian-inbox.sh hooks/wiki-detect.sh
offer_one "code-review-gate" \
  "Grava o marco zero no início e, no encerramento de sessão que tocou código, pede o review. Bloqueia no máximo 2x." \
  S hooks/code-review-gate.sh
offer_one "review-voice-guard" \
  "Intercepta 'gh pr comment' e afins: nega assinatura de IA e citação sua em terceira pessoa antes de publicar." \
  S hooks/review-voice-guard.sh
offer_one "sync-configs (WSL)" \
  "Sincroniza settings.json entre WSL e Windows. Só serve se você usa os dois." \
  N hooks/sync-configs.sh

printf '\n'
copy_group policies/license-allowlist.json policies/license-policy.md
ok "política de licença instalada (o security-auditor depende dela)"
while IFS= read -r rel; do copy_one "$rel"; done < <(cd "$SRC" && find docs examples -type f \( -name '*.md' -o -name '*.json' \) | sort)
ok "docs e exemplos instalados"

if [ "$DRY" = 0 ]; then
  chmod +x "$DST"/hooks/*.sh 2>/dev/null || true
  ok "hooks marcados como executáveis"
  note "hook sem +x falha em silêncio — o sintoma é 'o gate nunca dispara'"
fi

# --- CLAUDE.md ----------------------------------------------------------------
printf '\n'
if [ -f "$DST/CLAUDE.md" ]; then
  run cp "$SRC/CLAUDE.md" "$DST/CLAUDE.md.blueprint"
  warn "seu CLAUDE.md foi mantido; o template ficou em CLAUDE.md.blueprint"
  note "compare os dois e traga o que fizer sentido — ele conduz toda sessão"
else
  if [ "$DRY" = 0 ]; then
    sed "s/<seu nome>/$OWNER/g" "$SRC/CLAUDE.md" > "$DST/CLAUDE.md"
  fi
  ok "CLAUDE.md instalado com o seu nome"
fi

# --- settings.json ------------------------------------------------------------
SETTINGS="$DST/settings.json"
FRAGMENT="$SRC/settings.fragment.json"
if [ ! -f "$FRAGMENT" ]; then
  warn "settings.fragment.json ausente — hooks não foram registrados"
elif [ "$DRY" = 1 ]; then
  skip "merge de settings.json (dry-run)"
else
  [ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
  jq empty "$SETTINGS" 2>/dev/null || die "seu settings.json é JSON inválido — conserte antes de reinstalar"
  TMP="$(mktemp)"
  # Merge, nunca substituição: mcpServers, permissions e enabledPlugins ficam.
  # Hook com o mesmo comando não é duplicado — reinstalar não empilha gatilho.
  jq -s --arg owner "$OWNER" '
    .[0] as $cur | .[1] as $new
    | $cur
    | .statusLine = ($new.statusLine // $cur.statusLine)
    | .env = (($cur.env // {}) + ($new.env // {}) + {OWNER_NAME: $owner})
    | .hooks = (
        reduce ($new.hooks // {} | to_entries[]) as $ev (($cur.hooks // {});
          .[$ev.key] = (
            ((.[$ev.key] // []) + $ev.value)
            | group_by(.matcher // "")
            | map(
                (.[0].matcher // null) as $m
                | {hooks: (map(.hooks[]) | unique_by(.command))}
                | if $m == null then . else {matcher: $m} + . end
              )
          ))
      )
  ' "$SETTINGS" "$FRAGMENT" > "$TMP"
  jq empty "$TMP" 2>/dev/null || { rm -f "$TMP"; die "o merge produziu JSON inválido — settings.json ficou intocado"; }
  mv "$TMP" "$SETTINGS"
  ok "settings.json mesclado (o que já era seu foi preservado)"
  ok "OWNER_NAME=$OWNER gravado no env"
fi

# --- registro dos vaults ------------------------------------------------------
if [ "$MAKE_VAULTS" = 1 ] && [ "$DRY" = 0 ]; then
  mkdir -p "$DST/wiki"
  for pair in "vaults.example.json:vaults.json" "default.example.json:default.json"; do
    s="$SRC/wiki/${pair%%:*}"; d="$DST/wiki/${pair##*:}"
    if [ -f "$d" ]; then skip "wiki/${pair##*:} já existe"
    else sed "s#\$HOME/vaults#$VAULTS_ROOT#g" "$s" > "$d"; ok "wiki/${pair##*:} → $VAULTS_ROOT"; fi
  done
fi

# =============================================================================
step "8/8 · Validação"
fail=0
for f in "$DST"/hooks/*.sh; do
  [ -e "$f" ] || continue
  bash -n "$f" 2>/dev/null || { warn "sintaxe inválida: $(basename "$f")"; fail=1; }
  [ -x "$f" ] || { warn "sem +x: $(basename "$f")"; fail=1; }
done
[ "$fail" = 0 ] && ok "hooks íntegros e executáveis"
for f in "$DST"/settings.json "$DST"/wiki/*.json "$DST"/examples/*.json "$DST"/policies/*.json; do
  [ -e "$f" ] || continue
  jq empty "$f" 2>/dev/null || { warn "JSON inválido: $f"; fail=1; }
done
[ "$fail" = 0 ] && ok "JSONs válidos"
ok "$(find "$DST/agents" -name '*.md' 2>/dev/null | wc -l) agentes · $(find "$DST/skills" -name 'SKILL.md' 2>/dev/null | wc -l) skills · $(find "$DST/hooks" -name '*.sh' 2>/dev/null | wc -l) hooks"
[ "$fail" != 0 ] && warn "há avisos acima — rode de novo com --force se quiser realinhar"

# =============================================================================
step "Pronto. Como começar"
cat <<FIM
  ${B}1. Abra uma sessão nova.${OFF} Hook só carrega no start — a sessão atual não vê
     nada do que acabou de ser instalado.

       cd $PROJECTS && claude

  ${B}2. Confira que a configuração está em vigor${OFF}, não só declarada:

       /doctor          diagnóstico do ambiente
       /agents          lista os agentes que o Claude enxerga
       /config          modelo, tema, permissões
       /status          o que está carregado nesta sessão

     Se a statusline não aparecer, o merge do settings.json não pegou.
     ${DIM}Config declarada não é config em vigor: a evidência é o comportamento.${OFF}

  ${B}3. Edite os dois arquivos que ainda estão genéricos:${OFF}

       ~/.claude/CLAUDE.md            conduz toda sessão; sem o seu contexto,
                                      os agentes recomendam no vazio
       ~/.claude/examples/products.json   os agentes de operação leem daqui
                                      antes de medir produção

  ${B}4. Instale o Obsidian e abra os dois vaults.${OFF} Passo a passo com telas em
     docs/obsidian.md. Sem ele o pipeline funciona — você só perde a leitura.

  ${B}5. Primeira volta completa${OFF}, para ver o ciclo fechar:

       peça qualquer coisa que toque código, encerre a sessão, e observe o
       librarian pedir a síntese. O que você responder vira página na wiki.

FIM
[ "$DRY" = 1 ] && warn "isto foi um dry-run: nada acima foi realmente escrito"
exit 0
