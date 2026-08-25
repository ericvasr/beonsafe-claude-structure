# Dependências de terceiros

> **Estes componentes NÃO estão neste repositório. Instale cada um a partir da sua origem oficial abaixo.**
>
> Este repo documenta como configurar um setup de Claude Code (agentes, hooks, policies, skills próprias). Ele **não redistribui** código de terceiros — plugins e skills de terceiros devem ser instalados diretamente do projeto original, sob a licença dele.

## Tabela

| Nome | O que faz | Origem/upstream | Licença | Como instalar (fonte oficial) |
|---|---|---|---|---|
| **superpowers** | Plugin de metodologia de desenvolvimento para agentes de código: brainstorming, writing-plans, subagent-driven-development, TDD, systematic-debugging, code review, etc. | [github.com/obra/superpowers](https://github.com/obra/superpowers) (marketplace `claude-plugins-official`, autor Jesse Vincent) | MIT | No Claude Code: `/plugin marketplace add anthropics/claude-plugins-official` seguido de `/plugin install superpowers`. Ou clone o repo e siga o README para outros hosts (Codex, Cursor, OpenCode etc). |
| **front** | Skill de design/frontend: orquestra fases de entendimento → auditoria → referências → arquitetura → criação → verificação para UI, com dials de motion/densidade e QA via Playwright. | Meta-skill que integra várias fontes distintas (não tem upstream único): [pbakaus/impeccable](https://github.com/pbakaus/impeccable) (Apache-2.0, baseado no `frontend-design` da Anthropic), [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill), [alchaincyf/huashu-design](https://github.com/alchaincyf/huashu-design), [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill), e o plugin oficial Playwright (ver abaixo) | MIT (composição); cada fonte integrada mantém a própria licença — conferir cada repo antes de redistribuir | Instale cada projeto-fonte listado ao lado a partir do repositório dele e componha localmente conforme sua necessidade; não há um único pacote "front" oficial para instalar de uma fonte central. |
| **graphify** | Transforma qualquer pasta (código, docs, papers, imagens, vídeo) num knowledge graph navegável: `graphify query`, `graphify path`, `graphify explain`, relatório e visualização HTML. | [github.com/safishamsi/graphify](https://github.com/safishamsi/graphify) (também referenciado como `Graphify-Labs/graphify`; pacote PyPI `graphifyy`) | Dual: Apache-2.0 e MIT (repo traz `LICENSE` e `LICENSE-MIT`) | `uv tool install graphifyy` (ou `pipx install graphifyy`), depois `graphify install` para registrar a skill no agente. Em seguida, `/graphify .` no Claude Code. |
| **ponytail** | Skill de minimalismo de código: força a solução mais simples que funciona (YAGNI, stdlib antes de dependência, reuso antes de reescrever). Níveis lite/full/ultra. | [github.com/DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | MIT | `/plugin marketplace add DietrichGebert/ponytail` e depois `/plugin install ponytail@ponytail` (enviar como dois prompts separados). |
| **caveman** | Modo de comunicação ultra-comprimida (prosa terse), níveis lite/full/ultra e variantes wenyan (文言文). Reduz tokens de saída mantendo o conteúdo técnico. | [github.com/JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | MIT | Instale como plugin Claude Code, extensão Codex/Gemini CLI, ou regra de agente (Cursor/Windsurf/Cline/Copilot) seguindo o README do repo oficial. |
| **Playwright MCP** | Servidor MCP de automação de browser: navegação, screenshot, clique, preenchimento de formulário, snapshot de acessibilidade, para QA de interfaces e testes E2E. | [github.com/microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp) (pacote npm `@playwright/mcp`, autor Microsoft) | Apache-2.0 | Via Claude Code: `/plugin marketplace add anthropics/claude-plugins-official` + `/plugin install playwright`. Ou manualmente, registre o servidor MCP com `npx @playwright/mcp@latest`. |
| **scrollcraft** (`nateherk-design`) | Skill de landing page dirigida por scroll: vídeo que scrubba, seções que pinam, trilhos laterais, assinatura de movimento por build. Engine vanilla próprio, sem framework. | [github.com/nateherkai/scroll-craft](https://github.com/nateherkai/scroll-craft) | MIT | `/plugin marketplace add nateherkai/scroll-craft` + `/plugin install nateherk-design@nateherk`. **Antes de instalar, leia a nota abaixo.** |
| **Strix** | Pentest autônomo: agentes que atacam o alvo rodando e só reportam achado com PoC que funciona. Perna dinâmica do `security-auditor`. | [github.com/usestrix/strix](https://github.com/usestrix/strix) | Apache-2.0 | Skills instaláveis direto. O CLI, quando necessário: `pipx install strix-agent` — **nunca** o `curl \| bash` que o upstream sugere. |

## Notas

- Licenças e URLs acima foram confirmadas inspecionando os manifestos/metadados das cópias instaladas localmente (`.claude-plugin`, `package.json`, `LICENSE`, `SKILL.md`) e cruzando com os repositórios oficiais publicados. Nenhum dado foi assumido sem essa checagem.
- `front` é uma composição local que integra múltiplos projetos de terceiros — não existe um único pacote oficial "front" para instalar; instale as fontes listadas e adapte conforme a licença de cada uma.
- Antes de instalar qualquer dependência de terceiros, revise a licença upstream e a política de licenças do seu projeto.

---

## Nota sobre o scrollcraft

O gate de licença passou: MIT limpa, sem `postinstall`, sem dependência externa nos
scripts (só builtins `node:`), sem binário commitado, sem ofuscação e sem telemetria.

O que a leitura levantou, e vale saber antes de instalar:

- **Repo novo.** Criado em agosto de 2026, autor único, poucos commits e changelog em
  movimento. Instalar apontando para `main` significa aceitar atualização silenciosa de
  ~100KB de instrução que o agente obedece, com `allowed-tools: Bash` sem restrição.
  Atualização de markdown é o vetor, não o `.js`.
- **`scripts/kie.mjs` sobe imagem de referência para um CDN de terceiro**
  (`kieai.redpandaai.co`) e usa a URL pública devolvida. Para asset de marca, tudo bem.
  Para screenshot de ambiente interno, tela de produto ou documento — não passe por ali.
- **`scripts/serve.mjs` escuta em `0.0.0.0`** e checa a raiz por prefixo de string, o que
  deixa escapar para diretório irmão. Sozinho cada um é ruído; juntos, alguém na mesma
  rede lê a pasta vizinha enquanto você verifica uma página. Dois consertos de uma linha
  cada, se for rodar o servidor de verificação.

Se o produto gerado for entregue a cliente com o `engine/scrollcraft.js` no bundle, esse
engine é código MIT sendo **distribuído**: o aviso de copyright precisa ir junto no
artefato. A página em si (HTML, copy, assets) é sua — a MIT não contamina a saída da
ferramenta, só o código dela que viaja junto.
