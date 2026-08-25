# Brand Asset Protocol — 5-Step Gathering

Adapted from huashu-design's Core Asset Protocol (v1.1, 2026-04-20). Use this **whenever a specific brand is mentioned in the task** (Stripe, the user's company, a client, etc).

## Why this is mandatory for brand work

> Asset > Spec. A brand is "being recognized." If you can't deliver recognition, you've made generic design with a label slapped on.

Recognition hierarchy by contribution to brand identity:

| Asset type | Contribution | Mandatory for |
|-----------|--------------|----------------|
| **Logo** | Highest — any brand uses theirs for instant recognition | ALL brand work |
| **Product renders** | Extreme — hardware/products are "the hero" | Physical products |
| **UI screenshots** | Extreme — digital products = their interface | SaaS / apps |
| **Color values** | Medium — auxiliary, prevent confusion | All |
| **Fonts** | Low — only useful after the above are in place | All |
| **Tone keywords** | Low — for agent self-check | All |

**Real failure mode (true incident, huashu 2026-04-20):** Designer assumed Kimi's brand was orange from memory. Actual brand color is `#1783FF` blue. Cost: 1-2 hour rework. Another (more recent): a design for Lovart grabbed the "user-demo brand color" from a product screenshot (which was the demo product, not Lovart) — almost destroyed the entire design.

**The lesson:** never guess from memory. Always extract from official source.

## The 5-step protocol

```
Step 1 - Ask         Checklist of 6 asset types (don't ask vaguely)
Step 2 - Search      5 official channels per asset
Step 3 - Download    Per asset type, in priority order
Step 4 - Verify      Resolution, copyright, freshness, exact hex
Step 5 - Freeze      Write brand-spec.md with paths, hexes, vars
```

### Step 1 — Ask the user (one batched checklist)

Do NOT ask "what's the brand"? Ask precisely:

> "For brand-specific design, I need at least 3 of these. Which can you provide / point me to?
> 
> 1. **Logo** — official SVG or URL to download from (e.g., `<brand>.com/brand`)
> 2. **Product photos / renders** — official hi-res images (for physical products)
> 3. **UI screenshots** — current product screens (for SaaS/apps)
> 4. **Color hex values** — official palette (we'll extract from logo if missing)
> 5. **Fonts** — name of brand typography (we'll match similar if missing)
> 6. **Brand guidelines doc** — PDF / Notion / Figma if you have it
>
> Anything I'm missing, I'll search official sources and verify with you."

### Step 2 — Search official channels (per asset, 5 channels)

For each missing asset:

| Asset | Channels (in order) |
|-------|---------------------|
| Logo | `<brand>.com/brand` → `<brand>.com/press` → `brand.<brand>.com` → social profiles (Twitter avatar, LinkedIn) → Wikipedia commons |
| Product render | Official product page → press kit → launch event video frames (Apple-style keynote) → e-commerce listing → AI-generated FROM REFERENCE (last resort) |
| UI screenshot | App Store / Play Store → official YouTube launch video frames → reviews on tech sites → live product (if accessible) |
| Color hex | Logo SVG `<path fill="...">` → brand guidelines PDF → website CSS → screenshot eyedropper |
| Fonts | Brand guidelines doc → website CSS `font-family` → press kit |

Use WebFetch / WebSearch as needed.

### Step 3 — Download by priority

For each asset, prefer formats in this order:

| Asset | Format priority |
|-------|-----------------|
| Logo | SVG (inline) > SVG (file) > PDF > PNG (large) > rasterised from social avatar |
| Product render | PNG / JPG ≥ 2000px wide > 1000px > AI-generated from reference (last resort) |
| UI screenshot | Official > video frame screenshot > tech review article screenshot |

### Step 4 — Verify and extract

Quality bar (called the "5-10-2-8" gate, except for logo):

- **Logo**: if it exists, you must use it. Not a multi-choice problem.
- **Other assets** (product / UI / reference):
  - Search at least **5** channels
  - Find at least **10** candidates
  - Select the **2** best
  - Each must score ≥ **8/10** on the eight dimensions below

**8 dimensions for asset selection:**

1. Resolution ≥ 2000px on long side
2. Copyright is clear (official source, brand kit, press release with usage terms)
3. Mood matches the project direction
4. Visual consistency with other selected assets
5. Independent narrative (the asset says something on its own)
6. Not stock-photo-feeling
7. Not low-light / awkward angle / cluttered
8. Is FRESH (current product version, not 3 years stale)

A 7/10 asset is a **negative** signal. Better to omit and use an honest placeholder than ship a weak asset.

**Color extraction:**

1. Open the brand logo SVG in a text editor
2. Find `<path fill="..."/>` — that's the canonical hex
3. If the logo uses multiple colors, cross-reference with screenshots
4. Convert hex → oklch (use DevTools color picker or online converter)
5. NEVER use a color you eyeballed from a JPG. JPG compression shifts colors by 5-10 hex points.

### Step 5 — Freeze the spec

Write `brand-spec.md` at the project root. This becomes the single source of truth.

```markdown
# Brand spec — <Brand Name>

## Assets

### Logo
- File: `assets/brand/logo.svg`
- Source: https://<brand>.com/brand (downloaded 2026-05-21)
- Variants: full-color, monochrome black, monochrome white, icon-only

### Product renders
- File: `assets/brand/product-hero.png` (3200×1800)
- Source: <brand>.com/products/<name> (downloaded 2026-05-21)
- License: brand press kit, free for editorial use

### UI screenshots
- File: `assets/brand/app-home.png` (1440×900)
- Source: App Store screenshots (downloaded 2026-05-21)

## Colors (extracted from logo SVG)

```css
:root {
  /* Primary palette */
  --brand-primary: #1783FF;       /* oklch(0.62 0.21 250) */
  --brand-primary-hover: #0F6CDB; /* oklch(0.55 0.21 250) */
  --brand-primary-active: #0954B0;/* oklch(0.48 0.21 250) */

  /* Secondary */
  --brand-accent: #FFCC00;        /* oklch(0.85 0.18 95) */

  /* Neutrals (tinted toward brand hue) */
  --ink: #0A1F35;                 /* oklch(0.20 0.06 250) */
  --mute: #6B7B8C;                /* oklch(0.55 0.03 250) */
  --surface: #F4F8FC;             /* oklch(0.97 0.01 250) */
  --border: #DCE5EE;              /* oklch(0.90 0.015 250) */
}
```

## Typography

- Display: Söhne Buch (per brand guidelines doc, page 12)
- Body: Söhne Buch
- Mono: SF Mono (system fallback)
- Substitutes if Söhne unavailable: Inter → ❌ banned. Use General Sans 500 as the closest match.

## Tone keywords

(For self-check, not for copy)
- Confident not arrogant
- Modern not trendy
- Precise not pedantic
- Warm not cute

## Anti-references (from brand guidelines or our judgement)

- Never look like generic SaaS
- Never look like a bank
- Never look like Linear (intentional differentiation)
- Never use purple gradients
```

This spec file becomes the contract. Every subsequent design decision references `--brand-primary`, `assets/brand/logo.svg`, etc. **Knowledge not frozen = knowledge forgotten**, and the next session will guess from memory again.

---

## When the user is the brand (your own company)

When designing for your own company, the brand usually already has:
- An identity page in your wiki (`wiki/entities/<empresa>.md`)
- Visual signature in the dashboard CSS (`core.css`): warm-cream palette, amber accent, IBM Plex / JetBrains Mono typography
- Mission-control vintage aesthetic per `command.html` styles

In that case the brand-spec.md is effectively the wiki entity file plus the product's core.css. Don't re-extract — reference what already exists.

---

## Anti-patterns

| Bad | Why |
|-----|-----|
| Guessing brand colors from memory | The Kimi failure mode — 1-2 hour rework |
| Substituting logo with "similar looking" SVG | Brand is the logo, not your interpretation |
| Using a single low-res JPG of the brand for hero | Cheap; signals you didn't try |
| AI-generating brand-adjacent imagery from a "vague" prompt | Hallucination risk; can fabricate trademarked elements |
| Reading brand color from a JPG of a product (instead of logo SVG) | JPG compression shifts colors; the product image's neighbouring pixels can be wrong |
| Inventing brand "voice" without source | Whatever you invent isn't theirs |
| Skipping the freeze step ("I'll remember") | You won't. The next session won't. Future-you will guess wrong. |

---

## Output to user after protocol completes

> "Brand spec frozen at `brand-spec.md`. Pulled logo from <source>, palette from logo SVG, type from <source>. Two product renders selected at 8.5/10 and 8/10 from 12 candidates across 6 channels.
> 
> Ready to design. Next: pick design direction (load `design-philosophies.md`)."
