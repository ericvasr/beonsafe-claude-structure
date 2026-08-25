---
name: gsap
description: Use ao escrever, revisar ou depurar animação com GSAP — timeline, ScrollTrigger, pin, scrub, snap, SplitText, MorphSVG, Flip, DrawSVG, useGSAP em React, cleanup de trigger, scroll que trava ou fica pesado com o tempo, animação que dessincroniza do scroll suave. Também acione quando o pedido mencionar GSAP, ScrollTrigger, timeline de animação, cena coreografada, pinned section, scroll storytelling, morph de SVG, ou quando alguém colar código GSAP para revisar. NÃO use para decidir SE cabe GSAP (isso é `front`, references/motion-libs.md, que tem a escada CSS→nativo→lib e o gate de licença), nem para animação declarativa em React (isso é `motion`).
license: MIT
version: 1.0.0
---

# /gsap — orquestração quando a animação É o produto

GSAP é a ferramenta certa quando a animação **é a feature**: herói coreografado, história com seções fixadas ao scroll, morph de SVG, revelação por caractere. Usar GSAP para um hover state é o sinal de que ninguém checou o degrau 1 da escada — CSS faz isso de graça e sem 25 KB.

**Antes de instalar: licença.** O licenciamento mudou depois da aquisição pela Webflow. Não presuma MIT e não presuma que "agora os plugins são grátis" cobre o seu caso. A pergunta que decide: o produto **vende a animação como o produto em si**, ou usa animação num produto próprio? Acione `security-auditor`, registre o veredito em `~/.claude/logs/license-audit.jsonl`, e só então `npm i`. Detalhes: `front/references/motion-libs.md` §6.

---

## 1. Timeline: a razão de existir

Tween solto é `transition` do CSS com mais passos. O que só a timeline faz é **relacionar tempos**:

```js
const tl = gsap.timeline({ defaults: { ease: 'power3.out', duration: 0.6 } });
tl.from('.titulo', { y: 24, opacity: 0 })
  .from('.lead',   { y: 16, opacity: 0 }, '-=0.35')   // sobrepõe 350ms
  .from('.cta',    { y: 12, opacity: 0 }, '<0.1')     // 100ms depois do início do anterior
  .from('.card',   { y: 20, opacity: 0, stagger: 0.08 }, '-=0.2');
```

Posições relativas (`'<'`, `'>'`, `'-=0.3'`) são o coração: mudou a duração de um passo, a coreografia inteira se reacomoda. Delays absolutos espalhados por dez tweens são o que apodrece.

`defaults` no construtor evita repetir ease e duração em cada linha — e faz o ajuste fino ser uma edição só.

---

## 2. ScrollTrigger: onde a maioria dos bugs mora

```js
gsap.registerPlugin(ScrollTrigger);          // esquecer isto é o erro nº 1

const tl = gsap.timeline({
  scrollTrigger: {
    trigger: '.secao',
    start: 'top top',
    end: '+=120%',        // duração em distância de scroll, não em px de página
    scrub: 0.6,           // número = suavização em segundos; `true` gruda seco
    pin: true,
    anticipatePin: 1,     // sem isto o pin "pula" em scroll rápido
    invalidateOnRefresh: true,
  },
});
```

O que morde:

- **`markers: true` durante o desenvolvimento.** Depurar posição de trigger no olho é perda de tempo.
- **Layout que muda depois do cálculo** (fonte que carrega, imagem sem `width`/`height`, acordeão que abre) desloca todos os triggers. `ScrollTrigger.refresh()` depois, ou `invalidateOnRefresh`.
- **Pin cria wrapper no DOM.** Se o CSS do pai depende de `:first-child`, de `gap` ou de grid implícito, o layout muda ao pinar. Use `pinSpacing` consciente.
- **`scrub` com animação de propriedade cara** (filter, box-shadow, width) engasga. Scrub só em `transform` e `opacity`.
- **Scroll suave de terceiro** (Lenis) precisa de `lenis.on('scroll', ScrollTrigger.update)`, senão a animação anda atrás do scroll. E Lenis ainda não tem veredito de licença registrado — passa pelo gate antes.

---

## 3. React: `useGSAP` e o vazamento que só aparece depois

```jsx
import { useGSAP } from '@gsap/react';

function Secao() {
  const raiz = useRef(null);
  useGSAP(() => {
    // tudo criado aqui é revertido no unmount, incluindo ScrollTriggers
    gsap.from('.item', { y: 20, opacity: 0, stagger: 0.06 });
  }, { scope: raiz });
  return <section ref={raiz}>…</section>;
}
```

Sem `useGSAP` (ou sem cleanup manual), navegação SPA **acumula triggers**: cada visita à rota cria mais um conjunto, e o scroll fica progressivamente pesado. O bug clássico não aparece no primeiro minuto de teste — aparece no quinto.

Cleanup manual, quando não dá para usar o hook:

```js
useEffect(() => {
  const ctx = gsap.context(() => { /* animações */ }, raiz);
  return () => ctx.revert();
}, []);
```

**Nunca misture GSAP e `motion` no mesmo elemento.** Os dois escrevem `transform` e a última escrita ganha; o resultado é intermitente e impossível de depurar.

---

## 4. Acessibilidade não é opcional aqui

```js
const reduz = matchMedia('(prefers-reduced-motion: reduce)');

ScrollTrigger.matchMedia?.({
  '(prefers-reduced-motion: no-preference)': () => { /* coreografia completa */ },
  '(prefers-reduced-motion: reduce)': () => {
    gsap.set('.item', { clearProps: 'all', opacity: 1, y: 0 });   // estado final, sem movimento
  },
});
```

Duas regras que valem mais que a preferência do sistema:

- **Conteúdo nunca depende da animação para existir.** Se o JS falhar ou o plugin não carregar, o texto tem que estar lá, legível, em `opacity: 1`. Animar `from` com opacidade zero em CSS é como se perde conteúdo em produção.
- **Seção pinada sequestra o scroll.** Em leitor de tela e em teclado, garanta que o conteúdo pinado é alcançável na ordem do documento e que nada fica preso.

---

## 5. Performance

- Anime **`transform` e `opacity`**. `top`, `left`, `width`, `height` disparam layout a cada quadro.
- `will-change` é analgésico caro: aplique no início da animação e remova no fim (`onComplete`), nunca deixe fixo no CSS.
- `gsap.set()` para estado inicial é mais barato que um tween de duração zero.
- `force3D` já é padrão em GSAP 3; não copie truque de v2.
- **API v2 em projeto v3 é o erro mais comum ao copiar exemplo antigo**: `TweenMax`, `TimelineMax` e `Power2.easeOut` morreram. Hoje é `gsap.to`, `gsap.timeline`, `'power2.out'`.

---

## Checklist antes de dizer que terminou

- [ ] Veredito de licença registrado **antes** do install
- [ ] `registerPlugin` de todo plugin usado
- [ ] Cleanup: `useGSAP`/`gsap.context().revert()`, e triggers mortos no unmount
- [ ] `prefers-reduced-motion` com caminho de estado final
- [ ] Conteúdo legível sem JS
- [ ] Só `transform`/`opacity` no scrub
- [ ] Testado em scroll rápido e em resize (o pin é onde quebra)
- [ ] Screenshot ou vídeo conferido — timeline lida no código não é timeline vista
