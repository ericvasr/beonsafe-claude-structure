# Precedência e autoconfiguração

Este documento descreve como o Claude que roda sob este setup deve se orientar: qual regra vence em caso de conflito, e como ele aprende o padrão deste repo sem depender de explicação manual a cada sessão.

## `CLAUDE.md` conduz

O `CLAUDE.md` global (na raiz deste repo, ou o equivalente do usuário em `~/.claude/CLAUDE.md`) é a **camada de condução primária** de toda sessão. Em qualquer conflito com CLAUDE.md de projeto, plano, template, skill, agente ou commit anterior, **o global vence** — salvo:

1. ordem direta e explícita do usuário na conversa em curso, ou
2. política enterprise.

Um CLAUDE.md de **projeto** só *adiciona* contexto local (paths, stack, convenções do repo daquele projeto específico); ele nunca revoga uma regra global (atribuição em commits, gate de licença, premissa de `front`, uso do squad, economia de tokens). Se um arquivo de menor nível contradizer o global, a regra é seguir o global e **sinalizar o conflito** ao usuário — não silenciar a divergência.

**Nota mecânica:** o harness do Claude Code carrega o CLAUDE.md de projeto por cima do global na ordem de arquivos (o de projeto aparece "depois" no contexto). Isso é só ordem de merge de arquivos — a superioridade do global descrita acima é por **instrução explícita**, não pela ordem em que os arquivos chegam. Tratar como regra dura mesmo quando a ordem de carregamento sugerir o contrário.

## Regras que o global fixa (resumo)

- **Atribuição**: nunca `Co-Authored-By: Claude` (ou variação atribuindo coautoria a IA) em commits, PRs, comentários de código, changelogs, releases ou qualquer artefato versionado — mesmo que um exemplo, template ou commit anterior sugira o contrário.
- **Gate de licença**: obrigatório antes de ingerir código de terceiros; delega a classificação ao `security-auditor`; ver `docs/policies.md`.
- **`front` como premissa de UI**: qualquer tarefa de interface aciona o skill de design antes de escrever código — motion, os cinco estados de dado (empty/loading/error/success/disabled) e acessibilidade não são opcionais.
- **Agentes especializados**: Claude despacha o agente certo por conta própria quando a tarefa cai no domínio dele — não espera o usuário pedir explicitamente; ver `docs/agents.md`.
- **Economia de tokens**: minimalismo de código em sessão de código, prosa terse em sessão de prosa — nunca os dois trocados, ou o ganho vira perda.
- **Medir antes de opinar**: afirmação sobre estado de produção exige comando, não repo, doc ou memória. Os cinco agentes de `agents/operacao/` são acionados sem pedir permissão quando aparecer "provavelmente", duas hipóteses sem evidência entre elas, ou a mesma discussão pela terceira vez. Ver `docs/premissas-agentes-operacionais.md`.
- **Nomear o ponto cego do instrumento**: antes de dizer "medi", dizer em uma linha qual pergunta o comando responde e qual ele não responde. Se a conclusão for "ausência", exigir controle positivo na mesma rodada.
- **Baseline de segurança de API**: premissa de desenho, não revisão posterior. Ausência de item é achado com severidade. Ver `docs/baseline-seguranca-api.md`.
- **Autenticação não se experimenta em produção**: mudança em login, IdP ou header de gateway só entra com a reversão já executada num descartável.

## As três camadas de conhecimento

Onde cada coisa mora, e por quê:

| Camada | O que guarda | Alcance | Vida |
|---|---|---|---|
| **Wiki** (`/ingerir`) | padrão, decisão, incidente, arquitetura, o porquê | os dois vaults, versionado | permanente |
| **`CLAUDE.md`** | como trabalhar: regra, correção, preferência | toda sessão, qualquer diretório | permanente |
| **`memory/`** | fato operacional: host, caminho, estado corrente | **só naquele diretório** | enquanto o projeto viver |

A memória de arquivo é **por diretório de trabalho**: são escopos que não se enxergam, e
uma regra salva num deles fica invisível nos outros. Por isso ela não é o lugar do
conhecimento — fragmenta por construção.

O fim de sessão é automático: o librarian bloqueia o `Stop` e força a síntese. O começo
**não** é — o `session-brief` só avisa que existe página. Ver o aviso é o gatilho para
rodar `/consultar <tema>` antes da primeira edição. Essa assimetria é onde o setup mais
falha na prática.

## Como Claude se autoconfigura neste padrão

Quando este repo (ou uma cópia dele) está presente no ambiente de trabalho, Claude não precisa que o usuário explique o setup a cada sessão — ele se orienta lendo, nesta ordem de prioridade:

1. **`CLAUDE.md`** — as regras de condução primária (ver acima).
2. **`docs/agents.md`, `docs/skills.md`, `docs/hooks.md`, `docs/policies.md`** (este diretório) — o que existe, quando cada peça é acionada, e como as peças se relacionam entre si.
3. **`DEPENDENCIES.md`** — o que é de terceiros, e onde instalar a partir da fonte oficial (este repo não redistribui skills/plugins de terceiros).
4. O conteúdo real de `agents/`, `skills/`, `hooks/`, `policies/` — a fonte de verdade final para frontmatter, `description`, `tools` e lógica de cada peça, caso a documentação em `docs/` fique desatualizada.

Ou seja: os arquivos em `docs/` são a **camada de leitura rápida** — o que Claude consulta primeiro para decidir "qual agente/skill/hook se aplica aqui" sem precisar reler o corpo inteiro de cada arquivo fonte. Em caso de divergência entre `docs/` e o conteúdo real de `agents/`/`skills/`/`hooks/`/`policies/`, o conteúdo real vence — `docs/` deve ser atualizado para refletir a fonte, nunca o contrário.
