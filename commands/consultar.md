Consulta o seu wiki de conhecimento (detecção automática de vault) sobre o tema/pergunta e sintetiza uma resposta.

Consulta: $arguments

## 0. Resolver o vault

```bash
eval "$(bash ~/.claude/hooks/wiki-detect.sh "$PWD")"
```

Usa `WIKI_INDEX`, `WIKI_ROOT`, `WIKI_LOG`, `WIKI_LANG`. Se o vault tiver `graphify` em `derived_graphs` e existir `graphify-out/graph.json`, preferir `graphify query "<pergunta>"` antes de varrer o index (subgrafo escopado, mais barato).

## Passos

1. Ler `$WIKI_INDEX` para identificar as páginas potencialmente relevantes (o catálogo `AUTOINDEX` está sempre atual).
2. Ler as páginas identificadas.
3. Sintetizar resposta no idioma do vault (`WIKI_LANG`, pt-BR):
   - Resposta direta.
   - Citações com links Obsidian `[[página]] §seção`.
   - Conexões entre os temas.
4. Se a resposta for síntese valiosa (análise/comparação/padrão), oferecer salvar como nova página no `wiki_dir` adequado do vault (ex.: `temas/` no pessoal, `patterns/` no operacional) — o valor das explorações **compõe** no wiki, não some no chat. Ao salvar, rodar `python3 ~/.claude/hooks/wiki-reindex.py "$PWD"` e logar em `$WIKI_LOG`.
5. Se revelar lacuna, mencionar e oferecer `/ingerir` de novas fontes.

Responder sempre no idioma do vault (pt-BR).
