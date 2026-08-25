---
name: motion
description: Use ao escrever, revisar ou depurar animação declarativa em React com Motion (motion.dev, ex-Framer Motion) — variants, AnimatePresence, layout animation, shared layout com layoutId, gestos (drag, hover, tap), scroll com useScroll e useTransform, spring, useReducedMotion, LazyMotion, exit que não dispara, layout shift ao animar. Também acione quando o pedido mencionar motion.dev, framer-motion, `motion/react`, animação de entrada/saída em React, transição entre estados de componente, ou quando alguém colar código com `<motion.div>` para revisar. NÃO use para decidir SE precisa de biblioteca (isso é `front`, references/motion-libs.md), para timeline coreografada e ScrollTrigger (isso é `gsap`), nem para 3D (isso é `threejs`).
license: MIT
version: 1.0.0
---

# /motion — animação declarativa em React, sem inventar o que o CSS já faz

Motion (pacote `motion`, import de `motion/react`, MIT verificado) resolve quatro coisas que o CSS puro não resolve bem: **animação de saída**, **layout animation**, **gesto com física** e **estado compartilhado entre componentes**. Fora disso, ele costuma ser peso a mais.

A pergunta antes de importar: o que estou animando é entrada/saída de um elemento que **desmonta**, ou é uma mudança de estado que `transition` do CSS cobre? Se for a segunda, o CSS ganha — 0 KB, sem hidratação, sem cascata de re-render.

---

## 1. Variants: o motivo de existir

Animar prop por prop espalha timing por todo lado. Variants nomeiam **estados** e propagam para os filhos:

```jsx
import { motion } from 'motion/react';

const lista = {
  oculto: {},
  visivel: { transition: { staggerChildren: 0.06, delayChildren: 0.1 } },
};
const item = {
  oculto: { opacity: 0, y: 16 },
  visivel: { opacity: 1, y: 0, transition: { type: 'spring', stiffness: 260, damping: 26 } },
};

<motion.ul variants={lista} initial="oculto" animate="visivel">
  {dados.map(d => <motion.li key={d.id} variants={item}>{d.nome}</motion.li>)}
</motion.ul>
```

O pai não precisa repetir o estado nos filhos: o nome da variante desce sozinho. Mudou o ritmo? Um número, num lugar.

---

## 2. AnimatePresence: a saída que o CSS não tem

```jsx
<AnimatePresence initial={false} mode="wait">
  {aberto && (
    <motion.div
      key="painel"                                  // key ESTÁVEL, senão não há saída
      initial={{ opacity: 0, height: 0 }}
      animate={{ opacity: 1, height: 'auto' }}
      exit={{ opacity: 0, height: 0 }}
      transition={{ duration: 0.22, ease: [0.16, 1, 0.3, 1] }}
    />
  )}
</AnimatePresence>
```

Por que o `exit` "não funciona", em ordem de frequência:

1. O `AnimatePresence` **não é pai direto** do condicional, ou o condicional está acima dele.
2. Falta `key`, ou a key muda a cada render (`key={Math.random()}`, index de array que reordena).
3. O componente filho não é `motion.*` nem repassa props.
4. Desmonte vem do roteador, que troca a árvore inteira antes da saída rodar.
5. `mode="wait"` esperando a saída de algo que nunca sai.

`height: 'auto'` funciona aqui, ao contrário do CSS — mas mede o conteúdo a cada quadro. Em lista longa, prefira `transform: scaleY` com `transform-origin`.

---

## 3. Layout animation: potente e traiçoeira

```jsx
<motion.div layout transition={{ layout: { duration: 0.25 } }} />
```

`layout` anima o FLIP entre duas posições calculadas. Cuidados que evitam UI borrada:

- Texto dentro de elemento com `layout` **distorce** enquanto anima. Ponha `layout` no contêiner e deixe o conteúdo com `layout="position"`.
- `layoutId` compartilhado faz o elemento "voar" entre dois lugares — é o efeito de card que vira modal. Dois elementos com o mesmo `layoutId` montados ao mesmo tempo brigam.
- `border-radius` e `box-shadow` precisam estar em estilo inline para acompanhar o FLIP sem deformar.
- Em lista virtualizada, `layout` recalcula tudo a cada scroll. Desligue.

---

## 4. Scroll sem biblioteca de scroll

```jsx
const { scrollYProgress } = useScroll({ target: ref, offset: ['start end', 'end start'] });
const y = useTransform(scrollYProgress, [0, 1], ['0%', '-18%']);
<motion.div ref={ref} style={{ y }} />
```

Antes disso: **CSS `animation-timeline: scroll()` e `view()` fazem parallax e reveal nativamente**, com zero JS, e já têm suporte amplo. Reveal ao entrar na viewport quase nunca justifica biblioteca. Use `useScroll` quando precisar de valor derivado em JS (interpolar cor, alimentar canvas, sincronizar dois elementos distantes).

`useSpring` sobre o progresso dá suavidade sem `scrub` de terceiros:

```jsx
const suave = useSpring(scrollYProgress, { stiffness: 120, damping: 30, mass: 0.4 });
```

---

## 5. Movimento reduzido e peso

```jsx
const reduz = useReducedMotion();          // NUNCA opcional
<motion.div
  initial={reduz ? false : { opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={reduz ? { duration: 0 } : { type: 'spring', stiffness: 300, damping: 30 }}
/>
```

`initial={false}` é o desligamento correto: o elemento nasce no estado final, sem pular.

Peso: `LazyMotion` + `domAnimation` derruba a árvore completa do componente `motion` quando o bundle está apertado.

```jsx
import { LazyMotion, domAnimation, m } from 'motion/react';
<LazyMotion features={domAnimation}><m.div animate={{ opacity: 1 }} /></LazyMotion>
```

Note o `m.div` no lugar de `motion.div` — trocar um pelo outro anula a economia.

---

## 6. Spring que parece física, não borracha

| Sensação | stiffness | damping | Onde usar |
|---|---|---|---|
| Preciso, sem overshoot | 300 | 30 | botão, toggle, feedback de UI |
| Suave com leve inércia | 180 | 24 | painel, drawer, card |
| Elástico | 400 | 12 | só com intenção lúdica declarada |

`duration` e `type: 'spring'` juntos se ignoram — escolha um. Para movimento pequeno de interface, `ease: [0.16, 1, 0.3, 1]` com 150–250 ms costuma ler melhor que qualquer spring.

---

## Checklist antes de dizer que terminou

- [ ] O que é `transition` de CSS ficou em CSS
- [ ] `useReducedMotion` tratado, com estado final visível
- [ ] `AnimatePresence` com key estável e pai direto do condicional
- [ ] Nada de GSAP no mesmo elemento (os dois escrevem `transform`)
- [ ] Só `transform`/`opacity` no caminho quente; `layout` fora de lista virtualizada
- [ ] `m` + `LazyMotion` se o bundle importa
- [ ] Testado com re-render do pai: animação que reinicia a cada render é dependência instável em `animate`
- [ ] Screenshot ou captura de vídeo conferida
