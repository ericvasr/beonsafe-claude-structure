# Impeccable Commands — 23-Command Palette

> Adapted from [pbakaus/impeccable](https://github.com/pbakaus/impeccable), licensed
> under the Apache License 2.0 (Copyright 2025 Paul Bakaus). **This file is modified from
> the original**: the commands were re-selected, rewritten and reorganised as workflow
> templates; no text was copied verbatim. See `../PROCEDENCIA.md` and
> `../../../licenses/Apache-2.0.txt`.

Each command is a workflow template — load the relevant one when the user asks for that specific operation.

## How to invoke

User types `/front <command> <target>` OR speaks naturally ("audit this page", "polish the hero", "make it bolder"). Map natural language to the closest command, then execute the workflow.

## Command index (by category)

### Build (start from intent or blank)

| Command | Purpose | Output |
|---------|---------|--------|
| `craft` | Shape, then build feature end-to-end | Full working surface |
| `shape` | Plan UX/UI before any code | Spec + wireframe + decisions doc |
| `teach` | Set up PRODUCT.md + DESIGN.md | Context files that anchor every later run |
| `document` | Generate DESIGN.md from existing code | Reverse-engineered design tokens + components |
| `extract` | Pull tokens/components into a design system | Reusable system files |

### Evaluate (judge existing)

| Command | Purpose | Output |
|---------|---------|--------|
| `critique` | UX design review with heuristic scoring | 5D radar (philosophy/hierarchy/craft/function/innovation) + punch list |
| `audit` | Technical: a11y, performance, responsive | Pass/fail report + fixes |

### Refine (improve existing)

| Command | Purpose |
|---------|---------|
| `polish` | Final quality pass before shipping |
| `bolder` | Amplify safe / bland designs |
| `quieter` | Tone down aggressive designs |
| `distill` | Strip to essence, remove complexity |
| `harden` | Production-ready: errors, i18n, edge cases |
| `onboard` | First-run flows, empty states |

### Enhance (add depth)

| Command | Purpose |
|---------|---------|
| `animate` | Add purposeful animations and motion |
| `colorize` | Add strategic color to monochromatic UIs |
| `typeset` | Improve typography hierarchy and fonts |
| `layout` | Fix spacing, rhythm, visual hierarchy |
| `delight` | Add personality and memorable touches |
| `overdrive` | Push past conventional limits (use sparingly) |

### Fix (target specific issues)

| Command | Purpose |
|---------|---------|
| `clarify` | Improve UX copy, labels, error messages |
| `adapt` | Adapt for different devices / screen sizes |
| `optimize` | Diagnose and fix UI performance |

### Iterate (visual variants)

| Command | Purpose |
|---------|---------|
| `live` | Pick elements, generate alternatives on the fly |

---

## Detailed workflows

### `craft <target>` — Build end-to-end

1. **Shape first**. Run `shape` mentally even if not called. State 1-sentence purpose, primary user, primary action, anti-references.
2. **Pick register** (brand vs product) and direction (from `design-philosophies.md`).
3. **Set dials** (from `taste-dials.md`).
4. **Build the spine first**: structure, type system, color tokens, spacing. NOT pretty details.
5. **Fill in critical surfaces**: hero, primary action, key data.
6. **Polish pass**: anti-pattern audit, micro-interactions, copy refinement.
7. **Verify** via Playwright (load `playwright-verification.md`).

### `shape <target>` — Plan before code

Output a brief that includes:
- **Purpose**: 1 sentence
- **Primary user**: who, what mood, what device
- **Primary action**: the one thing they're here to do
- **Surface hierarchy**: what's most important, second, third
- **Information architecture**: sections + their role
- **Anti-references**: what this should NOT look like
- **DNA**: philosophy + dials + palette + type pairings
- **Risks**: edge cases, accessibility concerns, perf concerns

If anything is unclear, ask the user ONE batched clarification (not iterative).

### `audit <target>` — Technical evaluation

Run these checks (paste-and-fix style):

| Dimension | Check | Tool |
|-----------|-------|------|
| Accessibility | Color contrast (WCAG AA min), keyboard nav, ARIA roles, focus visible, semantic HTML | Playwright a11y snapshot + manual review |
| Performance | LCP < 2.5s, CLS < 0.1, INP < 200ms, bundle size sanity | Lighthouse / Playwright network panel |
| Responsive | 320px, 768px, 1024px, 1440px breakpoints work | Playwright multi-viewport |
| Cross-browser | Chromium baseline + Firefox + WebKit sanity | Playwright cross-browser |
| Console | Zero errors, warnings explained | Playwright console |
| Network | No 404s, no oversized assets (>500kB without reason) | Playwright network |
| Semantic | Headings hierarchy correct (one `<h1>`, descending), landmarks present | DOM inspection |

Output: pass/fail per dimension + concrete fix per failure (with diff).

### `critique <target>` — UX review

Score on 5 dimensions, 0–10 each:

1. **Philosophy coherence** — does the design embody one direction or average many?
2. **Visual hierarchy** — does the eye know where to go?
3. **Execution craft** — micro-details: spacing, alignment, type rhythm, color discipline
4. **Functionality** — does the UI serve the action? Or decorate?
5. **Innovation** — does it surprise anywhere? Or play it safe?

Output:
- Radar chart (text or HTML)
- **Keep**: 3 things that are working
- **Fix**: top 5 issues with severity (CRITICAL / HIGH / MEDIUM / LOW)
- **Quick wins**: 3 fixes that take < 5 minutes each
- **Strategic moves**: 1-2 bigger changes that would lift the whole

### `polish <target>` — Pre-ship pass

Final QA pass before declaring done:
- Run `audit` (technical)
- Run `critique` (subjective)
- Fix everything CRITICAL and HIGH
- Ensure all copy is real (no Lorem, no Acme, no John Doe)
- Ensure all states exist: default, hover, focus, active, disabled, loading, empty, error
- Tighten spacing rhythm (consistent vertical scale)
- Ensure motion respects `prefers-reduced-motion`
- Verify in Playwright at 3 viewports

### `bolder <target>` — Amplify safe designs

Diagnostic: the design is competent but invisible. Apply:
- Stronger type scale contrast (hero ≥ 3x body)
- Commit harder to one color direction (move from Restrained to Committed on the four-step axis)
- One memorable micro-detail (kinetic type / spotlight / asymmetric crop / unexpected hover)
- Strip 1-2 things to make room for the bold move

### `quieter <target>` — Tone down loud designs

Diagnostic: design is screaming. Apply:
- Reduce chroma across the palette
- Cut gradients to flat
- Increase whitespace by ≥30%
- Remove decorative animations; keep functional micro-feedback only
- Pick ONE moment to be loud — silence the rest

### `distill <target>` — Strip to essence

Remove until removing more breaks the design. Apply:
- Delete every decoration that doesn't serve hierarchy or function
- Collapse redundant sections (two CTAs → one)
- Reduce type weights used (target 2 weights max)
- Reduce color count (target 3 colors max + neutrals)

### `harden <target>` — Production readiness

- Empty states (no data, first-run, search no results)
- Loading states (skeleton, spinner, progressive disclosure)
- Error states (network down, validation, permissions)
- Edge cases (very long names, missing avatars, RTL, accessibility)
- i18n considerations (string length variance, RTL, dates)
- Browser support documented

### `animate <target>` — Add motion

- **Purposeful only**: motion should communicate (state change, hierarchy, attention)
- Spring physics for delight, cubic-bezier for utility
- Stagger reveals (`staggerChildren: 0.05`) for groups
- Always respect `prefers-reduced-motion`
- See `motion-pipeline.md` for full animation system

### `colorize <target>` — Add strategic color

Move from monochrome to colored without going garish:
- Identify the 1-2 places color earns its presence (primary action, brand moment)
- Pick the chroma carefully (oklch 0.10–0.18 is usually the sweet spot)
- Tint neutrals toward the new accent (avoid floating-color effect)

### `typeset <target>` — Type hierarchy

- Audit current type scale; check ratio (1.25 / 1.333 / 1.5 — pick one)
- Audit weight contrast; aim for ≥ 300 unit gap between hierarchical levels
- Verify body line-height (1.45–1.6 for sans, 1.5–1.7 for serif)
- Verify line-length (45–75ch for body, 25–45ch for narrow columns)
- Replace any banned fonts with distinctive alternatives

### `layout <target>` — Spacing and rhythm

- Apply a consistent vertical rhythm (multiples of 4 or 8)
- Identify the grid (usually 12-col but could be 6 / 8 / asymmetric)
- Fix alignment failures (text + image not on same baseline, etc)
- Break the grid intentionally in 1-2 spots if VARIANCE ≥ 6

### `delight <target>` — Memorable touches

Add ONE-TO-THREE moments that the user will screenshot:
- Easter egg interaction
- Custom-drawn detail (not from icon library)
- Unexpected hover state
- Sound feedback (sparingly)
- Personality copy moment

Constraint: each moment must justify the JS/CSS cost. No delight-for-delight's-sake.

### `overdrive <target>` — Push past conventional limits

Use rarely. When the brief justifies an "Awwwards-tier" approach:
- Full-bleed scroll-jacking sequences
- WebGL / particle systems
- Custom cursor (with accessibility fallback)
- Magnetic interactions
- Audio-reactive elements

Pair with a strict `prefers-reduced-motion` fallback.

### `clarify <target>` — UX copy

- Rewrite vague CTAs to specific actions
- Replace marketing clichés ("Seamless", "Empower") with concrete verbs
- Tighten error messages (state what failed + what to do)
- Make empty states actionable (not just "No results")
- Match tone to register (brand = personality, product = utility)

### `adapt <target>` — Multi-device

- 320px (small mobile)
- 390px (iPhone Pro)
- 768px (tablet portrait)
- 1024px (tablet landscape / small laptop)
- 1440px (desktop)
- 1920px+ (large display)

Test each breakpoint. Don't let anything reflow into illegibility. Use `clamp()` for fluid typography.

### `optimize <target>` — UI performance

- Replace JPG/PNG with WebP/AVIF
- Lazy-load below-fold images
- Defer non-critical JS
- Trim unused CSS
- Audit largest contentful paint, fix the culprit
- Avoid layout-triggering animations

### `live <target>` — Variant iteration

The "design playground" mode. Given a component, generate 3+ variants across a dimension:
- Color variants (Restrained / Committed / Drenched)
- Layout variants (centered / asymmetric / split)
- Motion variants (static / fluid / cinematic)
- Density variants (airy / daily / cockpit)

Show side-by-side. Let user pick. Lock the winner. Iterate again on the next dimension.

---

## Register-based defaults

Each command behaves differently in **Brand** register vs **Product** register.

| Command | Brand defaults | Product defaults |
|---------|----------------|------------------|
| `craft` | Asymmetric hero, custom illustration, big type, motion-on-load | Standard grid, clear info hierarchy, instant feedback, minimal motion |
| `polish` | Add brand-moment detail | Tighten micro-feedback, fix every empty/error state |
| `colorize` | One saturated color story | Restrained: neutrals + semantic colors (info/warn/error/success) |
| `animate` | Hero reveals, scroll-triggered | Micro-interactions only (hover, focus, state change) |

If the register isn't obvious from context, ask the user one batched question:
> "Is this a brand surface (marketing, landing, pitch deck) or a product surface (internal tool, dashboard, settings)?"

---

## Output format for every command

After running any command, output:

```
## /front <command> · result

**Direction**: <philosophy/DNA used>
**Dials**: VARIANCE <n>, MOTION <n>, DENSITY <n>
**Register**: <brand|product>

### Changed
- <file>: <one-line summary of change>
- <file>: ...

### Verified
- Playwright screenshot: <viewport> ✓
- Console: 0 errors ✓
- a11y snapshot: <pass/issues>

### Next moves
- /front polish — final pass
- /front audit — technical check
- /front live <element> — try variants
```

This makes iteration cheap because the user always knows where to go next.
