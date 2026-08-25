# Color System — oklch + Curated Palettes

> Paletas curadas derivadas de [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) (MIT, Copyright (c) 2024 Next Level Builder). Reescrito. Ver `../PROCEDENCIA.md`.

Color decisions are not "what looks pretty" — they're load-bearing. Wrong color = wrong mood + wrong register + wrong industry signal.

## Core rules (apply always)

### Use `oklch()`, not `hsl()` / `rgb()` / hex

```css
/* GOOD */
--brand: oklch(0.62 0.18 250);
--brand-hover: oklch(0.55 0.18 250); /* darker, same chroma + hue */

/* BAD */
--brand: hsl(220, 80%, 50%);  /* perceptual lightness is wrong */
--brand: #3b82f6;             /* unreadable, no relationship to hover */
```

`oklch()` is perceptually uniform — same lightness number = same perceived brightness across hues. This makes generating shades + hover states deterministic.

### Reduce chroma at extremes

Chroma close to 0 (lightness < 0.15) or 1 (lightness > 0.92) looks garish/toxic. Empirical guidance:

| Lightness | Max chroma | Notes |
|-----------|-----------|-------|
| 0.05–0.15 | 0.04 | Deep neutrals; subtle hue tint only |
| 0.15–0.40 | 0.12 | Saturated darks (brand accents) |
| 0.40–0.65 | 0.20 | Saturated midtones (primary brand) |
| 0.65–0.85 | 0.15 | Lighter brand variants |
| 0.85–0.95 | 0.08 | Tinted backgrounds |
| 0.95–1.00 | 0.02 | Off-white surfaces |

### Tint every neutral

Pure gray (chroma 0) is dead. Tint every neutral toward the brand hue:

```css
/* Brand hue: 250 (a cool blue) */
--surface-1:    oklch(0.99 0.005 250);   /* off-white tinted */
--surface-2:    oklch(0.97 0.008 250);
--text-primary: oklch(0.18 0.02 250);    /* deep ink, hue retained */
--text-muted:   oklch(0.50 0.015 250);
--border:       oklch(0.90 0.010 250);
```

Even chroma 0.005 is enough to break the "AI default" feel.

### Four-step commitment axis

Where on the commitment axis sits this surface? Be explicit. The user (and you) should know.

| Step | Definition | Use case |
|------|-----------|----------|
| **Restrained** | Tinted neutrals + one accent at ≤10% surface area | B2B SaaS, finance, healthcare, government |
| **Committed** | One saturated color at 30-60% surface area | Modern brand, agency, fintech |
| **Full palette** | 3-4 named role colors (info/success/warn/danger + brand) | Complex products, data dashboards |
| **Drenched** | Surface IS the color (purple/red/green floor-to-ceiling) | Statement brands, launches, gaming, lifestyle |

---

## Banned color choices

| Banned | Reason | Use instead |
|--------|--------|-------------|
| `#000000` / `#ffffff` | Garish, no nature, AI default | Tinted black/white (see above) |
| `oklch(0.62 0.22 295)` (the AI purple `#8b5cf6`) | Trained data default for SaaS | Tinted indigo `oklch(0.45 0.15 270)` OR pick a non-default hue |
| Purple gradient on white SaaS hero | The category-default cliché | Either pick one color and drench, or stay restrained |
| Gray text on colored background | Accessibility + cheap | Tinted gray that matches the brand hue |
| Rainbow accent set (red+green+blue all saturated) | Visual chaos | 1 brand + 4 semantic colors max |

---

## Palette presets (by mood)

These are starting points — tune the exact hues to fit. All use `oklch()`.

### Calm warm (Kenya Hara × terracotta)

```css
--base:    oklch(0.98 0.005 60);     /* warm off-white */
--ink:     oklch(0.18 0.02 60);      /* deep brown-ink */
--mute:    oklch(0.55 0.015 60);
--accent:  oklch(0.55 0.14 35);      /* terracotta */
--border:  oklch(0.90 0.01 60);
```

### Editorial luxury

```css
--base:    oklch(0.97 0.01 80);      /* cream */
--ink:     oklch(0.15 0.02 280);     /* deep navy-ink */
--mute:    oklch(0.50 0.02 280);
--accent:  oklch(0.42 0.18 25);      /* burgundy */
--border:  oklch(0.88 0.015 80);
```

### Mission-control vintage (warm CRT)

```css
--base:    oklch(0.14 0.01 50);      /* charcoal-warm */
--surface: oklch(0.18 0.012 50);
--cream:   oklch(0.89 0.045 80);     /* warm cream text, NOT pure white */
--mute:    oklch(0.65 0.025 70);
--amber:   oklch(0.78 0.16 70);      /* CRT phosphor amber */
--phosphor:oklch(0.78 0.18 130);     /* CRT phosphor green */
--safety:  oklch(0.62 0.20 30);      /* warning red-orange */
```

### Soft pastel (minimal product)

```css
--base:    oklch(0.985 0.003 80);    /* bone */
--ink:     oklch(0.20 0.01 240);
--mute:    oklch(0.55 0.015 240);
--accent-pastel-red:    oklch(0.92 0.05 25);
--accent-pastel-blue:   oklch(0.92 0.05 240);
--accent-pastel-green:  oklch(0.92 0.05 145);
--accent-pastel-yellow: oklch(0.94 0.07 95);
--border:  oklch(0.92 0.008 240);
```

### Cockpit dark (data ops)

```css
--base:       oklch(0.10 0.005 240);
--surface:    oklch(0.14 0.008 240);
--surface-hi: oklch(0.18 0.010 240);
--ink:        oklch(0.92 0.005 240);
--mute:       oklch(0.55 0.010 240);
--accent-data:oklch(0.82 0.16 50);   /* amber */
--accent-ok:  oklch(0.78 0.18 145);
--accent-err: oklch(0.65 0.20 30);
--rule:       oklch(0.25 0.010 240);
```

### Editorial luxury dark

```css
--base:    oklch(0.10 0.005 30);     /* deep warm ink */
--surface: oklch(0.15 0.008 30);
--cream:   oklch(0.94 0.04 80);      /* warm cream */
--mute:    oklch(0.62 0.020 80);
--accent:  oklch(0.65 0.14 25);      /* burnt amber */
--border:  oklch(0.22 0.012 30);
```

### Brutalist tactical (terminal)

```css
--base:       oklch(0.08 0.005 145);  /* near-black, hint of green */
--surface:    oklch(0.12 0.008 145);
--phosphor:   oklch(0.85 0.18 145);   /* CRT green */
--critical:   oklch(0.65 0.22 30);    /* danger red */
--rule:       oklch(0.30 0.020 145);
```

### Y2K / Vaporwave (statement)

```css
--base:    oklch(0.85 0.10 320);     /* lavender mist */
--accent1: oklch(0.75 0.20 320);     /* hot magenta */
--accent2: oklch(0.78 0.16 200);     /* cyan */
--ink:     oklch(0.20 0.02 320);
--chrome:  oklch(0.95 0.02 240);
```

---

## Industry palette directions

(Use these as starting points, not endpoints. Override per brand.)

| Industry | Typical palette direction | Why |
|----------|---------------------------|-----|
| Finance / banking | Navy + cream + sparing accent | Stability, longevity, trust |
| Healthcare | Calm blue/green + soft white | Calm, hygienic, trustworthy |
| Education | Warm earth + 1 bright accent | Approachable, energising |
| Gaming | Neon on dark | Energy, focus, immersion |
| Luxury | Cream + black + 1 burnished accent | Restraint, quality, scarcity |
| Wellness | Earth tones (sage, terracotta) | Natural, grounded |
| Fintech (modern) | Dark + 1 saturated brand | Edge, tech-forward |
| Editorial / news | Cream/off-white + black ink + 1 highlight | Reading, authority |
| Climate / sustainability | Sage + sand + sky | Natural, optimistic |
| Children's | Warm + 3-4 candy accents | Playful, energetic |

---

## How to extract brand colors (when brand is specified)

1. Visit official `<brand>.com/brand`, `<brand>.com/press`, or marketing kit.
2. Pull SVG logos. **Read the SVG `<path fill="..."/>`** — that's the canonical hex.
3. Cross-check with screenshots of the live site using an eyedropper.
4. Convert hex → oklch using a tool or browser DevTools.
5. Record in `brand-spec.md`:

```md
# Brand spec — Stripe

## Colors (extracted from stripe.com/brand)
- Primary: #635BFF → oklch(0.55 0.22 275)
- Accent: #00D924 → oklch(0.77 0.22 145)
- Ink: #0A2540 → oklch(0.20 0.06 250)
- Cream: #F6F9FC → oklch(0.97 0.01 240)

## Hover/active derivation
- Primary hover: oklch(0.48 0.22 275)  /* -0.07 lightness */
- Primary active: oklch(0.42 0.22 275) /* -0.13 lightness */
```

**NEVER guess brand colors from memory.** The Kimi failure (memory said orange, actual is `#1783FF` blue) is a 1-2 hour rework warning.

---

## Verification

After picking a palette, screenshot the result and check:

- **Contrast**: WCAG AA minimum (4.5:1 for body, 3:1 for large text). Use DevTools or a contrast checker.
- **Three-color test**: pick 3 random elements + their backgrounds. Are the contrasts intentional? If one accidentally has near-zero contrast, fix.
- **Hue consistency**: do all neutrals have the same underlying hue? If you see one off-temp gray, fix.
- **Saturation walk**: lay out the palette swatches side by side. Does it feel like a system or like 5 random colors? If random, drop colors until it feels intentional.

When in doubt, use **fewer colors**. The most common failure mode is too many.
