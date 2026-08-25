#!/usr/bin/env bash
# =============================================================================
# session-brief.sh — o começo de sessão que faltava
# =============================================================================
# SessionStart. O fim de sessão já é automático: o librarian bloqueia o Stop e
# força a síntese para a wiki. O começo não era — e o CLAUDE.md registra o custo
# disso: "se eu não puxar, o conhecimento entra e nunca sai", com o caso de eu ir
# reescrever um script que tinha construído no dia anterior.
#
# Este hook puxa, em três frentes, o que já existe e ninguém lia:
#   1. as últimas ingestões do vault (o que aprendi recentemente);
#   2. páginas da wiki cujo nome casa com o diretório de trabalho;
#   3. a última medição de cada agente que tem `memory:` no frontmatter
#      (~/.claude/agent-memory/<nome>/) — o registro durável que substitui
#      "o resultado do subagente morreu no fim do turno".
#
# Sai SILENCIOSO quando não há nada a dizer: zero ruído em cwd sem histórico.
# Teto rígido de linhas, porque isso entra em TODA sessão e contexto é caro.
# Nunca falha a sessão (exit 0 sempre).
#
# Env: SESSION_BRIEF_OFF=1 desliga.
# =============================================================================
set -uo pipefail

# Log SEMPRE, inclusive nos no-ops e com o motivo. Sem isso não há como responder
# "rodou? teve efeito? por quê não?" — e "não apareceu nada na tela" não distingue
# hook que não rodou de hook que rodou e calou de propósito. additionalContext do
# SessionStart vai para o modelo, nunca para o terminal.
BRIEF_LOG="$HOME/.claude/logs/session-brief.jsonl"
brief_log() {
  mkdir -p "$(dirname "$BRIEF_LOG")" 2>/dev/null || true
  printf '{"ts":"%s","cwd":"%s","emitted":%s,"reason":"%s"}\n' \
    "$(date -Is)" "${CWD:-?}" "$1" "$2" >> "$BRIEF_LOG" 2>/dev/null || true
}

[ "${SESSION_BRIEF_OFF:-}" = "1" ] && { CWD="${PWD}"; brief_log false "desligado por env"; exit 0; }

CWD="${CLAUDE_PROJECT_DIR:-$PWD}"
# O payload do SessionStart traz o cwd real; o env pode divergir em subdiretório.
PAYLOAD=$(timeout 1 cat 2>/dev/null || true)
FROM_PAYLOAD=$(printf '%s' "$PAYLOAD" | python3 -c \
  "import json,sys; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null || true)
[ -n "$FROM_PAYLOAD" ] && CWD="$FROM_PAYLOAD"

# Diretório oculto vira nome buscável: `.claude` só casa com `claude-*.md` sem o ponto.
BASE=$(basename "$CWD" | sed 's/^[._-]*//')

# Nome curto demais ou sem letras não é âncora: um diretório chamado `2026` casaria
# com toda nota datada do vault e o brief viraria lixo. Melhor calar.
[ ${#BASE} -lt 4 ] && { brief_log false "nome curto demais: $BASE"; exit 0; }
printf '%s' "$BASE" | grep -qE '[a-zA-Z]{3}' || { brief_log false "nome sem letras: $BASE"; exit 0; }
OUT=""
ANCHOR=0   # só fala se houver âncora NESTE cwd; log e memória são globais e,
           # sozinhos, virariam parede de texto repetida em toda sessão.
add() { OUT="${OUT}$1"$'\n'; }

# --- 1 e 2: o que a wiki já sabe -------------------------------------------
eval "$(bash "$HOME/.claude/hooks/wiki-detect.sh" "$CWD" 2>/dev/null)" || true

for ROOT in "${WIKI_VAULT_PESSOAL:-}" "${WIKI_VAULT_EMPRESA:-}"; do
  [ -z "$ROOT" ] || [ ! -d "$ROOT" ] && continue

  # Páginas cujo NOME casa com o diretório de trabalho. Casar por nome de arquivo
  # (e não por conteúdo) é de propósito: grep de conteúdo em vault grande é caro e
  # devolve ruído. Quem quer o conteúdo roda /consultar.
  # raw/ fica de fora: é fonte imutável, não é o que se lê para se orientar. O que
  # vale aqui é a página destilada, que é onde mora a conclusão.
  HITS=$(find "$ROOT" -iname "*${BASE}*.md" -not -path "*/.*" -not -path "*/raw/*" \
         -not -path "*/meta/*" 2>/dev/null | head -4)

  # Projeto novo costuma herdar o nome do anterior com um ano colado
  # (`produto` -> `produto2026`). Sem tirar o sufixo, a sessão que mais precisa
  # do histórico é justamente a que não acha nada.
  STEM=$(printf '%s' "$BASE" | sed -E 's/[-_ ]?(19|20)[0-9]{2}$//')
  if [ -z "$HITS" ] && [ "$STEM" != "$BASE" ] && [ ${#STEM} -ge 4 ]; then
    HITS=$(find "$ROOT" -iname "*${STEM}*.md" -not -path "*/.*" -not -path "*/raw/*" \
           -not -path "*/meta/*" 2>/dev/null | head -4)
    [ -n "$HITS" ] && BASE="$STEM (projeto anterior)"
  fi
  if [ -n "$HITS" ]; then
    ANCHOR=1
    add "Wiki tem página sobre \`$BASE\` — leia antes de reconstruir:"
    while IFS= read -r h; do add "  - ${h#$ROOT/}"; done <<< "$HITS"
  fi
done

# Sem âncora neste diretório, o resto é ruído global: cala a boca e sai.
[ "$ANCHOR" = 0 ] && { brief_log false "sem pagina na wiki para $BASE"; exit 0; }

# Últimas ingestões: o log é append-only com prefixo greppável.
WIKI_LOG="${WIKI_VAULT_PESSOAL:-}/wiki/log.md"
if [ -f "$WIKI_LOG" ]; then
  RECENT=$(grep '^## \[' "$WIKI_LOG" 2>/dev/null | tail -3 | sed 's/^## /  /')
  [ -n "$RECENT" ] && { add "Últimas ingestões na wiki:"; add "$RECENT"; }
fi

# --- 3: última medição de cada agente com memória ---------------------------
MEM="$HOME/.claude/agent-memory"
if [ -d "$MEM" ]; then
  LINES=""
  for d in "$MEM"/*/; do
    [ -d "$d" ] || continue
    NAME=$(basename "$d")
    NEWEST=$(find "$d" -type f -name '*.md' -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
    [ -z "$NEWEST" ] && continue
    WHEN=$(date -r "$NEWEST" +%F 2>/dev/null)
    LINES="${LINES}  - ${NAME}: última nota em ${WHEN}"$'\n'
  done
  [ -n "$LINES" ] && { add "Agentes com memória (consulte antes de remedir):"; add "${LINES%$'\n'}"; }
fi

[ -z "$OUT" ] && { brief_log false "nada a dizer"; exit 0; }

# Teto rígido: 18 linhas. Isso roda em toda sessão; brief que vira parede de texto
# é lido como ruído e treina a ignorar o próprio hook.
printf 'CONTEXTO DE ABERTURA — o que já está registrado sobre este diretório.\n'
printf '%s' "$OUT" | head -18
brief_log true "emitiu contexto para $BASE"
printf 'Regra do CLAUDE.md: consultar antes de construir. Se o assunto já teve sessão, rode /consultar <tema> antes da primeira edição — o registro costuma estar mais certo que a reconstrução.\n'
exit 0
