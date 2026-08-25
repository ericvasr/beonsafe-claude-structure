Revisão completa (lint) do seu wiki de conhecimento, com detecção automática de vault.

## 0. Resolver o vault

```bash
eval "$(bash ~/.claude/hooks/wiki-detect.sh "$PWD")"
```

Usa `WIKI_INDEX`, `WIKI_ROOT`, `WIKI_LOG`, `WIKI_LANG`.

## 1. Sanear o index primeiro (barato, determinístico)

```bash
python3 ~/.claude/hooks/wiki-reindex.py "$PWD"
```

Reconstrói o catálogo `AUTOINDEX` a partir do frontmatter — resolve de cara "index defasado" e "página no index que não existe". A curadoria fora dos marcadores é preservada.

## 2. Escanear `$WIKI_ROOT` e reportar

**Estruturais:**
- Páginas órfãs (sem nenhum `[[link]]` inbound).
- Links quebrados (`[[página]]` sem arquivo alvo).
- Frontmatter incompleto/incorreto (campos faltando, datas, status).

**Conteúdo:**
- Contradições entre páginas (devem estar em callout `> [!contradiction]`, não apagadas).
- Claims desatualizados por fontes mais recentes.
- Conceitos citados em 2+ páginas sem página própria.
- Páginas `seed` sem atualização há 30+ dias; projetos/metas parados.

**Oportunidades:**
- Lacunas preenchíveis por pesquisa/nova fonte.
- Cross-refs que deveriam existir e não existem.
- Perguntas novas a explorar.

## 3. Fechar

- Relatório organizado por categoria, no idioma do vault (`WIKI_LANG`, pt-BR).
- Perguntar o que resolver agora.
- Logar: `printf '\n## [%s] lint | N problemas, N oportunidades\n' "$(date +%F)" >> "$WIKI_LOG"`.
