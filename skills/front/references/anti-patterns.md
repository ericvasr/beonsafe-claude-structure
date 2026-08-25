# Anti-Patterns — Unified Catalog

Compiled from impeccable (27 deterministic rules), taste-skill (forbidden patterns), huashu (anti-AI-slop list), ui-ux-pro-max (industry-specific anti-patterns). When two sources conflict, the stricter rule wins.

## TL;DR — The AI Slop Test (apply always)

> If a stranger could guess the theme, palette, and layout from the **category alone** (e.g. "SaaS", "fintech", "AI tool"), what you produced is not design — it's a corpus average. Rework.

The second-order test: if they could guess the aesthetic family from category + anti-references combined, you're still trapped one tier deeper. Push further.

---

## A. Typography bans

| Forbidden | Reason | Use instead |
|-----------|--------|-------------|
| `Inter`, `Roboto`, `Arial`, `Open Sans` as display | System default look — invisible voice | Geist, Outfit, Cabinet Grotesk, Bricolage Grotesque, Newsreader, Source Serif, EB Garamond, JetBrains Mono, IBM Plex |
| Serif (`Times`, generic) on dashboards | Wrong register, fights data density | Mono (JetBrains, IBM Plex Mono) or distinctive sans |
| Oversized `H1` (>96px) on landing | Mid-2020s AI-generated cliché | Type scale `text-4xl md:text-6xl` max for hero, vary by section |
| Thin Lucide icons next to bold heading | Inconsistent stroke weight | Match icon weight to body weight |
| Em dashes (—) in copy | Trained-data tic; reads as ChatGPT output | Commas, colons, semicolons, parentheses, periods |
| `Lorem ipsum`, `text here`, `placeholder` | Lazy execution | Write real copy as if shipping. If genuinely TBD, gray block + honest label |
| Gradient text via `background-clip: text` | AI-poster tic | Solid color with measured contrast |

---

## B. Color bans

| Forbidden | Reason | Use instead |
|-----------|--------|-------------|
| Pure `#000000` background | Garish at extreme chroma; never occurs in nature | Tinted black (`oklch(0.15 0.02 <brand-hue>)`) |
| Pure `#ffffff` background | Same — kills mood, reads "AI default" | Tinted off-white (`oklch(0.98 0.005 <brand-hue>)`) |
| Purple-on-white SaaS gradient hero | The AI training default — sniffable from miles | Pick a single saturated direction OR full restrained neutrals |
| Oversaturated neon accents | "Look at me" energy without earning it | Lower chroma, fewer accents, more whitespace |
| "AI purple" `#6366f1` / "AI blue" `#3b82f6` for fintech, banking | Trained-data category-default | Domain-appropriate desaturated palettes; see `color-system.md` |
| Gray text (`#999`, `#aaa`) on colored backgrounds | Accessibility + cheap feel | Tinted gray that matches the brand hue |
| Identical accent for primary and warning | Semantic confusion | One accent per role: brand, info, success, warning, danger |
| Gradient backgrounds as default surface | Reads "Stripe 2018 fan tribute" | Solid surfaces; gradients only on intentional hero moments |

**Color quality bar (oklch only):**
- Reduce chroma as lightness approaches 0 or 100 (high chroma at extremes looks toxic)
- Use `oklch()` not `hsl()` — perceptually uniform
- Tint every neutral toward brand hue, even at chroma 0.005
- Four-step commitment axis: **Restrained** (tinted neutrals + one accent ≤10%) → **Committed** (one saturated 30–60%) → **Full palette** (3–4 named roles) → **Drenched** (surface IS the color)

---

## C. Layout bans

| Forbidden | Reason | Use instead |
|-----------|--------|-------------|
| Three-column equal card grid as page body | The single most common AI default layout | Bento, masonry, asymmetric split, or break the row entirely |
| Centered hero with subtitle + two CTAs | The "Vercel template" cliché | Asymmetric hero, left-aligned text + right imagery, editorial split, full-bleed |
| Side-stripe borders (`border-left: 4px solid accent`) | Bootstrap-era tic | Full 1px borders OR background tint OR no border |
| Hero-metric template (big number + small label + gradient) | SaaS template; reads as marketing slop | Editorial layouts, narrative copy, real screenshots |
| Cards inside cards (nested cards with shadows) | Visual debt | Flatten — outer container, inner uses borders or background contrast |
| `h-screen` for full-height | Breaks on mobile with browser chrome | `min-h-[100dvh]` |
| Complex flexbox math with `flex-basis: 23.5%` | Fragile, error-prone | CSS Grid (`grid-template-columns: repeat(4, 1fr)` etc) |
| Modal as default for any optional content | Disruptive; hides context | Progressive disclosure: inline accordion → side panel → modal (last resort) |

---

## D. Motion bans

| Forbidden | Reason | Use instead |
|-----------|--------|-------------|
| `transition: all 0.3s ease` | Animates expensive properties, lazy default | Specific properties + intent (`transform 220ms cubic-bezier(0.2, 0.8, 0.2, 1)`) |
| Animating `top` / `left` / `width` / `height` | Triggers layout, drops frames | `transform: translate / scale`, `opacity`, `filter` only |
| Bounce / elastic easing (`ease-out-back`, `cubic-bezier(.68,-.55,.27,1.55)`) | Dated; tonally wrong for serious products | Spring physics (`stiffness: 100, damping: 20`) or measured cubic-bezier |
| Linear easing for visible motion | Robotic; lacks acceleration story | Cubic-bezier or spring |
| `backdrop-blur` on scrolling containers | GPU thrash | Only on fixed/sticky elements |
| Animations longer than 320ms for UI feedback | Sluggish | 150–280ms for most micro-interactions |
| Auto-play looping background video on first load | Bandwidth + accessibility hostile | Static hero with optional play OR `prefers-reduced-motion` respect |
| Custom cursor that hides system cursor | Breaks accessibility, feels gimmicky | Decorate, don't replace |

---

## E. Iconography bans

| Forbidden | Reason | Use instead |
|-----------|--------|-------------|
| **Emoji as UI icons** (🚀 📊 ✨) | CRITICAL — reads as AI placeholder, breaks visual system | Phosphor, Radix, Lucide, custom SVG monoline. Stroke 1.4–1.6, viewBox 24, linecap round |
| Default shadcn/ui rounded radii unchanged | Recognizable shadcn-tax | Customize radii, colors, shadows — they're a base, not a finish |
| Mixed icon weight in the same surface | Visual chaos | Lock one stroke + one corner style per project |
| Stock photography of "diverse smiling people in offices" | Trained-data tic | Custom illustration, real screenshots, abstract photography, or careful sourcing |

---

## F. Copy bans (UX writing)

| Forbidden | Reason | Use instead |
|-----------|--------|-------------|
| Fake names: "John Doe", "Jane Smith", "Acme Corp" | Reveals demo state | Real-flavored names (Maria Schmidt, Pedro Rocha, Coldchain, Northwind Labs) |
| Marketing clichés: "Seamless", "Elevate", "Empower", "Revolutionize" | Reads as ChatGPT body copy | Specific verbs that describe what the product actually does |
| "Lorem ipsum" anywhere | Lazy | Real copy, even if rough |
| Buzzword stacks: "AI-powered, enterprise-grade, cloud-native" | Empty signaling | Name one specific benefit + one specific user |
| Title Case For All Buttons | Antiquated | Sentence case for buttons (`Save changes`, not `Save Changes`) — except brand names |
| Vague CTAs: "Learn more", "Click here", "Submit" | Loses scent of next step | Specific action: `See pricing`, `Start free trial`, `Continue to billing` |
| Apologetic / cute error copy | Patronising | Direct: `Card declined. Try another or contact support.` |

---

## G. Image / visual asset bans

| Forbidden | Reason | Use instead |
|-----------|--------|-------------|
| Single giant compressed JPG/PNG covering the whole page | "Image-to-code with no slicing" tell | Section-specific images, each readable; SVG/icons for ornaments |
| `https://images.unsplash.com/...` hotlinks | Hot-linking + signals stock | `picsum.photos/seed/<n>/<w>/<h>` for placeholder, real assets for production |
| AI-generated avatars with uncanny faces | Falls deep into uncanny valley | Initials in tinted circles, custom illustration, or real photography |
| CSS-drawn human silhouettes / generic SVG product mock | Reads as cheap placeholder | Real product photography OR honest gray block with label |
| Logos as `.png` with white halo | Cheap rendering | SVG only, inline preferred, anti-aliased |

---

## H. Brand-specific anti-patterns

If a specific brand is named (Stripe, Linear, the user's company), additional rules from `brand-asset-protocol.md` apply. The non-negotiable:

- **Never invent brand colors from memory.** Pull from official source. Real failure case: a designer assumed Kimi's brand was orange — it's actually `#1783FF` blue. 1-2 hour rework.
- **Never substitute logo with CSS-drawn approximation.** Use the real SVG from `<brand>.com/brand` or `/press`.
- **Never replace product hero shot with a CSS gradient block.** If you can't get a real render or screenshot, use a placeholder with the label `[product render missing]` — that's HONEST. A fake one is dishonest.

---

## I. Performance anti-patterns

| Forbidden | Reason |
|-----------|--------|
| 4+ webfonts loaded on first paint | Layout shift + slow LCP — pick 2 max |
| `<img>` without `width`/`height` or `aspect-ratio` | CLS killer |
| `<img>` without `loading="lazy"` below the fold | Wasted bandwidth |
| Inline SVG > 5kB | Move to file, reference with `<img src>` or `<use href>` |
| Animating filter / blur on the whole page during scroll | Frame drops on mid-range hardware |
| Loading the whole CMDB graph / data table on mount | Paginate or virtualise |

---

## J. Domain register conflicts

These aren't pure bans, they're signals you're using the wrong register:

- **Product surface using brand-register motion** (lots of parallax, hero animations) → users can't get work done. Switch to product register: micro-interactions only, instant feedback, no flourish.
- **Brand surface using product-register typography** (Inter, neutral gray everywhere) → forgettable. Switch to brand register: distinctive face, bolder accents, intentional silence.

---

## Self-audit checklist (run before declaring done)

- [ ] No banned fonts as display
- [ ] No `#000` / `#fff`
- [ ] No emoji as UI icons
- [ ] No three-equal-card-grid as the page body
- [ ] No gradient text
- [ ] No `h-screen`
- [ ] No animating layout properties
- [ ] All copy real (no Lorem, no John Doe, no "Seamless")
- [ ] Real or honest-placeholder images (no fake CSS product mock)
- [ ] Spring physics or measured easing, not bounce
- [ ] One coherent aesthetic, not three averaged
- [ ] Could a stranger guess the theme from the category alone? If yes → rework

If any box is unchecked and the user hasn't explicitly authorized the exception, fix before shipping.
