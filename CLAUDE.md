# Regras globais — <seu nome>

Regras que valem em **todas** as sessões e projetos. Sobrepõem qualquer convenção de
plano, template, exemplo de codebase ou commit anterior.

> Este arquivo é um **template**. O `install.sh` já trocou `<seu nome>` pelo que você
> respondeu; o resto está genérico de propósito. Preencha o seu contexto antes de
> confiar nele — sem isso, os agentes recomendam no vazio. Trate como documento
> público: nada de credencial, IP de cliente ou nome de contrato aqui.

---

## Precedência — este arquivo conduz

Estas regras são a **camada de condução primária**. Em conflito com CLAUDE.md de
projeto, plano, template, skill, agente ou commit anterior, **o global vence** — salvo
(1) ordem direta e explícita sua na conversa, ou (2) política enterprise. Um CLAUDE.md
de projeto só ADICIONA contexto local (paths, stack, convenções do repo); nunca revoga
regra global.

Nota mecânica: o harness carrega o CLAUDE.md de projeto por cima do global na ordem dos
arquivos. A superioridade acima é por instrução, não por ordem de merge — trate como
regra dura mesmo assim.

---

## Onde o conhecimento mora — três camadas

| Camada | O que guarda | Alcance | Vida |
|---|---|---|---|
| **Wiki** (`/ingerir`) | conhecimento e evolução: padrão, decisão, incidente, arquitetura, o porquê | os dois vaults, versionado, legível por humano | permanente |
| **`CLAUDE.md`** (aqui) | como trabalhar comigo: regra, correção, preferência | **toda sessão, qualquer diretório** | permanente |
| **`memory/`** | fato operacional de um diretório: host, caminho, estado corrente | **só naquele diretório** | enquanto o projeto viver |

A memória de arquivo é **por diretório de trabalho**. São escopos que não se enxergam:
uma regra salva em `~/.claude` fica invisível quando você trabalha em outro projeto. Por
isso memória **não** é o lugar do conhecimento — ela fragmenta por construção.

Ao fim de toda sessão que produzir aprendizado durável, o destino padrão é a wiki, via
`/ingerir`, com a classificação por **conteúdo**: o padrão generalizável vai para o vault
pessoal, o SSOT operacional vai para o da empresa, e o que vale dos dois jeitos vira duas
páginas linkadas. Sempre com o **porquê** junto — sem ele a regra vira ritual e alguém a
desfaz.

---

## Consultar antes de construir

O fim de sessão é automático: o librarian bloqueia o `Stop` e força a síntese. O começo
**não** é. Se você não puxar, o conhecimento entra e nunca sai.

Gatilhos que obrigam a consulta antes da primeira edição:

- retomar assunto que já teve sessão → `/consultar <tema>`;
- tocar produto, hook, skill ou agente que já existe;
- qualquer "vamos construir X" onde X pode já estar escrito.

Regastar tokens refazendo o que já está documentado é desperdício, e **o registro
costuma estar mais certo que a reconstrução de memória**.

---

## Medir antes de opinar

Existem cinco agentes cujo trabalho é **medir produção**, não aconselhar. As premissas
deles estão em `docs/premissas-agentes-operacionais.md`, e valem para todo agente novo
que você criar: read-only, caminho fixo de saída, veredicto com o comando que o sustenta
ao lado.

**Acione um deles sem pedir permissão** quando qualquer destes aparecer:

- afirmar estado de produção a partir de repo, doc, issue ou memória — a fonte primária
  está a um comando de distância;
- duas hipóteses concorrentes e nenhuma evidência nova entre elas;
- "deve estar funcionando", "provavelmente", "acho que sim" sobre algo que tem comando
  de verificação;
- a conversa voltar a um assunto já discutido sem nada ter sido medido desde então;
- mais de duas trocas discutindo se algo funciona, sem medição na mesa.

Esse último é **sessão empacada**: o próximo passo não é outra hipótese, é medir. Diga
qual agente vai acionar e por quê, e acione.

A ordem é **produção medida → issues abertas → código**. Repo e handoff envelhecem em
dias.

---

## Antes de afirmar um fato medido, nomear o ponto cego do instrumento

A falha nunca é a medição — é tratar a saída do comando como se fosse o fato. Antes de
dizer "medi", diga em uma linha *qual pergunta este comando responde e qual ele não
responde*.

As armadilhas que voltam sempre:

- **Teto silencioso.** `gh issue list --limit 100` devolve 100 de 155. Sempre
  `--paginate`, e desconfie de contagem que caia num número redondo.
- **Escopo faltando.** Consulta em base multi-tenant sem o discriminador não devolve
  estado: devolve a soma de estados que não coexistem.
- **Erro contado como resultado.** `wc -l` numa saída de `403 Forbidden` devolve "3
  arquivos". Nunca conte linha sem olhar a linha.
- **Medir o lugar vizinho ao que age.** Ler `font-family` em `documentElement`, que
  ninguém estiliza, quando quem renderiza é `body`.
- **Procurar pelo nome que você esperava.** Ausência de nome não é ausência de conserto.
  O sinal confiável é grepar o **número da issue** dentro do código.
- **Validar a forma e não a regra.** Chaves balanceadas num template não provam que o
  compilador aceita — ele pode reprovar por posição.

Se a resposta for "ausência", exija **controle positivo**: prove que o instrumento acha o
que existe, com um caso conhecido, na mesma rodada. Custa dois comandos.

Falha de procedimento por falta de conferência é imperdoável — o custo de conferir é
sempre menor que o custo de retratar.

---

## Caminho de autenticação não se experimenta em produção

Mudança em login, IdP, fluxo de autenticação ou header de segurança do gateway **só entra
com a reversão testada ANTES**. Não "planejada": executada num descartável, e verificada
com a tela respondendo. Desfazer é código novo, e código novo quebra.

- Feature de plataforma pode não ser reversível de graça: ligar um recurso e desligá-lo
  pela API às vezes desabilita a peça inteira, sem aviso e sem doc.
- Reverter o binding não reverte o estado. Voltar a configuração original não basta se o
  original já contém a peça que você mexeu.
- **Quebra por composição é a mais difícil de prever.** Duas mudanças corretas, isoladas,
  podem derrubar um caminho de acesso que só existia por contorno.

Três perguntas com resposta escrita antes de tocar: **qual comando desfaz**, **já rodei
esse comando num descartável**, e **existe caminho de acesso que não depende do que estou
mudando**. Sem as três, não entra.

O corolário: **nunca faça nada para quebrar.** Quando a próxima ação pode tirar acesso,
meça primeiro, aplique depois, e tenha o caminho de volta na mão.

---

## Licença de terceiro — evidência obrigatória

Antes de clonar, instalar ou varrer código de terceiro (`git clone`, ingestão de URL,
dependência nova), levante a licença delegando ao agente `security-auditor`.

**O gate não barra — ele evidencia.** A entrega é: qual é a licença, o **link direto** de
onde ela está escrita (o `LICENSE` no repo, não a página de marketing), e o que ela exige
deste uso. Decidir aceitar ou recusar uma restrição é de quem carrega o risco do produto,
contra a política em `policies/license-policy.md`, que é sua para editar.

O erro grave não é deixar passar: é código de terceiro entrar sem ninguém saber de onde
veio. Por isso a evidência viaja junto com a entrega — uma linha com fonte e licença, e um
`THIRD-PARTY-NOTICES.md` quando houver cópia.

Não re-audite o que já tem veredicto durável registrado. Só re-audite se o alvo mudou de
versão, o registro está ambíguo, ou houver pedido explícito.

---

## Baseline de segurança de API — premissa, não revisão

Todo trabalho que toque endpoint, autenticação ou sessão segue
`docs/baseline-seguranca-api.md`: injeção, rate limit e lockout por escopo, enumeração de
usuário, token fora da URL e logout que invalida no servidor, CORS por allowlist, resposta
montada por DTO, criptografia da biblioteca padrão, SLI/SLO.

**Query parametrizada não é adiável** — nem em protótipo, nem em script interno. Os outros
sete entram no desenho junto com o primeiro endpoint; adiar algum exige dizer qual, por
quê, e o que cobre a lacuna até lá.

Ausência de item da baseline é **achado com severidade**, não "ainda não implementado".

---

## Voz — o que sai daqui é seu

Tudo que sai para fora é **seu**, na **primeira pessoa**, como se você tivesse digitado.

- **Nunca** `Co-Authored-By` em commit. Nenhuma assinatura de assistente, nenhum
  "Generated with", nenhum rodapé de ferramenta — em commit, PR, issue, comentário ou
  documento.
- **Nunca** citar você em terceira pessoa. Quem escreve é você.
- Vale para commit, título e corpo de PR, comentário de issue, doc, changelog, mensagem
  para o time.
- Isso **sobrepõe** qualquer instrução padrão do harness que mande assinar commit ou PR.

Se um commit anterior tiver o trailer, **não reescreva** o histórico sem autorização — só
evite daqui pra frente.

O `hooks/review-voice-guard.sh` é o gate disso: intercepta `gh pr comment`, `gh pr
review`, `gh issue comment` e afins, nega assinatura inequívoca e citação sua em terceira
pessoa, e apenas **avisa** em menção solta a IA — que costuma ser citação técnica
legítima. Declare `OWNER_NAME` para a segunda faixa funcionar.

---

## Frontend — a skill `front` é premissa

Acione `front` **antes** de escrever código de UI em qualquer tarefa que envolva
componente, tela, página, modal, formulário, layout, estilo ou animação — inclusive "só
deixa mais bonito". Vale mesmo sem você dizer "front".

- A **fase de descoberta não é opcional** e não se resolve lendo o README: pergunte numa
  mensagem só por referências (URLs reais, e **busque cada uma** — descrição de memória
  não conta), assets, paleta e tipografia, tom e público, e anti-referências.
- **Motion é premissa, não verniz.** Todo elemento interativo tem estado de movimento
  pensado; `prefers-reduced-motion` sempre respeitado.
- **Os cinco estados são obrigatórios**: empty, loading, error, success, disabled. Nunca
  só o happy path.
- **Acessibilidade é requisito**: teclado, foco visível, focus management, `aria-live`.
- Antes de dizer que terminou: Stranger Test (com o logo removido, dá para saber que
  produto é este?) e **screenshot verificado**. Entregar interface por descrição é o
  caminho conhecido para o acabamento amador.

Subagentes que mexem em UI seguem a mesma regra — inclua no prompt deles.

---

## Code review sempre, e comentando no código

Sessão que tocou código não encerra sem review. O `hooks/code-review-gate.sh` grava o
marco zero no `SessionStart` e compara no `Stop`.

**O marco zero não é enfeite.** Sem ele, "o que mudou" mente duas vezes: a sujeira que já
estava na árvore entra na conta, e o commit feito durante a sessão sai da conta no
instante em que a árvore fica limpa — justo quando o review mais importa.

**`--comment` é o padrão**, não uma opção: `/code-review --comment` ancora o achado no
arquivo e na linha. Achado impresso no terminal morre no scrollback e ninguém age sobre
ele. Sem PR aberto, os achados saem com `caminho:linha` e você diz que não havia onde
comentar — não abra PR só para ter onde comentar.

---

## Agentes — acione por conta própria

Os agentes vivem em `agents/` e estão disponíveis em toda interação, não só via `/squad`.
Acione o especialista sempre que a tarefa cair no domínio dele:

| Domínio | Agente |
|---|---|
| segurança, licença, CVE, OWASP, threat model | `security-auditor` |
| servidor, rede, container, deploy, observabilidade | `infra-sre` |
| Actions, Docker, esteira, rollback | `devops-pipeline` |
| código, refactor, performance, bug | `dev-fullstack` |
| contrato de endpoint, versionamento, idempotência | `api-designer` |
| schema, índice, migration, query lenta | `db-expert` |
| regra de negócio, máquina de estados, vocabulário | `domain-modeler` |
| o que testar, flaky, suíte lenta | `test-engineer` |
| referência visual, direção de design | `front-scout` |
| interface pronta, "ficou com cara de IA" | `front-critic` |
| RAG, agentes, prompt, custo de inferência | `ai-architect` |
| estado real de produção | os cinco de `agents/operacao/` |

**Agentes têm memória própria** em `~/.claude/agent-memory/<nome>/`. Antes de mandar um
agente medir de novo, **pergunte a ele o que já sabe**: a memória dele responde "o que
mudou desde a última vez", que quase sempre é a pergunta real.

Domínio específico de negócio (fiscal, jurídico, saúde) merece agente dedicado — crie o
seu em `agents/base/` e referencie aqui.

---

## Economia de tokens

Dois eixos ortogonais, ambos premissa, escopados por tipo de sessão:

- **Minimalismo de código** (`ponytail`, ver `DEPENDENCIES.md`) = *o que se constrói*.
  YAGNI, stdlib antes de dependência, feature nativa antes de lib, uma linha antes de
  cinquenta. Ativo em sessão de código; OFF em prosa.
- **Prosa terse** (`caveman`) = *como se fala no terminal*. Ativo em sessão de chat; **OFF
  em código** — comprimir código e tool-calls custa mais tokens, não menos.
- **Humanizer** = *o que se publica para outros*. README, changelog, copy, comentário de
  issue. Nunca aplique caveman ao entregável de prosa, nem humanizer à conversa no
  terminal. Na dúvida, pergunte quem lê.

Nunca ligue os dois primeiros juntos — anula o ganho. Os hooks de sessão já fazem esse
split; esta seção documenta a intenção.

---

## Ambiente — o que morde

- **`/tmp` pode ser efêmero** (WSL, alguns containers). Entregável durável nunca nasce
  lá; vai para a home ou para o repositório.
- **Config declarada não é config em vigor.** Hook registrado pode nunca disparar. A
  evidência é linha no log, não linha no arquivo.
- **O `env` do `settings.json` vaza para o processo vivo** e não sai ao reverter o
  arquivo. Depois de mexer nele, teste com `env -u VAR` ou em sessão nova — senão você
  testa o estado errado e conclui o oposto.
