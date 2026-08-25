# Agentes

Os 16 agentes vivem em `agents/`, organizados em cinco famílias, e ficam disponíveis em
**toda interação** — não só via `/squad`. Quem decide quando acioná-los é o próprio
Claude, lendo a `description` de cada um e casando com o domínio da tarefa.

## Como o dispatch funciona

1. Claude lê a tarefa em andamento.
2. Casa o domínio com a `description` de um dos agentes.
3. Despacha via Agent tool com `subagent_type: <name do frontmatter>`.
4. Se a tarefa cruzar domínios, `/squad` orquestra vários em paralelo sobre a mesma
   tarefa, com síntese e review cruzado.

O `name` do frontmatter é o endereço. Subpasta é organização para humano — o Claude
resolve pelo nome, não pelo caminho.

## As cinco famílias

### `agents/infra/` — infra e segurança

| Agente | Domínio | Detalhe que muda o uso |
|---|---|---|
| `security-auditor` | OWASP, secrets, hardening, threat model, OWASP LLM Top 10 | Executa o **gate de licença obrigatório** antes de qualquer ingestão de código de terceiro. Veredicto `BLOCK` interrompe até override explícito e registrado |
| `infra-sre` | Servidor, rede, container, K8s como runtime, IaC, observabilidade | Analisa e recomenda; **não mede produção** — isso é da família operação |
| `devops-pipeline` | Actions, runner, Docker, compose, PM2, systemd, deploy, segredo | É o par **construtor** do `esteira-gate`: o gate mede, este conserta |

### `agents/dev/` — desenvolvimento

| Agente | Domínio | Detalhe que muda o uso |
|---|---|---|
| `dev-fullstack` | Arquitetura, refactor, testes, performance, revisão | O generalista da família |
| `api-designer` | Contrato de endpoint, versionamento, idempotência, paginação | Entra **antes** do handler. Mudar resposta de endpoint existente é quebra de contrato, não refactor |
| `db-expert` | Schema, chave, índice, plano de query, migration, deadlock | **Read-only em produção por trava de `PreToolUse`**. Desenha a migration, não a aplica |
| `domain-modeler` | Invariante, máquina de estados, vocabulário do domínio | Entra quando a regra tem exceção, ou o mesmo conceito tem dois nomes no código |
| `test-engineer` | O que testar e em que nível, flaky, suíte lenta | Não persegue percentual de cobertura — persegue o teste que quebra quando a regra quebra |

### `agents/front/` — frontend

| Agente | Quando | Detalhe |
|---|---|---|
| `front-scout` | **Antes** da primeira linha de UI | Busca cada referência de verdade (WebFetch, Playwright). Descrição de memória não conta |
| `front-critic` | **Antes** de dar a tela por pronta | Screenshot em 3 viewports, Stranger Test, catálogo de anti-patterns. Não conserta: mede e devolve a lista |

### `agents/operacao/` — medem produção

Os cinco são **read-only por trava de hook**, têm caminho fixo de saída, e entregam
veredicto com o comando que o sustenta ao lado. As premissas estão em
`docs/premissas-agentes-operacionais.md`.

| Agente | A pergunta |
|---|---|
| `liveness-auditor` | O dado ainda está entrando? Mede último registro por caminho de ingestão, não processo vivo |
| `esteira-gate` | O CI valida o que diz validar? Inventaria o delta entre o que o workflow afirma e o que executa |
| `release-conductor` | O que está pronto e não protege ninguém? Mede o drift prod ↔ main ↔ integration |
| `prod-posture` | O host está exposto? O que só aparece em `docker inspect`, `git status`, `pg_roles` |
| `slo-keeper` | Quanto do orçamento de erro sobrou? Cabe trabalho novo? |

Eles leem `~/.claude/examples/products.json` antes de medir. Enquanto esse arquivo tiver
os produtos de exemplo, eles medem um portfólio que não é o seu.

### `agents/base/` — arquitetura de IA

`ai-architect` — orquestração de LLM, RAG, embeddings, vector DBs, prompt engineering,
frameworks de agente, eval, custo de inferência. Também para projetar e avaliar skills,
agentes e MCP servers.

## Memória de agente

Agentes com `memory: user` no frontmatter têm memória persistente em
`~/.claude/agent-memory/<nome>/`. Ela responde uma pergunta só: **o que mudou desde a
última vez que eu medi?**

Antes de mandar um agente medir de novo, pergunte a ele o que já sabe. Um número isolado
não diz quase nada; o mesmo número comparado com a medição anterior diz tudo.

O que vai para a memória do agente é o **delta** e o comando que funcionou. O que vira
conhecimento durável vai para a wiki — e como os operacionais não têm a tool `Skill`,
eles terminam o relatório com uma seção `## Para a wiki`, e quem chamou faz a ingestão.

## Criar o seu

Domínio específico de negócio (fiscal, jurídico, saúde, logística) merece agente
dedicado: um generalista erra o vocabulário e a regra. Crie em `agents/base/`, com
`description` que diga **quando acionar** — é a `description` que faz o roteamento, não o
corpo do prompt.
