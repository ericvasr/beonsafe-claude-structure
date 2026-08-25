#!/bin/bash
# =============================================================================
# librarian-inbox.sh — PostToolUse hook do Active Librarian (vault-aware)
# =============================================================================
# Dispara em Write|Edit. Loga a mudança no inbox do vault correspondente ao
# cwd do evento (resolvido por wiki-detect.sh). Sem vault → wiki pessoal.
#
# Input: JSON no stdin (evento PostToolUse). Output: nenhum (silencioso).
# =============================================================================
set -uo pipefail

CDIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
LOG="$CDIR/logs/librarian.jsonl"
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true
# Este hook era um no-op perfeito quando algo falhava: zero log. Agora todo caminho
# de saída diz o que fez e por quê — "rodou? teve efeito? por que não?".
_log() { printf '{"ts":"%s","hook":"inbox","action":"%s","reason":"%s"}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1" "$2" >>"$LOG" 2>/dev/null || true; }

INPUT=$(cat)
JQ=$(command -v jq || echo /usr/bin/jq)
if [ ! -x "$JQ" ]; then _log skip no_jq; exit 0; fi

# Vault-aware: resolve o vault pelo cwd do evento (fallback interno no resolver)
CWD=$(echo "$INPUT" | "$JQ" -r '.cwd // empty')
# O `|| true` precisa ficar FORA do eval: dentro da command substitution ele não
# protege o eval de morrer com exports mal quotados (vault com espaço no path).
DETECTED=$(bash "$HOME/.claude/hooks/wiki-detect.sh" "$CWD" 2>/dev/null || true)
eval "$DETECTED" || _log warn wiki_detect_eval_failed
INBOX="${WIKI_INBOX:-$HOME/vaults/conhecimento-pessoal/wiki/meta/inbox}"
CHANGES="$INBOX/changes.jsonl"
mkdir -p "$INBOX"

TOOL=$(echo "$INPUT" | "$JQ" -r '.tool_name // "unknown"')
SESSION_ID=$(echo "$INPUT" | "$JQ" -r '.session_id // "unknown"')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
FILE_PATH=$(echo "$INPUT" | "$JQ" -r '.tool_input.file_path // "unknown"')

# Tamanho da mudança (proxy). `// 0` garante número, nunca "null" cru no JSON.
SIZE=$(echo "$INPUT" | "$JQ" -c '
  if   .tool_name == "Edit"  then {old_len:(.tool_input.old_string//""|length), new_len:(.tool_input.new_string//""|length)}
  elif .tool_name == "Write" then {content_len:(.tool_input.content//""|length)}
  else {} end' 2>/dev/null || echo '{}')

# Montar o objeto COM jq, não por interpolação de string: um path com " ou \
# produzia linha JSON inválida e quebrava o /ingerir no parse do changes.jsonl.
if "$JQ" -n -c \
    --arg ts "$TIMESTAMP" \
    --arg tool "$TOOL" \
    --arg path "$FILE_PATH" \
    --arg session "${SESSION_ID:0:12}" \
    --arg vault "${WIKI_VAULT_ID:-pessoal}" \
    --argjson size "$SIZE" \
    '{ts:$ts,tool:$tool,path:$path,session:$session,vault:$vault} + $size' >> "$CHANGES" 2>/dev/null; then
  _log logged "$TOOL"
else
  _log error jq_write_failed
fi

exit 0
