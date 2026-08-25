# Taste Dials — Parametric Variance System

Adapted from Leonxlnx/taste-skill. Three 1–10 dials that tune every design decision. Defaults are intentional, not safe.

## The three dials

```
DESIGN_VARIANCE   = 8    (1=symmetric/predictable, 10=artsy chaos)
MOTION_INTENSITY  = 6    (1=static, 10=cinematic magic physics)
VISUAL_DENSITY    = 4    (1=art gallery, 10=pilot cockpit)
```

These defaults intentionally bias toward boldness. Adjust based on user signal.

---

## DESIGN_VARIANCE — layout boldness

| Value | Behavior |
|-------|----------|
| 1–3 | Symmetric, predictable, centered. Three-column grids, centered hero, mirrored layouts. (Avoid; this is the AI default. Only use if user explicitly wants this.) |
| 4–7 | Offset, varied aspect ratios, asymmetric hero, alternating section directions. Sweet spot for most product / brand work. |
| 8–10 | Masonry / asymmetric / massive empty zones. Bento with intentional gaps. Editorial scroll. Use for premium brand work, portfolios, pitch decks. |

**Implementation cue**: at VARIANCE ≥ 8, prefer CSS Grid with explicit `grid-template-areas`. Never use `repeat(3, 1fr)` for the main page body when VARIANCE ≥ 6.

---

## MOTION_INTENSITY — animation depth

| Value | Behavior |
|-------|----------|
| 1–3 | Static. Only hover-state color changes. Use for dense data tools, accessibility-first surfaces, focused work apps. |
| 4–7 | Fluid CSS transitions. Spring-physics micro-interactions. Subtle scroll reveals. Default for most product / brand work. |
| 8–10 | Framer Motion / Anime.js / Lottie. Scroll-triggered orchestration. Parallax. Magnetic cursors. Use for brand launches, portfolios, premium showcases. |

**Implementation cue**:
- At MOTION ≥ 6: use `useMotionValue` (never `useState` for continuous animation values).
- At MOTION ≥ 8: include a `prefers-reduced-motion` fallback that strips to MOTION 3 behavior.
- Always GPU-safe: `transform` and `opacity` only.

---

## VISUAL_DENSITY — information per square inch

| Value | Behavior |
|-------|----------|
| 1–3 | Art gallery / airy. Massive whitespace. One idea per screen. Use for luxury brand, editorial, mindfulness. |
| 4–7 | Daily app mode. Normal padding, comfortable scan. Default for most B2C product surfaces. |
| 8–10 | Cockpit mode. Tight padding (4–8px), monospace numbers, 1px borders only, no decoration. Use for terminals, ops dashboards, dev tools, finance trading UIs. |

**Implementation cue**:
- At DENSITY ≥ 8: type stack flips to `JetBrains Mono` / `IBM Plex Mono` for numeric data. Borders 1px solid, no shadows, no rounded radii (or `radius: 2px` max).
- At DENSITY ≤ 3: type stack uses serif display (`Newsreader`, `Source Serif`), generous line-height (1.6+), massive section padding (96px+).

---

## How to read user signals → dial settings

| User says | DIAL adjust |
|-----------|-------------|
| "more dramatic", "premium", "agency-level" | VARIANCE +2, MOTION +2 |
| "calmer", "simpler", "less noise" | VARIANCE −2, MOTION −2, DENSITY −1 |
| "data-heavy", "operations dashboard", "ops cockpit" | DENSITY 8+, MOTION ≤ 4 |
| "luxury", "editorial", "magazine" | DENSITY 2, VARIANCE 6+, MOTION 4 |
| "I'll show this to investors" | VARIANCE 8+, MOTION 7+, DENSITY 4 |
| "internal tool, doesn't need to be pretty" | VARIANCE 4, MOTION 3, DENSITY 6+ |
| "minimalist" | DENSITY 2-3, VARIANCE 3-5, MOTION 3-4 |
| "alive", "feels like it's breathing" | MOTION 6+, include perpetual micro-animations |

---

## Specialised variants (taste-skill sub-skills)

When the user mentions one of these aesthetics, jump to the variant defaults — these are pre-tuned dial settings + tighter constraints.

### `soft-skill` — Awwwards-tier agency
**Dials**: VARIANCE 8, MOTION 7, DENSITY 3
- Pick ONE vibe: ethereal glass / editorial luxury / soft structuralism
- Pick ONE layout: asymmetrical bento / Z-axis cascade / editorial split
- **Double-Bezel** (doppelrand): nested enclosure architecture — outer shell + inner core
- Magnetic button physics, 800ms+ fade-up scroll reveals, grain overlay (fixed elements only)
- Bans (in addition to global): Inter, thick Lucide strokes, generic 1px gray borders, harsh shadows, sticky navbars, linear easing

### `brutalist-skill` — Swiss industrial / Tactical telemetry
**Dials**: VARIANCE 6 (rigid grid), MOTION 3 (static-feel), DENSITY 8
- Two flavors:
  - **Swiss Industrial Print**: light mode, single red accent, heavy sans + minimal serif
  - **Tactical Telemetry**: dark mode, terminal aesthetic, CRT scanlines, halftone dithering, ASCII framing, crosshairs
- Bans: gradients, soft shadows, glassmorphism, rounded corners (or `radius: 0–2px` max), nested cards
- Type: monospace + heavy sans-serif (Druk, Aktiv Grotesk Black) + sparse serif processed

### `minimalist-skill` — Editorial monochrome
**Dials**: VARIANCE 5, MOTION 4, DENSITY 3
- Warm bone background `#F7F6F3`, 1px `#EAEAEA` borders, diffuse shadows (opacity < 0.05)
- Serif headers (Lyon / Newsreader / Playfair) + sans body (Geist / Switzer) + mono data (Geist Mono / JetBrains)
- Pale pastel accents: red `#FDEBEC`, blue `#E1F3FE`, green `#EDF3EC`, yellow `#FBF3DB`
- Bans (additional): `rounded-full` for large containers, primary colored backgrounds, AI copy clichés

### `image-to-code-skill` — Image-first website pipeline
**Workflow**: generate reference images → analyse → implement
- Use when user provides screenshots / image references
- Or when running an image-gen pre-step (Midjourney, DALL-E, Stable Diffusion)
- Critical: hero section quality (clean, spacious, readable on small laptops)
- Bans: single giant compressed page-image, tiny text, centered hero clichés, card spam, unextractable designs

### `redesign-skill` — Audit-then-fix existing
- Don't rewrite; identify generics + apply targeted fixes
- Run `audit` (technical) + `critique` (subjective) from impeccable-commands
- Target the highest-impact 3-5 issues; ignore minor cosmetic ones unless asked

### `stitch-skill` — Google Stitch-compatible
- Optional `DESIGN.md` export format
- Use when user wants design tokens that integrate with Google Stitch ecosystem

---

## Required scaffolding (regardless of dial settings)

These constraints apply to every output, modulated by but not skippable:

1. **Dependency verification**: check `package.json` BEFORE importing any library. Don't assume Framer Motion is there if user is on plain CSS.
2. **Spring physics over easing curves** at MOTION ≥ 5: `stiffness: 100, damping: 20` is the default starting point.
3. **`min-h-[100dvh]`** instead of `h-screen` — always.
4. **Grid > complex flex math**: CSS Grid for multi-column, never `flex-basis: 23.5%`.
5. **Phosphor / Radix icons** at consistent weight. Customize the shadcn defaults if used.
6. **Perpetual micro-interactions** at MOTION ≥ 6: at least one element on the page should be alive (pulse, shimmer, breathe, float) — isolated in its own Client Component to avoid re-render thrash.
7. **GPU-safe properties** for all motion: `transform`, `opacity`, `filter`.
8. **Z-index hygiene**: reserved layers (modal 1000, toast 900, nav 100, overlay 50). No `z-50` spam.

---

## Pre-flight checklist (run at the end)

7 binary checks:

- [ ] Global state used only where prop-drilling would be silly
- [ ] Mobile layout collapses correctly (no horizontal scroll at 320px)
- [ ] `min-h-[100dvh]` used for full-height sections
- [ ] `useEffect` cleanup functions present (for any listener / interval / animation frame)
- [ ] Empty / loading / error states included for every async surface
- [ ] No cards-inside-cards
- [ ] Perpetual animations isolated in own Client Components (don't trigger parent re-renders)

If any unchecked, fix.

---

## How `/front` uses these dials

When the orchestrator routes a task:

```
1. Detect explicit dial mentions in user prompt
   → set those values
2. Detect variant trigger words (brutalist, minimal, agency, dashboard)
   → load the matching variant defaults
3. Fall back to global defaults (VARIANCE 8, MOTION 6, DENSITY 4)
4. State the chosen dials in the design DNA prompt for traceability
```

The dials are not decoration — they drive every default choice from type scale to corner radii to padding to motion duration.
