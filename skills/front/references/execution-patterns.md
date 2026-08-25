# Execution Patterns — The Craft That Makes Pages World-Class

This reference contains the actual CSS/HTML/JS patterns that separate mediocre pages from Awwwards-tier work. Load this during Phase 4 (Create).

These are not "nice to know" — they are the building blocks of every great page.

---

## 1. Hero Patterns That Work

The hero is 80% of first impression. Get it right.

### Pattern A — Asymmetric Split

```html
<section class="hero">
  <div class="hero-content">
    <h1>The headline that earns attention</h1>
    <p>One sentence that makes them stay.</p>
    <a href="#" class="cta-primary">Specific action verb</a>
  </div>
  <div class="hero-visual">
    <!-- Real product screenshot, 3D render, or illustration. NEVER a gradient blob. -->
  </div>
</section>
```

```css
.hero {
  display: grid;
  grid-template-columns: 1fr 1.2fr; /* Asymmetric — NOT 1fr 1fr */
  gap: clamp(2rem, 4vw, 6rem);
  align-items: center;
  min-height: min(90vh, 900px); /* NOT h-screen, NOT 100vh */
  padding: clamp(2rem, 5vw, 8rem);
}

@media (max-width: 768px) {
  .hero {
    grid-template-columns: 1fr;
    min-height: auto;
    padding: 2rem 1.25rem;
  }
}
```

### Pattern B — Editorial Full-Bleed

Text dominates. Visual is secondary or atmospheric.

```css
.hero-editorial {
  display: flex;
  flex-direction: column;
  justify-content: center;
  min-height: min(85vh, 800px);
  padding: clamp(3rem, 8vw, 12rem) clamp(1.5rem, 5vw, 8rem);
}

.hero-editorial h1 {
  font-size: clamp(2.5rem, 5vw + 1rem, 6rem);
  line-height: 1.05;
  letter-spacing: -0.03em; /* Tighten at large sizes */
  max-width: 18ch; /* Constrain headline width for readability */
}
```

### Pattern C — Product Showcase (Apple-style)

Product image IS the hero. Text is minimal.

```css
.hero-product {
  position: relative;
  display: grid;
  place-items: center;
  min-height: min(100dvh, 1000px);
  overflow: hidden;
}

.hero-product img {
  width: clamp(300px, 60vw, 900px);
  height: auto;
  object-fit: contain;
}

.hero-product .headline {
  position: absolute;
  top: clamp(2rem, 8vh, 6rem);
  text-align: center;
}
```

### What NEVER works as a hero

- Centered text + subtitle + two equal CTAs → "Vercel template" cliché
- Purple/blue gradient background + white text → AI-default
- "Welcome to [Product]" → says nothing
- Three icon-circles below hero → "how it works" template

---

## 2. Section Transition Techniques

Sections should flow into each other, not stack like blocks.

### Technique A — Background color shift

```css
.section-light { background: oklch(0.98 0.005 var(--hue)); }
.section-mid   { background: oklch(0.95 0.01 var(--hue)); }
.section-dark  { background: oklch(0.12 0.02 var(--hue)); color: oklch(0.92 0.005 var(--hue)); }
```

Alternate light → mid → light → dark. Never same-color adjacent sections.

### Technique B — Asymmetric padding rhythm

```css
/* NOT: every section gets 80px top and bottom */
/* YES: intentional rhythm */
.section-breathe { padding: clamp(6rem, 12vh, 10rem) 0; }
.section-tight   { padding: clamp(3rem, 6vh, 5rem) 0; }
.section-hero     { padding: clamp(4rem, 10vh, 8rem) 0; }
```

### Technique C — Overlap / bleed

```css
.section-overlap {
  position: relative;
  margin-top: -4rem;
  z-index: 1;
  border-radius: 1.5rem 1.5rem 0 0;
}
```

### Technique D — Scroll-driven reveal

```css
@supports (animation-timeline: scroll()) {
  .reveal-on-scroll {
    animation: fadeSlideUp linear both;
    animation-timeline: view();
    animation-range: entry 0% entry 40%;
  }

  @keyframes fadeSlideUp {
    from { opacity: 0; transform: translateY(2rem); }
    to   { opacity: 1; transform: translateY(0); }
  }
}
```

---

## 3. Grid-Breaking Layout Patterns

The three-column equal grid is the enemy. These patterns replace it.

### Bento Grid (asymmetric cards)

```css
.bento {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  grid-auto-rows: minmax(200px, auto);
  gap: 1rem;
}

.bento-large  { grid-column: span 8; grid-row: span 2; }
.bento-medium { grid-column: span 4; grid-row: span 1; }
.bento-wide   { grid-column: span 6; grid-row: span 1; }
.bento-tall   { grid-column: span 4; grid-row: span 2; }

@media (max-width: 768px) {
  .bento { grid-template-columns: 1fr; }
  .bento-large, .bento-medium, .bento-wide, .bento-tall {
    grid-column: span 1;
    grid-row: span 1;
  }
}
```

### Alternating split (zigzag)

```css
.feature-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: clamp(2rem, 4vw, 6rem);
  align-items: center;
}

.feature-row:nth-child(even) {
  direction: rtl; /* Flip content/image sides */
}
.feature-row:nth-child(even) > * {
  direction: ltr;
}
```

### Offset grid

```css
.offset-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2rem;
}

.offset-grid > :nth-child(3n+2) {
  transform: translateY(3rem); /* Second column offset down */
}
```

---

## 4. Typography Impact Techniques

Type is the voice of the page. These patterns give it power.

### Fluid type scale

```css
:root {
  --text-xs:   clamp(0.75rem, 0.7rem + 0.25vw, 0.875rem);
  --text-sm:   clamp(0.875rem, 0.8rem + 0.35vw, 1rem);
  --text-base: clamp(1rem, 0.9rem + 0.5vw, 1.125rem);
  --text-lg:   clamp(1.125rem, 1rem + 0.6vw, 1.25rem);
  --text-xl:   clamp(1.25rem, 1rem + 1.2vw, 1.75rem);
  --text-2xl:  clamp(1.5rem, 1rem + 2vw, 2.5rem);
  --text-3xl:  clamp(2rem, 1.2rem + 3vw, 3.5rem);
  --text-hero: clamp(2.5rem, 1.5rem + 4.5vw, 6rem);
}
```

### Headline with negative tracking

```css
h1, .headline {
  letter-spacing: -0.03em; /* Tighten at display sizes */
  line-height: 1.05;
  text-wrap: balance; /* Modern CSS: balanced line breaks */
}
```

### Monospace labels (operational aesthetic)

```css
.label-mono {
  font-family: 'JetBrains Mono', 'Geist Mono', monospace;
  font-size: var(--text-xs);
  text-transform: uppercase;
  letter-spacing: 0.15em;
  color: oklch(0.55 0.02 var(--hue));
}
```

### Pull quote / highlight

```css
.pull-quote {
  font-family: var(--font-display);
  font-size: var(--text-2xl);
  font-style: italic;
  line-height: 1.3;
  border-left: 3px solid oklch(var(--accent-l) var(--accent-c) var(--accent-h));
  padding-left: 1.5rem;
  margin: 3rem 0;
}
```

---

## 5. Color Application Patterns

### The tinting system (mandatory)

```css
:root {
  --hue: 250; /* Brand hue — single source of truth */

  /* Surface scale — ALL tinted toward brand */
  --surface-0: oklch(0.99 0.003 var(--hue));   /* lightest background */
  --surface-1: oklch(0.97 0.006 var(--hue));
  --surface-2: oklch(0.94 0.01 var(--hue));
  --surface-3: oklch(0.90 0.015 var(--hue));

  /* Text scale */
  --text-primary:   oklch(0.15 0.02 var(--hue));
  --text-secondary: oklch(0.40 0.02 var(--hue));
  --text-muted:     oklch(0.55 0.015 var(--hue));

  /* Accent — the ONE color that pops */
  --accent: oklch(0.60 0.18 var(--hue));
  --accent-hover: oklch(0.53 0.18 var(--hue));
  --accent-subtle: oklch(0.94 0.04 var(--hue));
}
```

### Dark mode (derived, not separate)

```css
@media (prefers-color-scheme: dark) {
  :root {
    --surface-0: oklch(0.10 0.005 var(--hue));
    --surface-1: oklch(0.14 0.008 var(--hue));
    --surface-2: oklch(0.18 0.012 var(--hue));
    --surface-3: oklch(0.24 0.015 var(--hue));

    --text-primary:   oklch(0.93 0.005 var(--hue));
    --text-secondary: oklch(0.70 0.01 var(--hue));
    --text-muted:     oklch(0.50 0.01 var(--hue));

    --accent: oklch(0.70 0.16 var(--hue));
    --accent-hover: oklch(0.77 0.16 var(--hue));
    --accent-subtle: oklch(0.18 0.04 var(--hue));
  }
}
```

### Accent application rule

- Accent covers ≤ 10% of surface area (Restrained register)
- Used ONLY for: primary CTA, active states, key data highlights, brand moments
- NEVER used for: backgrounds of large sections, body text, decorative borders

---

## 6. Animation Craft

### Scroll-triggered entrance (modern CSS)

```css
@supports (animation-timeline: view()) {
  [data-animate] {
    opacity: 0;
    transform: translateY(1.5rem);
    animation: enterView 0.6s ease both;
    animation-timeline: view();
    animation-range: entry 10% entry 35%;
  }

  @keyframes enterView {
    to { opacity: 1; transform: translateY(0); }
  }
}

/* Fallback: visible immediately */
@supports not (animation-timeline: view()) {
  [data-animate] { opacity: 1; transform: none; }
}
```

### Spring-feel hover (CSS only)

```css
.card {
  transition: transform 0.35s cubic-bezier(0.2, 0.8, 0.2, 1);
}
.card:hover {
  transform: translateY(-4px);
}
```

### Stagger children on view

```css
[data-stagger] > * {
  --i: 0;
  animation-delay: calc(var(--i) * 60ms);
}
[data-stagger] > *:nth-child(1) { --i: 0; }
[data-stagger] > *:nth-child(2) { --i: 1; }
[data-stagger] > *:nth-child(3) { --i: 2; }
[data-stagger] > *:nth-child(4) { --i: 3; }
[data-stagger] > *:nth-child(5) { --i: 4; }
```

### Reduced motion (mandatory)

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

---

## 7. Responsive Recomposition (not shrinking)

### Container queries (component-level responsive)

```css
.card-container {
  container-type: inline-size;
  container-name: card;
}

@container card (min-width: 400px) {
  .card { display: grid; grid-template-columns: 1fr 1.5fr; }
}

@container card (max-width: 399px) {
  .card { display: flex; flex-direction: column; }
}
```

### Mobile-first section recomposition

```css
/* Mobile: stack, full-bleed, larger touch targets */
.features {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  padding: 2rem 1.25rem;
}

/* Desktop: grid with intentional layout */
@media (min-width: 768px) {
  .features {
    display: grid;
    grid-template-columns: repeat(12, 1fr);
    gap: 2rem;
    padding: clamp(4rem, 8vh, 8rem) clamp(2rem, 5vw, 8rem);
  }
}
```

---

## 8. Performance Patterns (non-negotiable)

### Font loading strategy

```html
<!-- Preload critical fonts (display + body) -->
<link rel="preload" href="/fonts/geist-var.woff2" as="font" type="font/woff2" crossorigin>

<style>
  @font-face {
    font-family: 'Geist';
    src: url('/fonts/geist-var.woff2') format('woff2');
    font-weight: 100 900;
    font-display: swap; /* Show fallback immediately, swap when loaded */
  }
</style>
```

**Rule**: maximum 2 font families loaded. Self-host WOFF2. Never load from Google Fonts CDN (privacy + performance).

### Image optimization

```html
<!-- Responsive images with modern formats -->
<picture>
  <source srcset="/img/hero.avif" type="image/avif">
  <source srcset="/img/hero.webp" type="image/webp">
  <img src="/img/hero.jpg"
       alt="[descriptive alt text]"
       width="1200" height="800"
       loading="lazy"
       decoding="async">
</picture>

<!-- Above-fold images: NO lazy loading -->
<img src="/img/hero.jpg" width="1200" height="800" fetchpriority="high">
```

### Critical CSS pattern

```html
<head>
  <!-- Inline critical CSS for above-fold -->
  <style>/* hero, nav, type system */</style>

  <!-- Defer rest -->
  <link rel="stylesheet" href="/styles/main.css" media="print" onload="this.media='all'">
</head>
```

---

## 9. Component Patterns

### Button hierarchy

```css
/* Primary: filled, brand accent */
.btn-primary {
  background: var(--accent);
  color: oklch(0.99 0 0);
  padding: 0.75rem 1.5rem;
  border-radius: 0.5rem;
  font-weight: 500;
  transition: background 0.2s cubic-bezier(0.2, 0.8, 0.2, 1);
}
.btn-primary:hover { background: var(--accent-hover); }

/* Secondary: outlined */
.btn-secondary {
  background: transparent;
  color: var(--text-primary);
  border: 1px solid var(--surface-3);
  padding: 0.75rem 1.5rem;
  border-radius: 0.5rem;
}

/* Ghost: text-only */
.btn-ghost {
  background: transparent;
  color: var(--accent);
  padding: 0.75rem 1rem;
}
```

**Rule**: ONE primary CTA per viewport. Maximum TWO secondary. Everything else is ghost/link.

### Card that doesn't look like every other card

```css
.card {
  background: var(--surface-1);
  border: 1px solid var(--surface-3);
  border-radius: 0.75rem;
  padding: clamp(1.5rem, 3vw, 2.5rem);
  transition: transform 0.35s cubic-bezier(0.2, 0.8, 0.2, 1),
              border-color 0.2s ease;
}

.card:hover {
  transform: translateY(-2px);
  border-color: var(--accent-subtle);
}

/* NEVER: shadow on default state + bigger shadow on hover → 2018 pattern */
/* NEVER: card inside card */
/* NEVER: side-stripe accent border */
```

---

## 10. The "Last 5%" Details

These are the details that separate "good" from "excellent":

### Custom selection color
```css
::selection {
  background: oklch(0.85 0.08 var(--hue));
  color: var(--text-primary);
}
```

### Smooth scroll with reduced-motion respect
```css
html {
  scroll-behavior: smooth;
}
@media (prefers-reduced-motion: reduce) {
  html { scroll-behavior: auto; }
}
```

### Focus-visible (keyboard only, not click)
```css
:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
  border-radius: 2px;
}
:focus:not(:focus-visible) {
  outline: none;
}
```

### Balanced text wrap for headings
```css
h1, h2, h3 {
  text-wrap: balance;
}
p {
  text-wrap: pretty; /* Avoids orphans on last line */
}
```

### Smooth font rendering
```css
body {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-rendering: optimizeLegibility;
}
```

---

## Self-audit before declaring Phase 4 complete

- [ ] HTML is semantic (`<header>`, `<main>`, `<section>`, `<footer>`, `<nav>`)
- [ ] Type scale uses `clamp()` for fluid sizing
- [ ] All colors use oklch with brand hue tinting
- [ ] Maximum 2 font families loaded (+ 1 mono if needed)
- [ ] All images have width/height/alt
- [ ] Above-fold images: `fetchpriority="high"`, no `loading="lazy"`
- [ ] Below-fold images: `loading="lazy"` + `decoding="async"`
- [ ] Animations use transform/opacity only (GPU-safe)
- [ ] `prefers-reduced-motion` respected
- [ ] `prefers-color-scheme` supported (if dark mode relevant)
- [ ] ONE primary CTA per viewport
- [ ] Real copy throughout — no placeholders
- [ ] `min-h-[100dvh]` not `h-screen`
- [ ] Mobile layout is RECOMPOSED, not shrunk
