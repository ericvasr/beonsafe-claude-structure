# Repertório visual — as fontes trazidas e o veredicto de cada uma

Carregue na **Fase 2 (Discover)**, junto com `source-registry.md`. Isto não é lista de links: é o que já foi aberto, medido e julgado, para a busca começar de um repertório em vez de começar do zero.

**Regra que criou este arquivo:** estas referências foram trazidas e nada foi usado, porque elas viviam fora do fluxo que dispara. Repertório que não chega no momento da decisão é acervo morto. Se você está na Fase 2 e não abriu este arquivo, está desenhando de memória.

Medições feitas pelo `front-scout`, com as páginas abertas de verdade — não descritas de memória. Guarde as capturas fora do git: elas passam de alguns MB rápido.

---

## 1. O achado que vale mais que a lista

**O sotaque de "landing de IA" não está na família da fonte. Está no par peso/tracking do display.**

Dez homes medidas. Quem soa a IA: vercel.com (Geist 64px, `-0.06em`), ghost.org (Inter Display 96px/700, `-0.025em`). Quem soa a ofício: field.io (DM Sans 72px, **peso 400, tracking positivo +0.01em**), USWDS (Public Sans 36px, peso 200), schibsted.com (700 mas tracking **zero**), stripe (peso 300).

Trocar a família sem corrigir peso e tracking não resolve nada. Corrigir peso e tracking sem trocar a família resolve quase tudo.

---

## 2. As referências, com o padrão por trás

| Fonte | O que tirar | Licença / cuidado |
|---|---|---|
| **field.io** | Barra de 50px sticky, fundo **transparente**, sem borda, sem blur, que **esconde no scroll para baixo e volta no scroll para cima**, e **sem CTA nenhum**. Wordmark = fonte do corpo com 0.45em de tracking, sem símbolo. Motion = 16 `<video>`, 0 `<canvas>`, 0 `@keyframes`: o movimento é o conteúdo, o cromo fica parado. | Referência visual, nada a copiar |
| **motion.dev** | Tira de células `<dl>` no lugar de faixa deslizante. Documentação como peça de design. | MIT (a lib) |
| **bklit.com** | Grade com hairline **visível** e régua — bento que não vira dashboard | Referência visual |
| **oxide.computer** | Rótulo mono em caixa alta como estrutura, não como enfeite | Referência visual |
| **kokonutui.com** | Composições de componente; bom para ritmo de seção | Verificar licença por componente |
| **anime.js** | Demos de motion leve; API pequena fora de React | MIT |
| **particles.casberry.in** | **A qualidade de partícula**: grão fino, muito dele, brilho por acúmulo de alfa. Ponto grosso lê como bolha e pesa. | Página é referência; **código do registry: BLOCK** |
| **reactbits.dev** | Catálogo de efeito | **MIT + Commons Clause** — morde se o componente virar parte de algo revendido |
| **originkit.dev** | Catálogo | **Sem licença declarada** = todos os direitos reservados |
| **codepen.io** | Técnica isolada | Caso a caso, quase sempre sem licença explícita |
| **21st.dev / 21-DOT-DEV** | Registro: é org de bibliotecas Swift/Bitcoin, **não** fonte de animação | — |

**Política sugerida:** olhar, medir e se inspirar em qualquer fonte é livre e não precisa de cerimônia. **Copiar código** dispara aviso com a licença nomeada, e a decisão é de quem assume o risco do produto. O que não muda: NC e SA em produto que cobra continuam sendo risco a declarar em voz alta, não a esconder.

---

## 3. As nove linguagens visuais, julgadas

Contexto do julgamento: produto técnico, dark OLED, público iniciante, tom sem hype.

| Linguagem | Veredicto | Por quê |
|---|---|---|
| **Bento Grid** | **usar** | Desde que seja a grade com hairline de bklit e as células de altura desigual do motion.dev. Três cards iguais com sombra não é bento, é template |
| **Minimalismo escuro** | **usar** | oxide e bklit provam que preto + hairline + rótulo mono comunica engenharia |
| Glassmorphism | **erro** | `backdrop-filter: blur()` com borda branca translúcida é o sotaque exato do linear.app. Todo mundo tem |
| Liquid Glass | erro | Mesma família, pior: lê como interface de sistema operacional |
| Neumorphism | erro | Precisa de fundo cinza médio. Morre em `#000` |
| Claymorphism | erro | Volume fofo e pastel brigam com "técnico sem hype" |
| Skeuomorphism | erro | Só como piada de nicho |
| Maximalismo | erro | Quando o mercado grita, sobriedade é o diferencial. Maximalismo entrega o campo |
| Spatial UI / 3D | **caso a caso** | Bonito e caro: ~130–180 KB gzip. Como asset isolado, com gate de carregamento, nunca como estrutura da página. Ver `webgl-3d.md` |

---

## 4. Como usar isto na Fase 2

1. Leia a §1 antes de propor tipografia. Meça peso e tracking do display atual — o problema costuma estar aí.
2. Escolha 2 ou 3 fontes da tabela §2 que atacam o problema **desta** página, e abra cada uma com WebFetch ou Playwright. A tabela diz o que procurar; ela não substitui a captura.
3. Nomeie as anti-referências pela §3, com o motivo medido junto.
4. Se a referência que o usuário citou não está aqui e vale ficar, **acrescente uma linha** depois de abri-la. Este arquivo cresce por uso, não por lista importada.
