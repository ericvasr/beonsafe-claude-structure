Ingere a fonte fornecida nos seus wikis de conhecimento. Pipeline global — funciona em qualquer vault marcado com `.wikiconfig.json`. **O vault de destino é decidido pelo conteúdo de cada aprendizado, nunca pelo diretório onde a sessão rodou.**

Fonte a ingerir: $arguments

## 0. Resolver o contexto (SEMPRE primeiro)

```bash
eval "$(bash ~/.claude/hooks/wiki-detect.sh "$PWD")"
echo "Vault do cwd: $WIKI_VAULT_ID"
echo "  pessoal: $WIKI_VAULT_PESSOAL"
echo "  empresa: $WIKI_VAULT_EMPRESA"
```

`WIKI_VAULT_ID`/`WIKI_ROOT`/`WIKI_RAW`/… descrevem o vault **sugerido pelo cwd** — é uma pista, não a decisão. `WIKI_VAULT_PESSOAL` e `WIKI_VAULT_EMPRESA` dão as duas raízes, e você vai escrever em uma, na outra, ou nas duas, conforme a §3.

Para cada vault que for usar, leia o `.wikiconfig.json` da raiz dele para pegar `raw_dirs`, `wiki_dirs` e `derived_graphs` — **eles diferem entre os vaults** (o pessoal tem `projetos-pessoais`, `temas`, `leituras`; o da empresa tem `domains`, `projects`, `patterns`, `entities`). Nunca hardcode caminho. Tudo em pt-BR.

## 1. Ler a fonte

Caminho de arquivo → ler o arquivo. Conteúdo colado → usar o conteúdo. Ler por completo antes de resumir.

## 2. Preservar em raw/ (imutável)

Salvar a fonte **completa** no `raw/` do vault que for dono da fonte — se a fonte é documento da empresa, raw da empresa; se é artigo que eu li, raw do pessoal. Documento inteiro, nunca stub. Raw é fonte da verdade: LLM lê, nunca reescreve depois.

Se a fonte alimentar os dois vaults, ela mora em **um** raw só (o dono), e a página do outro vault referencia por link.

## 3. Classificar cada aprendizado — o passo que decide

Destile 3-5 aprendizados. Para **cada um, separadamente**, responda:

> Este aprendizado ainda vale se eu sair da <sua empresa> amanhã?

| Resposta | Vault | O que a página é |
|---|---|---|
| Vale — é padrão, armadilha, princípio, ofício | **pessoal** | o mecanismo, sem nome de cliente, sem IP, sem credencial |
| Não vale — morre com o sistema | **empresa** | o SSOT: host, versão, ADR, topologia, decisão de negócio |
| Vale dos dois jeitos | **os dois** | duas páginas com recortes diferentes, linkadas |

O terceiro caso é o mais comum e **não é duplicação** — é a mesma matéria em duas lentes. Um incidente de fila em memória gera *"fila em memória não serializa entre processos"* no pessoal (o padrão) e a página do sistema afetado na empresa (host, versão, o que mudou). Escrever só uma das duas perde metade.

Regras que não se negociam:

- **Nada sensível cruza para o pessoal.** IP de cliente, credencial, nome de contrato, dado de pessoa, endpoint interno — ficam só na empresa. Se o padrão precisa de exemplo, anonimize.
- **Aprendizado de ofício não fica preso na empresa.** Se ele sobrevive à troca de emprego, ele vai para o pessoal, mesmo que tenha nascido num incidente de cliente.
- **Na dúvida entre "só empresa" e "os dois", escolha os dois.** Falta de página no pessoal é conhecimento perdido; página a mais é barata.

Confirme a classificação com quem opera antes de escrever — curadoria humana no loop. Mostre a tabela: aprendizado → vault → por quê.

## 4. Escrever a página

Em `<raiz-do-vault>/<wiki_dir>/<slug>.md`, `kebab-case.md`, título em sentence case, na pasta correta dentre as `wiki_dirs` **daquele** vault. Frontmatter:

```yaml
---
title: "..."
domain: <área>
tags: [..]
status: seed | growing | evergreen | deprecated
sources: ["[[...]]"]
related: [[..]], [[..]]
created: YYYY-MM-DD
updated: YYYY-MM-DD
agent: <handle>
---
```

Quando o mesmo aprendizado virar duas páginas, cada uma referencia a outra pelo caminho absoluto do vault vizinho, e diz em uma linha qual é o recorte de lá.

## 5. Propagar (disciplina obrigatória)

- Atualizar as páginas existentes tocadas pela fonte; criar novas para conceitos/projetos/entidades novos.
- **≥2 cross-references** por página (`[[..]]`) — sem página órfã.
- **Contradição** com página existente → callout `> [!contradiction] ... [[página]] §seção`. **Nunca apagar** a claim antiga.
- **Atualização** que revisa afirmação anterior → callout `> [!update] ...`, preservando o histórico.

## 6. Markdown é SSOT; grafos são derivados

O markdown é a **única fonte da verdade**. Se `derived_graphs` daquele vault não for vazio, regenerar essas camadas a partir do markdown **depois** de escrever — nunca editá-las como fonte primária. Se a camada declarada não existir mais (config velha), diga isso em vez de tentar regenerar o que não existe.

## 7. Fechar o ciclo, em cada vault que recebeu escrita

```bash
python3 ~/.claude/hooks/wiki-reindex.py "<raiz-do-vault>"
printf '\n## [%s] ingestão | <Título da fonte>\n' "$(date +%F)" >> "<raiz>/<log>"
```

Escreveu nos dois? Roda nos dois. O reindex reconstrói o catálogo entre marcadores `AUTOINDEX` (curadoria fora deles é preservada). O log é append-only, prefixo greppável `## [YYYY-MM-DD] ingestão | ...`.

Lembrar: absolutamente tudo em pt-BR.
