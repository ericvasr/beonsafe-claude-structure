#!/bin/bash
# =============================================================================
# code-review-gate.sh — nenhuma sessão que tocou código encerra sem code review,
# e o review comenta INLINE NO PR, não só no terminal.
# =============================================================================
# Dois modos, um arquivo:
#   --baseline   (SessionStart) grava o marco zero da sessão: o HEAD e o que já
#                estava sujo na árvore ANTES de eu mexer em nada.
#   (sem arg)    (Stop) compara com o marco zero e bloqueia se sobrou código sem
#                review.
#
# O marco zero existe porque "o que mudou" sem ele é mentira em dois sentidos:
# a sujeira pré-existente da árvore entra na conta (e a sessão é acusada de
# mexer no que não mexeu), e o commit feito durante a sessão SAI da conta assim
# que a árvore fica limpa — que é justo o momento em que o review mais importa.
# Comparar com o upstream não resolve: aqui não há remote nenhum, `@{u}` falha,
# e a perna de "comitado e não enviado" desaparecia em silêncio.
#
# Bloqueia no máximo 2x por sessão. O teto não é paranoia: o librarian também
# bloqueia no mesmo Stop, os dois pedidos chegam juntos, e se o outro ganha a
# primeira rodada o `stop_hook_active` me calaria para sempre — o review sumia
# da sessão inteira. Com teto, eu pego a segunda rodada e ainda assim termino.
#
# Knobs (env): CODE_REVIEW_GATE=0 desliga; CODE_REVIEW_MIN_FILES (piso 1).
# Evidência de execução: ~/.claude/logs/code-review-gate.jsonl (linha por saída).
# =============================================================================
set -uo pipefail

CDIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
LOG="$CDIR/logs/code-review-gate.jsonl"
STATE="$CDIR/state/code-review"
mkdir -p "$(dirname "$LOG")" "$STATE" 2>/dev/null || true
find "$STATE" -maxdepth 1 -mtime +7 -type f -delete 2>/dev/null || true

_log() { printf '{"ts":"%s","hook":"code-review-gate","action":"%s","reason":"%s","files":%s}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1" "$2" "${3:-0}" >>"$LOG" 2>/dev/null || true; }

[ "${CODE_REVIEW_GATE:-1}" = "0" ] && { _log skip disabled_by_env; exit 0; }

INPUT=$(cat)
JQ=$(command -v jq || echo /usr/bin/jq)
[ -x "$JQ" ] || { _log skip no_jq; exit 0; }

CWD=$(echo "$INPUT" | "$JQ" -r '.cwd // empty')
SESSION_ID=$(echo "$INPUT" | "$JQ" -r '.session_id // empty')
SESSION_SHORT="${SESSION_ID:0:12}"

# Sem id não há marcador possível, e um marcador "unknown" compartilhado calaria
# o gate para todas as sessões seguintes por uma semana.
[ -n "$SESSION_SHORT" ] || { _log skip no_session_id; exit 0; }

[ -n "$CWD" ] && GITDIR=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null) \
  || { _log skip not_a_git_repo; exit 0; }

# `-uall` lista os arquivos DENTRO de diretório novo, em vez de colapsar a árvore
# inteira num `?? novodir/` que o filtro de extensão descarta — era o caso do
# diretório de código novo, o que mais precisa de review, passando invisível.
# `core.quotePath=false` impede que nome acentuado saia como "revis\303\243o.sh":
# a aspa final quebrava o `$` do regex e o arquivo não contava.
_dirty() { git -C "$CWD" -c core.quotePath=false status --porcelain -uall 2>/dev/null \
  | sed 's/^...//; s/.* -> //'; }

BASE="$STATE/$SESSION_SHORT.base"

if [ "${1:-}" = "--baseline" ]; then
  { git -C "$CWD" rev-parse HEAD 2>/dev/null || echo "-"; _dirty; } > "$BASE"
  _log baseline "$(basename "$GITDIR")"
  exit 0
fi

MARKER="$STATE/$SESSION_SHORT.done"
[ -f "$MARKER" ] && { _log skip already_reviewed; exit 0; }

BLOCKS_FILE="$STATE/$SESSION_SHORT.blocks"
# `cat`, não `< arquivo`: o redirecionamento de um arquivo que ainda não existe
# cospe "No such file or directory" no stderr do hook em toda primeira sessão,
# e o harness lê stderr de hook como falha.
BLOCKS=$(cat "$BLOCKS_FILE" 2>/dev/null | tr -dc '0-9'); BLOCKS="${BLOCKS:-0}"
[ "$BLOCKS" -ge 2 ] && { _log skip block_ceiling_reached; exit 0; }

# O que esta sessão deixou para revisar = sujeira nova + arquivos dos commits
# feitos desde o marco zero. Sem marco zero (sessão iniciada em outro repo),
# cai para a árvore inteira: prefiro pedir review a mais que deixar passar.
if [ -f "$BASE" ]; then
  BASE_HEAD=$(head -1 "$BASE")
  tail -n +2 "$BASE" > "$BASE.tree"
  CHANGED=$( {
    _dirty | grep -Fxv -f "$BASE.tree" || true
    if [ "$BASE_HEAD" != "-" ] && git -C "$CWD" rev-parse --quiet --verify "$BASE_HEAD" >/dev/null 2>&1; then
      git -C "$CWD" -c core.quotePath=false diff --name-only "$BASE_HEAD"..HEAD 2>/dev/null
    fi
  } | sort -u )
  rm -f "$BASE.tree"
else
  CHANGED=$(_dirty | sort -u)
fi

CHANGED=$(printf '%s\n' "$CHANGED" | grep -Ei '\.(py|js|jsx|ts|tsx|go|rs|java|rb|c|h|cpp|hpp|cc|cs|kt|swift|php|scala|lua|sh|bash|sql|vue|svelte)$' || true)
COUNT=$(printf '%s\n' "$CHANGED" | grep -c . || true)
COUNT=$(printf '%s' "$COUNT" | tr -dc '0-9'); COUNT="${COUNT:-0}"

# O piso é sempre >= 1: bloquear com zero arquivo não faz sentido, e era o que
# `CODE_REVIEW_MIN_FILES=0` — ou qualquer valor não numérico — provocava.
MIN=$(printf '%s' "${CODE_REVIEW_MIN_FILES:-1}" | tr -dc '0-9'); MIN="${MIN:-1}"
[ "$MIN" -lt 1 ] && MIN=1

if [ "$COUNT" -lt "$MIN" ]; then _log pass no_code_changes "$COUNT"; exit 0; fi

LIST=$(printf '%s\n' "$CHANGED" | head -20 | sed 's/^/  - /')
[ "$COUNT" -gt 20 ] && LIST="$LIST
  - ... e mais $((COUNT - 20)) arquivo(s)"

REASON="Antes de encerrar: esta sessão mexeu em $COUNT arquivo(s) de código e ainda não passou por code review. Rode o review agora — uma vez, e comente no código.

Arquivos:
$LIST

1. Rode \`/code-review --comment\` sobre esses arquivos. O \`--comment\` não é opcional: o achado tem que ficar ancorado no arquivo e na linha, como comentário inline no PR, não impresso no terminal e perdido no scrollback.
2. Sem PR aberto para este branch (\`gh pr view\` falha): entregue os achados no terminal com caminho:linha e diga que não havia PR onde comentar. Não abra PR só para ter onde comentar.
3. Nenhum comentário sai com assinatura de ferramenta nem etiqueta de IA — sem \`Co-Authored-By\`, sem \"Generated with\", sem 🤖, sem link para claude.ai, sem me citar em terceira pessoa. É a minha voz, primeira pessoa. Isso tem gate: \`hooks/review-voice-guard.sh\` nega o \`gh pr comment\` que carregue qualquer uma dessas marcas, então escrever limpo é mais rápido que ser barrado.
4. Ao terminar, grave o marcador: \`echo '<n> achados, <onde comentou>' > $MARKER\`. Sem ele este gate bloqueia de novo.
5. Se não houver o que revisar de verdade (só config, doc ou arquivo gerado), grave o marcador dizendo isso e siga.

Seja breve. Em português brasileiro."

echo $((BLOCKS + 1)) > "$BLOCKS_FILE"
_log block code_changes_unreviewed "$COUNT"
"$JQ" -n --arg r "$REASON" '{"decision":"block","reason":$r}'
exit 0
