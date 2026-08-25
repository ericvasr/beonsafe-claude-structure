#!/usr/bin/env bash
# =============================================================================
# review-voice-guard.sh — comentário de review sai na minha voz, ou não sai
# =============================================================================
# Hook PreToolUse em Bash. Intercepta o comando que PUBLICA comentário (gh pr
# comment, gh pr review, gh issue comment, gh api .../comments) e nega quando o
# corpo carrega assinatura de ferramenta ou etiqueta de IA.
#
# Existe porque a exigência estava só em prosa — no CLAUDE.md e no texto do
# code-review-gate. Prosa é sugestão: o comando do plugin oficial de code review
# manda "🤖 Generated with Claude Code" no rodapé por instrução dele mesmo, e
# regra escrita não segura isso. O gate precisa estar na ferramenta que executaria
# a violação, no instante em que ela sairia.
#
# Duas faixas, de propósito:
#   NEGA  — assinatura inequívoca (Co-Authored-By, "Generated with", 🤖,
#           claude.ai/code, "-- Claude", e o dono da voz em terceira pessoa
#           (esta última só quando OWNER_NAME estiver declarado).
#   AVISA — menção solta a claude/IA/AI, que pode ser citação técnica legítima
#           ("o plugin code-review@claude-plugins-official assina o rodapé").
#           Negar isso daria falso positivo em review de código sobre o próprio
#           setup, que é justamente onde eu mais reviso.
#
# Falha interna = deixa passar (exit 0). Guard quebrado não pode travar review.
# Env: REVIEW_VOICE_GUARD=0 desliga (ainda loga).
# =============================================================================
set -uo pipefail

LOG="$HOME/.claude/logs/review-voice-guard.jsonl"
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true

PAYLOAD=$(cat 2>/dev/null || true)
CMD=$(printf '%s' "$PAYLOAD" | python3 -c \
  "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" \
  2>/dev/null || true)

log() { printf '{"ts":"%s","decision":"%s","why":%s,"cmd":%s}\n' \
  "$(date -Is)" "$1" \
  "$(python3 -c 'import json,sys;print(json.dumps(sys.argv[1]))' "$2" 2>/dev/null || echo '""')" \
  "$(python3 -c 'import json,sys;print(json.dumps(sys.argv[1][:400]))' "$CMD" 2>/dev/null || echo '""')" \
  >> "$LOG" 2>/dev/null || true; }

[ "${REVIEW_VOICE_GUARD:-1}" = "0" ] && { log allow "guard desligado"; exit 0; }
[ -z "$CMD" ] && exit 0

# Só interessa comando que publica texto para fora — e `gh` tem que ser o COMANDO,
# não uma substring qualquer. Casar por substring interceptava todo script ou doc
# que apenas mencionasse `gh pr comment` dentro de uma string; aconteceu no primeiro
# teste deste guard, que bloqueou a si mesmo. Início de linha ou depois de ; && || |.
printf '%s' "$CMD" | grep -qE '(^|[;&|]([[:space:]]*))gh[[:space:]]+(pr[[:space:]]+(comment|review|create)|issue[[:space:]]+(comment|create)|api[^|;&]*comments)' \
  || exit 0

# O corpo pode vir em --body/-b inline ou num arquivo via --body-file/-F. Junta
# os dois: checar só a linha de comando deixaria passar todo o caminho de arquivo.
BODY="$CMD"
for f in $(printf '%s\n' "$CMD" | grep -oE '(--body-file|-F)[= ]+[^ ]+' | sed -E 's/^(--body-file|-F)[= ]+//' || true); do
  [ -f "$f" ] && BODY="$BODY
$(cat "$f" 2>/dev/null || true)"
done

# Normaliza caixa e espaço. Tira os identificadores TÉCNICOS que contêm "claude"
# e são nome de coisa, não assinatura — caminho do meu setup, id de modelo, nome
# de plugin. Sem isso, todo review sobre ~/.claude bateria no guard.
N=$(printf '%s' "$BODY" | tr '[:upper:]' '[:lower:]' | tr -s '[:space:]' ' ' \
  | sed -E 's#~?/?\.claude[a-z0-9_/.-]*##g; s#claude-(code|plugins|opus|sonnet|haiku|fable)[a-z0-9_.-]*##g')

deny() {
  log deny "$1"
  cat >&2 <<EOF
BLOQUEADO pelo review-voice-guard: $1

Comentário de review sai na minha voz, primeira pessoa, sem assinatura de
ferramenta. Sem "Co-Authored-By", sem "Generated with", sem 🤖, sem link para
claude.ai, sem me citar em terceira pessoa.

Reescreva o corpo e publique de novo. O achado é meu; quem escreve sou eu.
EOF
  exit 2
}

# Faixa 1 — assinatura inequívoca. Errada em qualquer contexto.
case "$N" in
  *co-authored-by*)                      deny "trailer Co-Authored-By no corpo" ;;
  *generated\ with*|*generated\ by*)     deny '"Generated with/by" no corpo' ;;
  *gerado\ com*|*gerado\ por*)           deny '"Gerado com/por" no corpo' ;;
  *🤖*)                                  deny "emoji de robô como etiqueta de IA" ;;
  *claude.ai*)                           deny "link para claude.ai no corpo" ;;
  *--\ claude*|*—\ claude*|*by\ claude*) deny "assinatura de Claude no fim do corpo" ;;
  *ai\ assistant*|*assistente\ de\ ia*)  deny "auto-identificação como assistente de IA" ;;
  *ai-generated*|*gerado\ por\ ia*)      deny "etiqueta ai-generated" ;;
esac

# Terceira pessoa — só checa se você declarar quem é o dono da voz.
#
#   export OWNER_NAME=seunome     # no shell, ou no env do settings.json
#
# Sem OWNER_NAME o bloco é pulado: um guard que não sabe o seu nome não tem como
# saber que "o fulano pediu" é uma auto-citação, e chutar daria falso positivo em
# qualquer comentário que mencione uma pessoa.
#
# A fronteira precisa ser de PALAVRA, não de espaço literal: `--body "o Fulano
# pediu..."` tem uma aspa antes do "o", e o padrão com espaço passava batido. Por
# isso a pontuação vira espaço aqui — e só aqui, porque os padrões acima dependem
# de `.`, `-` e `/` (claude.ai, co-authored-by, claude.ai/code).
OWNER="$(printf '%s' "${OWNER_NAME:-}" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' ' ' | tr -s ' ')"
OWNER="${OWNER# }"; OWNER="${OWNER% }"
if [ -n "$OWNER" ]; then
  NW=" $(printf '%s' "$N" | tr -c '[:alnum:]' ' ' | tr -s ' ') "
  case "$NW" in
    *" o $OWNER "*|*" do $OWNER "*|*" ao $OWNER "*|*" com o $OWNER "*|*" pelo $OWNER "*|\
    *" $OWNER pediu "*|*" $OWNER quer "*|*" $OWNER aprovou "*)
      deny "me citando em terceira pessoa" ;;
  esac
fi

# Faixa 2 — menção solta. Pode ser citação técnica legítima, então avisa e passa.
case "$N" in
  *claude*|*\ ia\ *|*\ ai\ *|*assistente*)
    log warn "menção solta a IA no corpo"
    python3 - <<'PY'
import json
print(json.dumps({"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":
"review-voice-guard: o corpo deste comentário menciona Claude/IA. Se for citação técnica "
"(nome de plugin, caminho, id de modelo), siga. Se for assinatura, auto-referência ou "
"etiqueta de quem escreveu, reescreva antes de publicar: o achado sai na minha voz, "
"primeira pessoa, sem rodapé de ferramenta."}}))
PY
    exit 0 ;;
esac

log allow "voz limpa"
exit 0
