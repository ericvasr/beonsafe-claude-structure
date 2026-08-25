# Page Architecture — How World-Class Pages Are Structured

A great page is not a stack of sections. It's a **narrative** — each section advances a story, builds on the previous, and leads the eye toward action.

Load this during Phase 3 (Architect) and Phase 4 (Create).

---

## The Scroll Narrative Principle

Every page tells a story through scrolling. The story follows one of these arcs:

### Arc A — The Pitch (marketing / landing)

```
1. HOOK        → Hero: what is this? Why should I care? (1 sentence + 1 visual)
2. PROVE       → Social proof / metrics / logos (you're not the first to trust this)
3. SHOW        → Features / capabilities (here's what it does, concretely)
4. EXPLAIN     → How it works (so simple you can see yourself doing it)
5. VALIDATE    → Testimonials / case studies (real people, real results)
6. CONVERT     → CTA section (specific action, clear value, low friction)
7. GROUND      → Footer (navigation, legal, trust signals)
```

### Arc B — The Dashboard (product / app)

```
1. ORIENT      → What am I looking at? KPIs, status, time range
2. ALERT       → What needs attention right now? Anomalies, warnings
3. DRILL       → Detailed data, expandable sections, charts
4. ACT         → Controls, filters, actions I can take
5. CONTEXT     → Supporting information, logs, history
```

### Arc C — The Story (brand / agency / portfolio)

```
1. INTRIGUE    → Full-screen moment that creates curiosity
2. CONTEXT     → Who is behind this? What do they believe?
3. EVIDENCE    → Work / projects / impact (show, don't tell)
4. DETAIL      → Deep dive on selected work
5. CONNECT     → Contact / hire / collaborate CTA
```

### Arc D — The Tool (developer / technical product)

```
1. WHAT        → One sentence: what this does
2. CODE        → Live code example or interactive demo (the product IS the hero)
3. WHY         → Key benefits (speed, DX, reliability — concrete, not buzzwords)
4. HOW         → Getting started in < 5 minutes
5. DEPTH       → Documentation links, advanced features
6. COMMUNITY   → GitHub stars, contributors, Discord
7. START       → Final CTA: get started now
```

---

## Section Composition Patterns

### Pattern 1 — Feature showcase (NOT three equal cards)

**Bad**: Three identical cards with icon + title + paragraph. This is the #1 AI default.

**Good alternatives**:

#### Bento layout
```
┌──────────────────┬────────┐
│                  │        │
│   Feature 1      │ Feat 2 │
│   (large, hero)  │        │
│                  │        │
├────────┬─────────┴────────┤
│        │                  │
│ Feat 3 │   Feature 4      │
│        │   (large)        │
└────────┴──────────────────┘
```

#### Alternating split (zigzag)
```
┌──────────────┬──────────────┐
│   Content    │    Visual    │
│   left       │    right     │
├──────────────┼──────────────┤
│   Visual     │   Content    │
│   left       │    right     │
├──────────────┼──────────────┤
│   Content    │    Visual    │
│   left       │    right     │
└──────────────┴──────────────┘
```

#### Featured + grid
```
┌────────────────────────────┐
│    Featured item (full)    │
├────────┬─────────┬─────────┤
│ Item 2 │ Item 3  │ Item 4  │
└────────┴─────────┴─────────┘
```

### Pattern 2 — Social proof

**Bad**: Logo strip with 6 gray logos in a row.

**Good alternatives**:

#### Marquee ticker (infinite scroll)
```
─── Logo1 ── Logo2 ── Logo3 ── Logo4 ── Logo5 ── Logo1 ── Logo2 ──→
```
With CSS: `animation: scroll 30s linear infinite`

#### Contextual proof
Instead of just logos, pair each with a metric:
```
┌─────────────────────────────────────────┐
│  "Reduced deploy time by 73%"            │
│  — Maria Santos, SRE Lead at [Company]   │
│  [Company logo]                          │
└─────────────────────────────────────────┘
```

#### Trust stack
```
┌──────────────────────────────────────┐
│  Used by 2,847 teams                 │
│  ★★★★★ 4.9 on G2 (312 reviews)     │
│  SOC 2 Type II certified            │
│  [Logo1] [Logo2] [Logo3] [Logo4]    │
└──────────────────────────────────────┘
```

### Pattern 3 — Pricing

**Bad**: Three equal columns, middle one highlighted, "Most Popular" badge.

**Good alternatives**:

#### Two-tier with emphasis
```
┌──────────────────┬──────────────────────────┐
│                  │                          │
│   Free           │   Pro                    │
│   (compact)      │   (expanded, branded)    │
│                  │                          │
└──────────────────┴──────────────────────────┘
      Enterprise? Talk to us →
```

#### Feature comparison table
Instead of cards, a table that shows EXACTLY what you get at each tier.

### Pattern 4 — CTA section

**Bad**: Generic "Ready to get started?" with two buttons.

**Good alternatives**:

#### Value-first CTA
```
┌──────────────────────────────────────┐
│  Start monitoring in 2 minutes.      │
│  No credit card. No setup wizard.    │
│                                      │
│  [Enter your email] [Start free →]   │
└──────────────────────────────────────┘
```

#### Social proof CTA
```
┌──────────────────────────────────────┐
│  Join 2,847 SRE teams who sleep      │
│  better at night.                    │
│                                      │
│  [Start free trial →]                │
│                                      │
│  "Set up took 3 minutes" — @user     │
└──────────────────────────────────────┘
```

---

## Section Rhythm Rules

### Density alternation

Never put two dense sections back-to-back. Alternate:
```
DENSE (features)  →  BREATHING (quote/social proof)  →  DENSE (how it works)  →  BREATHING (CTA)
```

### Background color rhythm

```
Light  →  Subtle tint  →  Light  →  Dark accent  →  Light  →  Brand color CTA
```

Never: same background color in adjacent sections (looks like one mega-section).

### Vertical spacing scale

```css
/* Section padding — use DIFFERENT values for different sections */
.section-hero     { padding-block: clamp(4rem, 10vh, 8rem); }
.section-content  { padding-block: clamp(5rem, 10vh, 8rem); }
.section-breathe  { padding-block: clamp(3rem, 6vh, 5rem); }  /* Lighter sections */
.section-cta      { padding-block: clamp(5rem, 12vh, 10rem); }
```

---

## Responsive Architecture

### Mobile is not "desktop shrunk"

Mobile requires RECOMPOSITION, not reduction:

| Desktop pattern | Mobile recomposition |
|----------------|---------------------|
| Two-column split | Stack, visual ABOVE content (visual hooks attention) |
| Bento 4-card grid | Single column, featured card larger, rest compact |
| Feature zigzag | Stack, all visual → content (consistent reading flow) |
| Pricing 3 columns | Horizontal scroll or accordion |
| Data table | Card list or horizontal scroll container |
| Navigation bar | Bottom sheet or hamburger (prefer bottom sheet for key actions) |

### Breakpoint strategy

```css
/* Mobile-first: design for 320px, enhance upward */
/* 320px — small phone (constraint test) */
/* 390px — modern phone (design target) */
/* 768px — tablet portrait */
/* 1024px — tablet landscape / small laptop */
/* 1280px — standard laptop */
/* 1440px — design canvas (primary desktop target) */
/* 1920px+ — large display (max-width container, not stretch) */

.container {
  width: 100%;
  max-width: 1280px;
  margin-inline: auto;
  padding-inline: clamp(1.25rem, 4vw, 3rem);
}
```

### Touch target rules (mobile)

- Minimum 44×44px touch targets
- 8px minimum gap between touch targets
- Primary actions: bottom of screen (thumb zone)
- Destructive actions: require confirmation, never in thumb zone

---

## Navigation Architecture

### For single-page (landing)

```html
<nav>
  <a href="/" class="logo">Brand</a>
  <div class="nav-links">
    <a href="#features">Features</a>
    <a href="#pricing">Pricing</a>
    <a href="#docs">Docs</a>
  </div>
  <a href="#signup" class="nav-cta">Get started</a>
</nav>
```

Sticky on scroll, shrinks slightly. Transparent on hero, solid on scroll.

```css
.nav {
  position: sticky;
  top: 0;
  z-index: 100;
  backdrop-filter: blur(12px);
  background: oklch(0.99 0.003 var(--hue) / 0.85);
  transition: background 0.3s ease;
}
```

### For multi-page (app/site)

- **Top nav**: brand + primary navigation + user menu
- **Side nav** (apps): persistent on desktop, overlay on mobile
- **Breadcrumbs**: for deep hierarchies (> 2 levels)
- **Footer nav**: secondary links, legal, social

### Navigation anti-patterns

- Hamburger menu on desktop (hides navigation that should be visible)
- More than 7 top-level nav items (cognitive overload)
- Dropdown menus that disappear when moving diagonally to them
- "Mega menu" for < 20 total links (overkill)

---

## Information Density by Page Type

| Page type | Density | Whitespace | Typography | Motion |
|-----------|---------|-----------|-----------|--------|
| **Marketing landing** | Low (3-4) | Generous (40%+) | Display serif or bold sans | Scroll reveals, hero animation |
| **Product page** | Medium (5-6) | Balanced (25-35%) | Clean sans, clear hierarchy | Micro-interactions on hover |
| **Dashboard** | High (7-9) | Tight (10-20%) | Mono for data, sans for labels | Functional only (loading, transitions) |
| **Documentation** | Medium (5-6) | Reading-optimized (30%+) | Serif body, sans headings | None (content is king) |
| **Portfolio** | Low (2-4) | Massive (50%+) | Statement display face | Image transitions, scroll narrative |
| **E-commerce PDP** | Medium (5-7) | Balanced | Clean sans, price prominent | Image zoom, cart micro-feedback |
| **Blog/editorial** | Medium (4-5) | Reading columns (60-75ch) | Serif body, 1.6+ line-height | None or subtle reveals |

---

## The Architecture Checklist

Before moving to Phase 4 (Create), verify:

- [ ] Scroll narrative defined (which arc? what story does scrolling tell?)
- [ ] Section sequence locked (each section has a PURPOSE in the narrative)
- [ ] Density rhythm planned (alternating dense/breathing sections)
- [ ] Background color rhythm planned (no same-color adjacent)
- [ ] Responsive strategy defined (RECOMPOSE for mobile, not shrink)
- [ ] Navigation pattern chosen (appropriate for page type)
- [ ] Breakpoints identified (where does the layout fundamentally change?)
- [ ] Container width locked (usually 1280px max with padding)
- [ ] Section spacing scale defined (not uniform — intentional rhythm)
- [ ] Grid system chosen (12-col for complex, simpler for editorial)
- [ ] One memorable moment planned (where in the scroll does it happen?)
