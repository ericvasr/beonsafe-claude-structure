# Motion libraries — choosing, gating, and using them

Load in Phase 4 when motion needs more than CSS can express. `motion-pipeline.md` decides **what** should move and why; this file decides **with what**, and how not to pay for it twice.

**Prime rule:** the platform animates for free. Reach for a library only when you can name the thing CSS cannot do — layout-shared transitions, physics, timeline orchestration, scroll-driven sequencing with fine control, or SVG morphing. "It's easier with a library" is not a reason; it's 30–120 KB.

---

## 1. Decision ladder — stop at the first rung that works

| Rung | Use it for | Cost |
|---|---|---|
| **1. CSS transition** | hover / focus / press / open-close of a single property | 0 |
| **2. CSS `@keyframes` + `animation`** | looping or multi-step on one element (pulse, shimmer, marquee) | 0 |
| **3. `view-transition` API** | route/state change morph, shared element between views | 0, native |
| **4. `animation-timeline: scroll()/view()`** | scroll-linked reveal and progress | 0, native |
| **5. Web Animations API (`el.animate()`)** | imperative control (pause, reverse, seek) without a lib | 0 |
| **6. Motion (`motion.dev`)** | React declarative motion, layout animation, gestures, exit animations | ~18–34 KB |
| **7. GSAP** | timeline orchestration, ScrollTrigger, SVG morph, text splitting | ~25 KB + plugins |
| **8. anime.js** | small standalone timeline outside React | ~9 KB |

Rungs 3 and 4 are the ones most often skipped for no reason. Check browser support for the actual target, then use them — `@supports (animation-timeline: scroll())` with a CSS-transition fallback beats importing a scroll library.

---

## 2. Before importing anything

```bash
# 1. Já está no projeto? Nunca adicione um segundo motion lib.
grep -E '"(motion|framer-motion|gsap|animejs|@studio-freight/lenis|lenis)"' package.json
```

Three hard rules:

1. **One motion library per project.** Two is a bundle tax plus two mental models plus competing `will-change` layers. If the project already has one, use it even if you prefer the other.
2. **Verify the version's API before writing code.** `framer-motion` became `motion` (different package name, `motion/react` import path). GSAP 3 killed the `TweenMax` API. Writing v2 code against v3 is the most common failure here.
3. **License gate is not optional** — see §6. This is a startup product, not a demo.

---

## 3. Motion (ex-Framer Motion) — the React default

Package: `motion` · import from `motion/react` · license MIT (verificado em 2026-07-26 — reconfira no `LICENSE` do repo antes de usar).

Use it for what CSS genuinely cannot:

- **`layout` / `layoutId`** — shared-element transitions and automatic FLIP on layout change. The single strongest reason to install it.
- **`AnimatePresence`** — exit animations. CSS cannot animate an unmounting element.
- **Gestures with physics** — `drag`, `whileHover`, `whileTap` with spring feel.
- **`useScroll` / `useTransform`** — scroll-driven values when native `animation-timeline` is not enough.

```jsx
import { motion, AnimatePresence, useReducedMotion } from 'motion/react';

function Panel({ open, children }) {
  const reduce = useReducedMotion();          // NUNCA opcional
  return (
    <AnimatePresence initial={false}>
      {open && (
        <motion.div
          initial={reduce ? { opacity: 0 } : { opacity: 0, y: 8 }}
          animate={reduce ? { opacity: 1 } : { opacity: 1, y: 0 }}
          exit={reduce ? { opacity: 0 } : { opacity: 0, y: 4 }}
          transition={reduce ? { duration: 0 } : { type: 'spring', stiffness: 420, damping: 34 }}
        >
          {children}
        </motion.div>
      )}
    </AnimatePresence>
  );
}
```

Rules that keep it fast:
- Animate `transform` and `opacity`. `motion` will happily animate `height` — it will also jank. For height, use `layout` (FLIP) instead of animating the property.
- Spring over duration for anything the user *initiated*; duration for anything ambient. Springs: `stiffness` 300–500 / `damping` 25–40 is the useful range. Below 20 damping it wobbles like a toy.
- `LazyMotion` + `domAnimation` when bundle size is contested — drops the full `motion` component tree.
- One `AnimatePresence` per list; give every child a stable `key`.

---

## 4. GSAP — timeline orchestration and scroll control

Use it when the animation *is the feature*: a choreographed hero, a scroll-driven story with pinned sections, SVG path morphing, per-character text reveal. For a hover state, using GSAP is a tell that nobody checked rung 1.

What only GSAP does well:

- **Timeline** — real sequencing with labels, relative offsets, `stagger`, and the ability to seek/reverse/scrub the whole composition as one object.
- **ScrollTrigger** — pin, scrub, snap, and per-element scroll ranges. This is the reason most projects add GSAP.
- **SplitText** — per-line/word/char reveal without hand-wrapping spans.
- **MorphSVG / MotionPath** — shape morph and path following.

```js
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
gsap.registerPlugin(ScrollTrigger);

// prefers-reduced-motion PRIMEIRO: sem isso o pin e o scrub continuam rodando.
if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
  gsap.set('[data-reveal]', { opacity: 1, y: 0 });
} else {
  const tl = gsap.timeline({
    scrollTrigger: {
      trigger: '#capitulo',
      start: 'top top',
      end: '+=180%',
      scrub: 0.6,           // número = suavização; true = travado no scroll
      pin: true,
      invalidateOnRefresh: true,
    },
  });
  tl.from('[data-reveal]', { opacity: 0, y: 24, stagger: 0.08 })
    .to('#capa', { scale: 1.08 }, '<');   // '<' = começa junto com o anterior
}
```

Rules:
- **Sempre `gsap.registerPlugin`** — plugin não registrado falha silencioso.
- Em React/Next: rode dentro de `useGSAP()` (`@gsap/react`) ou `useEffect` com cleanup `ScrollTrigger.getAll().forEach(t => t.kill())`. Sem cleanup, navegação SPA acumula triggers e o scroll fica pesado progressivamente — bug clássico que só aparece depois de 5 minutos de uso.
- `scrub: <número>` quase sempre lê melhor que `scrub: true`.
- `pin: true` muda o layout — verifique CLS na Fase 5. Pin com `min-h-[100dvh]`, nunca `h-screen` (ver `anti-patterns.md`).
- Não misture GSAP com `motion` no mesmo elemento: os dois escrevem `transform` e a última escrita ganha.

---

## 5. anime.js e Lenis — os casos específicos

**anime.js** (MIT, verificado): timeline pequena fora do React, ou animação em SVG/canvas onde você não quer o peso do GSAP. ~9 KB. Não tem ScrollTrigger equivalente — se precisa de scroll, ou é nativo (rung 4) ou é GSAP.

**Lenis** (smooth scroll): resolve o scroll "pesado" que design de agência costuma pedir. Duas ressalvas honestas:
- **Sequestra o scroll nativo.** Quebra `scroll-behavior`, âncora de teclado, e a expectativa de quem usa trackpad. Só entra se o cliente pedir explicitamente esse feel.
- Precisa de `lenis.on('scroll', ScrollTrigger.update)` para não dessincronizar do GSAP.
- **Sem veredito de licença registrado** — passa pelo gate antes.

---

## 6. Gate de licença — obrigatório antes de instalar

Rodar antes de `npm i`, sempre. Registre os vereditos duráveis em `~/.claude/logs/license-audit.jsonl` e numa página da sua wiki.

| Lib | Estado em 2026-07-26 |
|---|---|
| `motion` (motion.dev) | ✅ MIT verificado. Motion+ é produto comercial separado — não confundir |
| `animejs` | ✅ MIT verificado |
| `gsap` | ⚠️ **REVIEW obrigatório.** O licenciamento mudou depois da aquisição pela Webflow. Não presuma MIT e não presuma que "os plugins agora são grátis" cobre o teu caso. A pergunta a responder é: o produto **vende** a animação como o produto em si, ou usa animação num produto próprio? Acione `security-auditor` e registre o veredito |
| `lenis` | ⚠️ sem veredito registrado — gate antes |

Se copiar código de exemplo de qualquer registry de componente (reactbits, kokonutui, daisyUI…), a licença do trecho vem junto: ver `source-registry.md`. MIT exige preservar o aviso de copyright — copy-paste é justamente onde isso se perde.

---

## 7. Performance — o que realmente causa jank

- **Só `transform` e `opacity`.** Animar `top`/`left`/`width`/`height`/`margin` dispara layout a cada frame. Para tamanho, use `scale` ou FLIP.
- **`will-change` é empréstimo, não presente.** Aplique no início da interação, remova no fim. Deixar fixo em muitos elementos consome memória de GPU e degrada tudo.
- **Composite layers têm custo.** Dezenas de elementos animando simultaneamente derrubam o frame budget mesmo com `transform`. Anime o container, não 40 filhos.
- **Orçamento:** 16,7 ms por frame a 60 fps. Meça com o Performance panel, não pelo olho — em máquina de dev tudo parece liso.
- **Entrada por scroll:** prefira `IntersectionObserver` (ou rung 4) a listener de `scroll`. Listener de scroll sem `passive: true` bloqueia a rolagem.
- **`prefers-reduced-motion`:** não é "desligar tudo". Mantenha o feedback de estado (opacidade, cor) e remova deslocamento, parallax, scrub e auto-play. Movimento vestibular é o que machuca, não a mudança de cor.

---

## Quick gate (Phase 5 add-on)

- [ ] Nenhuma lib adicionada para o que CSS/nativo já fazia (rungs 1–5 checados)
- [ ] Uma única motion library no `package.json`
- [ ] Veredito de licença registrado antes do install (GSAP e Lenis exigem)
- [ ] API corresponde à versão instalada (`motion/react`, não `framer-motion`)
- [ ] `prefers-reduced-motion` tratado no caminho da lib, não só no CSS
- [ ] GSAP: plugins registrados e cleanup de `ScrollTrigger` em unmount
- [ ] Só `transform`/`opacity`; `will-change` removido após a interação
- [ ] Frame budget medido no Performance panel, não estimado
