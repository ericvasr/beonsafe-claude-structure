# Skills e commands

**Skill** é um procedimento que o Claude carrega quando a tarefa casa com a `description`
dela. **Command** é o que você dispara por `/nome`. A diferença que importa: a skill pode
se acionar sozinha, o command sempre parte de você.

## As dez skills

| Skill | Aciona quando | O que entrega |
|---|---|---|
| `squad` | Tarefa multi-domínio (infra + código + segurança) | Despacha vários agentes em paralelo sobre a **mesma** tarefa, com síntese e review cruzado |
| `incident` | Incidente ativo, outage, degradação, alerta crítico | Do alerta ao postmortem: triagem, mitigação, timeline, ações com dono e prazo |
| `runbook` | Documentar ou executar procedimento operacional | Passo a passo com comando de verificação em cada etapa |
| `infra-audit` | Auditar host, container, rede, certificado | Relatório de postura com severidade e remediação acionável |
| `sec-scan` | Scanning de segurança | Imagem, filesystem, IaC, segredo, dependência, SBOM — consolidado por severidade |
| `humanizer` | Prosa que outra pessoa vai ler | Tira o registro de IA: frase de encaixe, tricolon inflado, hedge, superlativo sem medida |
| `front` | Qualquer trabalho de interface | Descoberta → auditoria → referências → arquitetura → criação → verificação |
| `gsap` | Timeline, ScrollTrigger, pin, scrub, morph de SVG | Quando a animação **é** o produto |
| `motion` | Animação declarativa em React | Variants, AnimatePresence, layout animation, gesto com física |
| `threejs` | Cena 3D e WebGL | Partículas, shader, GLTF, dispose, fill rate |

## Os três commands

| Command | O que faz |
|---|---|
| `/consultar <tema>` | Consulta os vaults e sintetiza uma resposta. **Rode antes da primeira edição** quando o assunto já teve sessão |
| `/ingerir <fonte>` | Ingere aprendizado nos vaults, classificando por conteúdo |
| `/lint` | Revisão completa da wiki: link quebrado, página órfã, duplicata |

## A escada de animação

As três skills de animação respondem *como* animar. Quem decide *se* cabe biblioteca é o
`front`, em `references/motion-libs.md`, com a escada:

```
CSS  →  recurso nativo da plataforma  →  biblioteca
```

Usar GSAP para um hover state é o sinal de que ninguém checou o degrau 1 — CSS faz isso
de graça e sem 25 KB. E antes do `npm i` vem o gate de licença: o licenciamento do GSAP
mudou depois da aquisição pela Webflow, e "agora os plugins são grátis" não cobre todo
caso de uso.

## Precedência entre skills

Quando mais de uma parece caber, a pergunta que resolve quase sempre é **quem vai ler**:

| Situação | Skill |
|---|---|
| Conversa no terminal com você | prosa terse (`caveman`) |
| O que você publica para outros | `humanizer` |
| Mensagem de commit, título e corpo de PR | nenhuma das duas — registro seco é proposital |
| Código, comentário, nome de identificador | `ponytail` |
| Interface | `front` **antes** de escrever, `front-critic` antes de dar por pronta |

Nunca aplique a prosa terse ao entregável escrito, nem o `humanizer` à conversa de
terminal.

## `front` é uma composição

Diferente das outras, a `front` integra conteúdo de quatro projetos de terceiros. O
crédito de cada um, com licença e o que ela exige, está em
[`../skills/front/PROCEDENCIA.md`](../skills/front/PROCEDENCIA.md).

As 21 referências em `skills/front/references/` são carregadas sob demanda, por fase — o
`SKILL.md` diz qual abrir quando. Carregar todas de uma vez desperdiça contexto.
