#!/usr/bin/env bash
# Teste do review-voice-guard: assinatura de IA bloqueia, citação técnica passa,
# terceira pessoa só bloqueia quando OWNER_NAME está declarado.
#
#   ./test-review-voice-guard.sh
#
# Sai 0 se tudo passar, 1 no primeiro caso que falhar.
set -uo pipefail
GUARD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/review-voice-guard.sh"
[ -x "$GUARD" ] || { echo "guard não executável: $GUARD"; exit 1; }

pass=0; fail=0

# Roda o guard e devolve "deny" ou "allow".
# O guard nega por EXIT CODE 2 + mensagem no stderr, não por JSON no stdout —
# checar o stdout devolvia "allow" para tudo, inclusive para o que ele bloqueia.
check() {
  local cmd="$1" owner="${2:-}" rc
  printf '%s' "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":$(printf '%s' "$cmd" | jq -Rs .)}}" \
    | OWNER_NAME="$owner" REVIEW_VOICE_GUARD=1 bash "$GUARD" >/dev/null 2>&1
  rc=$?
  [ "$rc" = 2 ] && echo deny || echo allow
}

t() {
  local nome="$1" esperado="$2" cmd="$3" owner="${4:-}"
  local got; got=$(check "$cmd" "$owner")
  if [ "$got" = "$esperado" ]; then
    printf '  ✔ %s\n' "$nome"; pass=$((pass+1))
  else
    printf '  ✘ %s — esperado %s, veio %s\n' "$nome" "$esperado" "$got"; fail=$((fail+1))
  fi
}

echo "Faixa 1 — assinatura inequívoca deve NEGAR"
t "Co-Authored-By"      deny 'gh pr comment 1 --body "fix\n\nCo-Authored-By: Claude <a@b>"'
t "Generated with"      deny 'gh pr comment 1 --body "Generated with Claude Code"'
t "Gerado por"          deny 'gh pr comment 1 --body "Gerado por IA"'
t "link claude.ai"      deny 'gh pr comment 1 --body "veja https://claude.ai/code"'
t "assinatura no fim"   deny 'gh pr comment 1 --body "achado aqui -- Claude"'

echo "Faixa 2 — citação técnica legítima deve PASSAR"
t "nome de plugin"      allow 'gh pr comment 1 --body "instale claude-plugins-official"'
t "caminho de setup"    allow 'gh pr comment 1 --body "o hook vive em ~/.claude/hooks/"'
t "id de modelo"        allow 'gh pr comment 1 --body "roda em claude-opus-5"'

echo "Terceira pessoa — só com OWNER_NAME declarado"
t "sem OWNER_NAME"      allow 'gh pr comment 1 --body "o fulano pediu esse ajuste"'
t "com OWNER_NAME"      deny  'gh pr comment 1 --body "o fulano pediu esse ajuste"'  fulano
t "aspa antes do nome"  deny  'gh pr comment 1 --body "o fulano quer isso"'          fulano
t "outra pessoa passa"  allow 'gh pr comment 1 --body "o joao pediu esse ajuste"'    fulano

echo "Escopo — só comandos que publicam"
t "gh mencionado numa string" allow 'echo "rode gh pr comment com Co-Authored-By"'
t "comando que não publica"   allow 'git commit -m "Co-Authored-By: Claude"'

printf '\n%s passou, %s falhou\n' "$pass" "$fail"
[ "$fail" = 0 ]
