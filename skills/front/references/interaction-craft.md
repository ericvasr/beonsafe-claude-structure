# Interaction craft — the details that read as care

Load in Phase 4, junto com `ux-interaction.md`. Aquele arquivo garante que a superfície **funciona** (os cinco estados, formulário, acessibilidade). Este garante que ela **parece feita por alguém que se importa** — a camada de ofício que separa "componente correto" de "componente que dá vontade de usar".

**Prime rule:** o usuário não percebe interação boa; percebe interação ruim. Cada item aqui é invisível quando está certo e barulhento quando está errado.

---

## 1. Timing percebido — o número que ninguém calibra

Duração não é gosto, é função da distância e do tipo do movimento.

| Movimento | Duração | Easing |
|---|---|---|
| Micro-feedback (hover, press) | 80–120 ms | `ease-out` |
| Entrada de elemento pequeno (tooltip, dropdown) | 150–200 ms | `ease-out` |
| Painel / drawer / modal | 250–350 ms | `cubic-bezier(.32,.72,0,1)` |
| Saída de qualquer coisa | **60–70% da entrada** | `ease-in` |
| Transição de página | 300–450 ms | ease custom |

Três regras que resolvem a maioria dos casos:

- **Saída é mais rápida que entrada.** Entrar é apresentar; sair é sumir. Saída na mesma duração da entrada faz a UI parecer lenta, e é o erro mais comum.
- **`ease-out` para o que entra, `ease-in` para o que sai.** `ease-in-out` em elemento pequeno lê como preguiça — começa devagar quando o olho já esperava resposta.
- **`linear` só para movimento contínuo** (spinner, marquee, progresso). Em qualquer outra coisa denuncia falta de curva.

Distância importa: um elemento que atravessa 400 px na mesma duração de um que anda 8 px vai parecer teleporte ou lentidão. Escale a duração com a distância, não com a importância.

---

## 2. Toast / notificação

- **Empilhar, não substituir.** Toast novo não apaga o anterior; empilha com offset e escala decrescente (o de baixo levemente menor e mais opaco). Máximo 3 visíveis, resto na fila.
- **Entra pela borda de onde vem**, sai pela mesma. Entrada por `translateY` + `opacity` + leve `scale(0.96 → 1)`.
- **Duração pelo tamanho do texto**: ~4 s de base, +1 s a cada ~15 palavras. Erro não some sozinho.
- **Hover pausa o timer.** Sem isso, o toast desaparece exatamente quando a pessoa vai ler.
- **Swipe para dispensar** no mobile, com resistência e ponto de virada em ~40% da largura.
- **Nunca toast para erro que exige ação** (`ux-interaction.md` §5) e nunca para confirmar o óbvio.

## 3. Drawer / bottom sheet

- **Arrastável com física**, não com transição fixa. A velocidade do gesto decide: passou do limiar de velocidade, fecha, mesmo sem passar do limiar de distância.
- **Snap points** explícitos (peek / meio / cheio) em vez de posição livre.
- **Overlay escurece proporcional** à posição do drawer, não em on/off.
- **`overscroll-behavior: contain`** no conteúdo — sem isso, rolar até o fim do drawer rola a página atrás, e a sensação é de bug.
- **Scroll do body travado** enquanto aberto, e restaurado na posição exata ao fechar (não no topo).
- **Handle visível** quando é arrastável. Affordance invisível não existe.

## 4. Modal / dialog

- Entrada com `scale(0.96 → 1)` + `opacity`, nunca deslizando de longe. O olho já está no centro.
- Foco entra no primeiro elemento útil (não no botão de fechar), fica preso, e **volta ao gatilho** ao sair (`ux-interaction.md` §4 — é o item mais esquecido).
- `Esc` fecha; clique no overlay fecha **só** se não houver dado não salvo.
- Nada de nested modal. Se precisa de dois, o fluxo está errado.

## 5. Hover, press e o que fazer no touch

- **Press state existe.** `scale(0.97)` ou mudança de fundo em 80 ms. Sem feedback de press, o botão parece morto no toque.
- **`@media (hover: hover)`** em todo hover state. Em touch, hover fica "grudado" após o toque.
- **Hover intent** em menu: 100–150 ms de atraso na abertura evita que o menu pisque ao atravessar o cursor. Fechamento com atraso maior (~300 ms) para dar tempo de alcançar o submenu.
- **Área de clique ≥ 44×44 px** mesmo que o desenho seja menor — cresça o alvo com padding ou `::after`, não o visual.
- **Cursor comunica**: `pointer` em clicável, `grab/grabbing` em arrastável, `not-allowed` em desabilitado, `text` em editável.

## 6. Foco — a parte que separa produto de protótipo

- **Nunca remover o ring.** Restilizar: `:focus-visible` com ring de 2 px, `outline-offset: 2px`, cor de acento com contraste suficiente contra os dois fundos possíveis.
- **`:focus-visible`, não `:focus`** — evita ring em clique de mouse e o mantém no teclado.
- **Skip link** para o conteúdo principal, visível ao focar.
- **Ordem de tab segue a ordem visual.** `tabindex` positivo é sinal de layout errado.

## 7. Números, texto e o que trai amadorismo

- **Número que muda**: transição de dígito (roll) ou pelo menos `tabular-nums` para não dançar a largura. Contador que muda a largura a cada tick parece quebrado.
- **`font-variant-numeric: tabular-nums`** em toda tabela, preço, timer e métrica. Alinhamento de dígito é gratuito e ninguém faz.
- **Texto não deve reflow** ao entrar em hover (peso de fonte mudando é o culpado clássico — use `text-shadow` ou reserve a largura).
- **Truncamento** com `title`/tooltip mostrando o inteiro; nunca truncar sem dar acesso ao conteúdo.
- **Optical alignment**: aspas, marcadores e ícones alinhados pelo peso visual, não pela caixa. Ícone ao lado de texto quase sempre precisa de 1 px de ajuste vertical.

## 8. Skeleton e otimista

- **Skeleton espelha o layout real** — mesmas caixas, mesmas alturas. Skeleton genérico causa o salto que ele deveria evitar.
- **Shimmer sutil e lento** (1,5–2 s por passada). Rápido lê como carregamento travado.
- **Otimista onde é seguro** (toggle, like, reorder): renderize já, reconcilie depois, e no erro **reverta visivelmente** com aviso — reverter em silêncio é pior que não ser otimista.

## 9. Densidade e ritmo

- **Escala espacial única** (4 ou 8 px) aplicada em tudo. Um `13px` perdido entre `12` e `16` é o que faz a tela parecer "quase certa".
- **Espaçamento comunica agrupamento**: itens relacionados mais perto entre si do que do grupo vizinho. Espaçamento uniforme destrói hierarquia.
- **Altura de linha cai conforme o corpo cresce**: 1.6 em corpo, 1.2–1.3 em display. Título com `line-height` de corpo parece frouxo.

---

## Quick gate (Phase 5 add-on)

- [ ] Saída mais rápida que entrada; `ease-out` entrando, `ease-in` saindo
- [ ] Press state em todo elemento tocável; hover atrás de `@media (hover: hover)`
- [ ] Toast empilha, pausa no hover, e não é usado para erro acionável
- [ ] Drawer com física de gesto, snap points e `overscroll-behavior: contain`
- [ ] Modal devolve o foco ao gatilho; `Esc` fecha; sem nested
- [ ] `:focus-visible` restilizado, nunca removido; ordem de tab = ordem visual
- [ ] `tabular-nums` em número que muda; nada de reflow no hover
- [ ] Skeleton espelha o layout; otimista reverte visivelmente no erro
- [ ] Uma única escala espacial, sem valor órfão
