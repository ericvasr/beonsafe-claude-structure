#!/bin/bash
# =============================================================================
# librarian-session-end.sh — Stop hook do Active Librarian (vault-aware)
# =============================================================================
# Ao fim da sessão: se houve mudanças e ainda não sintetizou, força UMA rodada
# de síntese (decision:block) instruindo /ingerir a destilar aprendizados
# duráveis no vault correspondente ao cwd (resolvido por wiki-detect.sh).
# Sem vault → wiki pessoal (fallback).
#
# Guardas anti-loop: respeita stop_hook_active; só bloqueia 1x/sessão (grava
# report marker que zera o gatilho).
#
# Knobs (env): LIBRARIAN_MIN_CHANGES (default 1), LIBRARIAN_AUTOINGEST ("0" off).
# =============================================================================
set -euo pipefail

MIN_CHANGES="${LIBRARIAN_MIN_CHANGES:-1}"
AUTOINGEST="${LIBRARIAN_AUTOINGEST:-1}"

JQ=$(command -v jq || echo /usr/bin/jq)
INPUT=$(cat)

# jq ausente — marcador mínimo no fallback, sem síntese
if [ ! -x "$JQ" ]; then
  FB="$HOME/vaults/conhecimento-pessoal/wiki/meta/inbox"
  mkdir -p "$FB"
  echo "{\"type\":\"session_end\",\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"session\":\"unknown\",\"changes_count\":0,\"has_report\":false}" \
    > "$FB/$(date -u +%Y%m%d-%H%M%S)-session-end.json"
  exit 0
fi

# Vault-aware: resolve pelo cwd do evento
CWD=$(echo "$INPUT" | "$JQ" -r '.cwd // empty')
eval "$(bash "$HOME/.claude/hooks/wiki-detect.sh" "$CWD" 2>/dev/null || true)"
WIKI_ROOT="${WIKI_ROOT:-$HOME/vaults/conhecimento-pessoal/wiki}"
INBOX="${WIKI_INBOX:-$WIKI_ROOT/meta/inbox}"
mkdir -p "$INBOX"

STOP_ACTIVE=$(echo "$INPUT" | "$JQ" -r '.stop_hook_active // false')
SESSION_ID=$(echo "$INPUT" | "$JQ" -r '.session_id // "unknown"')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TIMESTAMP_FILE=$(date -u +"%Y%m%d-%H%M%S")
SESSION_SHORT="${SESSION_ID:0:12}"

# Quantas mudanças esta sessão fez (neste vault)
CHANGES_FILE="$INBOX/changes.jsonl"
CHANGE_COUNT=0
if [ -f "$CHANGES_FILE" ]; then
  # `grep -c` já imprime 0 e sai 1 quando não casa; o `|| echo 0` acrescentava um
  # SEGUNDO zero, e `CHANGE_COUNT` virava "0\n0" — que quebrava a comparação
  # numérica com "integer expression expected" em toda sessão sem mudanças. O
  # bloco de síntese caía fora por erro, não por decisão. `tr -d` normaliza.
  # `|| true` é obrigatório e não é paranoia: com `set -euo pipefail` (linha 15),
  # o `grep -c` que não casa nada sai 1 — mesmo imprimindo "0" — o pipefail
  # propaga, o set -e mata o script aqui, e o Stop hook morre com exit 1 sem
  # stderr nenhum. O efeito era o marcador de fim de sessão (linha ~79) nunca
  # ser gravado em NENHUMA sessão sem mudanças naquele vault. O sintoma no
  # terminal era só "Failed with non-blocking status code", que não aponta nada.
  CHANGE_COUNT=$( { grep -c "\"session\":\"$SESSION_SHORT\"" "$CHANGES_FILE" 2>/dev/null || true; } | tr -dc '0-9')
  CHANGE_COUNT="${CHANGE_COUNT:-0}"
fi

# Já sintetizou nesta sessão?
HAS_REPORT="false"
for f in "$INBOX"/*-report.md; do
  [ -f "$f" ] || continue
  if grep -q "$SESSION_SHORT" "$f" 2>/dev/null; then HAS_REPORT="true"; break; fi
done

# Síntese forçada (1x): mexeu, não sintetizou, não é re-loop
if [ "$AUTOINGEST" = "1" ] && [ "$STOP_ACTIVE" = "false" ] \
   && [ "$HAS_REPORT" = "false" ] && [ "$CHANGE_COUNT" -ge "$MIN_CHANGES" ]; then
  REASON="Antes de encerrar: esta sessão fez $CHANGE_COUNT mudança(s). Faça UMA síntese enxuta de aprendizado via /ingerir:
1. Leia $INBOX/changes.jsonl e filtre as entradas desta sessão ($SESSION_SHORT).
2. Rode /ingerir SOMENTE se houver aprendizado DURÁVEL (decisão de arquitetura, descoberta, padrão, correção não-óbvia). Ignore edits triviais/temporários.
3. CLASSIFIQUE CADA APRENDIZADO PELO CONTEÚDO, não pelo diretório desta sessão. A pergunta é: 'isto ainda vale se eu sair desta empresa amanhã?' Se vale (padrão, armadilha, ofício) → vault pessoal. Se morre com o sistema (host, ADR, topologia, cliente) → vault da empresa. Se vale dos dois jeitos → DUAS páginas com recortes diferentes, linkadas. Nada sensível (IP de cliente, credencial, contrato, dado de pessoa) cruza para o pessoal. Na dúvida entre 'só empresa' e 'os dois', escolha os dois. O cwd é pista, não decisão.
4. Se nada for durável, NÃO escreva páginas — apenas registre o report marker.
5. Ao terminar, grave $INBOX/${TIMESTAMP_FILE}-report.md contendo a linha 'session: $SESSION_SHORT' + 1-3 bullets do que foi (ou não) ingerido, dizendo em qual vault cada coisa entrou.
Seja breve — economia de tokens. Tudo em português brasileiro."
  "$JQ" -n --arg r "$REASON" '{"decision":"block","reason":$r}'
  exit 0
fi

# Caso normal — grava marcador e sai
cat > "$INBOX/${TIMESTAMP_FILE}-session-end.json" << EOF
{
  "type": "session_end",
  "ts": "$TIMESTAMP",
  "session": "$SESSION_SHORT",
  "vault": "${WIKI_VAULT_ID:-pessoal}",
  "changes_count": $CHANGE_COUNT,
  "has_report": $HAS_REPORT
}
EOF

exit 0
