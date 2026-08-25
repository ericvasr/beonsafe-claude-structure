# UI Styles Catalog — 67 Styles × 161 Product Reasoning

Compact mapping adapted from nextlevelbuilder/ui-ux-pro-max-skill. Use this when designing for a specific industry / product type. Cross-reference with `design-philosophies.md` for higher-level direction.

## Table of contents

- [How to use this](#how-to-use-this)
- [Product → Style lookup (top 30 categories)](#product--style-lookup)
- [49 General UI Styles](#49-general-ui-styles)
- [8 Landing Page Styles](#8-landing-page-styles)
- [10 Dashboard / BI Styles](#10-dashboard--bi-styles)
- [Anti-pattern map per industry](#anti-pattern-map-per-industry)

---

## How to use this

1. Identify the product **category** (or closest analog from the 161 list).
2. Look up recommended styles + anti-patterns for that category.
3. Cross with `design-philosophies.md` to pick the higher-level direction.
4. Cross with `taste-dials.md` to tune parametrically.

---

## Product → Style lookup

### Tech & SaaS

| Product | Recommended UI Styles | Color mood | Type mood | Anti-patterns |
|---------|----------------------|-----------|-----------|---------------|
| **SaaS landing** | Bento Grids, Soft UI, Aurora UI | Restrained + 1 saturated | Geist / Cabinet Grotesk display | AI purple gradient hero, 3-column equal cards |
| **B2B service** | Swiss Modernism 2.0, Information Architecture (iA-style) | Neutral + slate accent | Serif display + sans body | Cartoon mascots, glassy effects |
| **Developer tool** | Brutalism (Tactical Telemetry), Dark mode OLED, Cockpit | Mono + 1 accent (terminal green/amber) | Mono primary (JetBrains, Geist Mono) | Pastel palette, soft shadows, rounded everywhere |
| **IDE** | Dark mode OLED, Cockpit, Bento Grids | Charcoal + syntax-color accents | Mono | Light mode as default, decorative motion |
| **AI / Chatbot** | AI-Native UI, Soft UI, Liquid Glass | Restrained warm + one luminous accent | Geist / Outfit | Purple gradient, "AI Assistant" robot emoji, Inter font |
| **Cybersecurity** | HUD / Sci-Fi FUI, Brutalism Tactical, Dark mode | Monochrome + critical red | Mono + heavy sans | Bright B2C palette, friendly illustrations |

### Finance

| Product | Recommended UI Styles | Color mood | Type mood | Anti-patterns |
|---------|----------------------|-----------|-----------|---------------|
| **Fintech / Crypto** | Bento Grids, Editorial Grid, Spatial UI | Dark + 1 brand accent | Serif display + mono data | AI purple/pink (BANNED for finance), cartoon mascots |
| **Banking** | Swiss Modernism 2.0, Editorial Grid | Navy / forest / cream | Serif headers + sans body | Trendy gradients, neumorphism |
| **Insurance** | Editorial Grid, Soft UI | Calming blue / green | Serif + sans | Aggressive CTAs, urgency banners |
| **Personal finance** | Soft UI, Minimalism, Bento Grids | Warm neutrals + green accent | Sans / display | Casino-bright reds, alarmist warnings |
| **Invoice & billing** | Information Architects, Swiss | Mono + 1 accent | Sans + mono data | Decorative animations, marketing language |

### Healthcare

| Product | Recommended UI Styles | Color mood | Anti-patterns |
|---------|----------------------|-----------|---------------|
| **Medical clinic** | Soft UI, Inclusive Design | Calm blue/green, soft white | Cold tech aesthetic, neon |
| **Pharmacy** | Inclusive Design, Soft UI | Warm + green accent | Aggressive marketing CTAs |
| **Dental** | Soft UI, Minimalism | Light blue / mint | Loud sales banners |
| **Vet** | Soft UI, Claymorphism | Warm yellow / soft green | Sad imagery, dark moods |
| **Mental health** | Organic Biophilic, Nature Distilled | Earth tones, sage, terracotta | Aggressive notifications, bright reds |

### E-commerce

| Product | Recommended UI Styles | Color mood | Anti-patterns |
|---------|----------------------|-----------|---------------|
| **General e-com** | Bento Grids, Vibrant Block | Brand accent + neutral | Card spam, low-res product images |
| **Luxury** | Editorial Grid, Minimalism, Build | Cream + black + sparing accent | Sale banners, casino UI |
| **Marketplace P2P** | Bento Grids, Soft UI | Bright + neutral | Anonymous-feeling stock photos |
| **Subscription** | Bento Grids, Soft UI | Brand + warm | Pricing table with 3 equal cards |
| **Food delivery** | Soft UI, Vibrant Block | Appetite colors (warm reds, oranges) | Cold blue, monochrome |

### Services

| Product | Recommended UI Styles | Color mood | Anti-patterns |
|---------|----------------------|-----------|---------------|
| **Beauty / Spa** | Editorial Luxury, Build, Organic | Warm cream + 1 luxe accent | Tech-feel, cold blue |
| **Restaurant** | Editorial Grid, Vibrant | Warm earth + appetite accent | Generic stock food photos |
| **Hotel** | Editorial Luxury, Build | Warm cream + 1 accent | Booking-engine clutter |
| **Legal** | Swiss Modernism 2.0, Information Architects | Navy + cream + minimal accent | Trendy gradients, casual tone |
| **Booking** | Soft UI, Minimalism | Brand + neutral | Cluttered calendar UI, bright reds |

### Creative

| Product | Recommended UI Styles | Color mood | Anti-patterns |
|---------|----------------------|-----------|---------------|
| **Portfolio** | Editorial Grid, Brutalism, Motion-Driven | Personal direction | Template hero, generic stock |
| **Agency** | Motion-Driven, Editorial Luxury, Soft | Bold direction | "We make beautiful websites" copy |
| **Photography** | Editorial Grid, Vintage Analog | Image-led palette | Frames around photos, watermarks |
| **Gaming** | Cyberpunk UI, HUD Sci-Fi FUI, Retro-Futurism | Bold neon + dark | Corporate / SaaS palette |
| **Music** | Y2K, Vaporwave, Vibrant Block | Bold direction | Generic SaaS aesthetic |

### Lifestyle

| Product | Recommended UI Styles | Color mood | Anti-patterns |
|---------|----------------------|-----------|---------------|
| **Habit tracker** | Soft UI, Minimalism | Calm + 1 accent | Aggressive reminders, red alerts |
| **Recipe / Cooking** | Editorial Grid, Soft UI | Warm appetite + cream | Tech aesthetic |
| **Meditation** | Organic Biophilic, Nature Distilled | Earth + sage | Loud accents, fast motion |
| **Weather** | Soft UI, Aurora UI | Atmospheric + 1 mood color | Dense data dump |
| **Diary / Mood tracker** | Soft UI, Editorial | Personal palette + warm | Cold tech, charts everywhere |

### Emerging Tech

| Product | Recommended UI Styles | Color mood | Anti-patterns |
|---------|----------------------|-----------|---------------|
| **Web3 / NFT** | Cyberpunk, Y2K, Vaporwave | Neon + dark | Trad finance palette |
| **Spatial computing** | Spatial UI (VisionOS), Liquid Glass | Atmospheric + tactile | Flat 2D paradigm |
| **Quantum computing** | HUD Sci-Fi, Information Architecture | Mono + 1 accent | Marketing fluff |
| **Autonomous drones** | HUD Sci-Fi, Brutalism Tactical | Dark + warning colors | Consumer warmth |

---

## 49 General UI Styles

### Minimalism & Swiss

1. **Minimalism & Swiss Style** — Enterprise apps, dashboards. Grid-strict, monochrome + 1 accent, generous whitespace.
2. **Flat Design** — Web/mobile apps, startups. No depth cues, solid colors, sharp edges.
3. **Inclusive Design** — Public services, education, healthcare. High contrast, large hit targets, no decorative cruft.
4. **Accessible & Ethical** — Government, healthcare, education. Pass WCAG AAA where possible.
5. **Exaggerated Minimalism** — Fashion, architecture. Massive type, massive whitespace, one statement per scroll.
6. **Editorial Grid / Magazine** — News sites, blogs, magazines. Multi-column, serif display, image-led.

### Soft / Tactile

7. **Neumorphism** — Health/wellness. Soft inset/outset shadows on same-color background. Sparingly.
8. **Claymorphism** — Educational, children's, SaaS. Soft 3D blobs, rounded everything, friendly palette.
9. **Soft UI Evolution** — Enterprise apps, SaaS. Subtle depth, large radii, warm neutrals.
10. **Glassmorphism** — Modern SaaS, financial. Frosted glass overlays. Only when refraction is functional.
11. **Liquid Glass** — Premium SaaS, e-commerce. Inner border + inner shadow simulating refraction. Not lazy blur.
12. **Aurora UI** — Modern SaaS, creative. Soft gradient meshes as background atmosphere.
13. **Dimensional Layering** — Dashboards, cards, modals. Explicit z-layers communicate priority.

### Bold / Statement

14. **Brutalism** — Design portfolios, art. Raw HTML look, monospaced, harsh borders, primary colors.
15. **Neubrutalism** — Gen Z brands, startups, Figma-style. Brutalism + playful colors + hard shadows.
16. **Vibrant & Block-based** — Startups, creative agencies. Bold color blocks, type as graphic.
17. **Memphis Design** — Creative, music, youth. Geometric chaos, primary colors, pattern collisions.
18. **Bento Box Grid** — Dashboards, products, portfolios. Asymmetric grid of varied-size cards.
19. **Bento Grids** — Product features, dashboards. (Variant of Bento Box.)
20. **Anti-Polish / Raw Aesthetic** — Creative portfolios, artist sites. Looks "unfinished" intentionally.
21. **Gen Z Chaos / Maximalism** — Gen Z lifestyle, music artists. Loud, layered, mixed-media.

### Tech / Sci-fi

22. **Dark Mode (OLED)** — Night apps, coding. True black background, accent color saturation tuned.
23. **3D & Hyperrealism** — Gaming, product showcase. Photorealistic renders, deep shadows.
24. **Retro-Futurism** — Gaming, entertainment, music. 80s sci-fi: neon, gradients, scan lines.
25. **Cyberpunk UI** — Gaming, tech, crypto. Neon on dark, glitch effects, terminal aesthetic.
26. **HUD / Sci-Fi FUI** — Sci-fi games, space tech, cybersecurity. Vector data overlays, crosshairs.
27. **Pixel Art** — Indie games, retro tools. 8/16-bit aesthetic.
28. **Vaporwave** — Music, gaming, portfolios. 80s mall + glitch + pastels + Roman busts.
29. **Y2K Aesthetic** — Fashion, music, Gen Z. Chrome, gradients, frosted, optimistic-2000s.
30. **AI-Native UI** — AI products, chatbots, copilots. Conversational flow, generative reveals, ambient.
31. **Spatial UI (VisionOS)** — VR/AR, spatial computing. 3D layered glass, depth via blur.

### Skeumorphic / Premium

32. **Skeuomorphism** — Legacy, gaming, premium. Real-world materials simulated.
33. **Swiss Modernism 2.0** — Corporate, architecture, editorial. Pentagram-coded, type-driven, grid-strict.

### Motion-led

34. **Motion-Driven** — Portfolio, storytelling. Scroll narrative, parallax, kinetic type.
35. **Micro-interactions** — Mobile, touchscreen. Animation as feedback layer.
36. **Kinetic Typography** — Hero sections, marketing. Type animates, moves, reveals.
37. **Parallax Storytelling** — Brand storytelling, launches. Scroll = camera dolly.
38. **Tactile Digital / Deformable UI** — Modern mobile, playful brands. Press / drag deforms surface.

### Nature / Organic

39. **Organic Biophilic** — Wellness, sustainability. Natural textures, earth tones, leaf forms.
40. **Biomimetic / Organic 2.0** — Sustainability, biotech. Algorithmic nature: Voronoi, cells.
41. **Nature Distilled** — Wellness, sustainable. Reduced nature: stone, wood, sand colors.

### Editorial / Print

42. **E-Ink / Paper** — Reading apps, digital newspapers. Off-white, deep ink, no glow.
43. **Vintage Analog / Retro Film** — Photography, vinyl brands. Film grain, warm shift, vignettes.
44. **3D Product Preview** — E-commerce, furniture, fashion. Drag-to-rotate, lighting controls.

### Interactive details

45. **Interactive Cursor Design** — Creative portfolios. Custom cursor with magnetic / responsive behavior.
46. **Voice-First Multimodal** — Voice assistants, accessibility. Audio waveforms, transcript-as-UI.
47. **Zero Interface** — Voice assistants, AI. No UI at all in some flows.

### Effect-driven

48. **Gradient Mesh / Aurora Evolved** — Hero sections, backgrounds. Multi-stop gradients as atmospheric layer.
49. **Chromatic Aberration / RGB Split** — Music, gaming, tech. Color channel separation as effect.

---

## 8 Landing Page Styles

1. **Hero-Centric** — Strong visual identity. One striking hero owns 100vh.
2. **Conversion-Optimized** — Lead gen, sales. Multiple CTAs, social proof, urgency (sparingly).
3. **Feature-Rich Showcase** — SaaS, complex products. Sectioned features with scroll narrative.
4. **Minimal & Direct** — Simple products. One sentence, one CTA, nothing else.
5. **Social Proof-Focused** — Services, B2C. Testimonials, logos, case studies dominate.
6. **Interactive Product Demo** — Software tools. Live embed of the product itself as hero.
7. **Trust & Authority** — B2B, enterprise, consulting. Editorial-feel, named experts, depth signals.
8. **Storytelling-Driven** — Brands, agencies, nonprofits. Scroll = chapters of a narrative.

---

## 10 Dashboard / BI Styles

1. **Data-Dense** — Complex analysis. Cockpit-mode tables, multi-pane.
2. **Heat Map & Heatmap** — Geographic/behavior. Color-coded matrices.
3. **Executive** — C-suite summaries. Few large KPIs, narrative copy.
4. **Real-Time Monitoring** — Operations, DevOps. Live updates, alarms, sparkline ribbons.
5. **Drill-Down Analytics** — Detailed exploration. Click anywhere to expand.
6. **Comparative Analysis** — Side-by-side. Always two columns, segmented controls.
7. **Predictive Analytics** — Forecasting, ML. Probability bands, confidence intervals.
8. **User Behavior Analytics** — UX research. Funnel + heatmap + cohort overlays.
9. **Financial** — Finance, accounting. Tables-first, mono numerics, terse copy.
10. **Sales Intelligence** — Sales teams, CRM. Pipeline visualisation, activity streams.

---

## Anti-pattern map per industry

A few universal pairings that come up often:

- **Banking ⊕ AI purple gradient** = NEVER. Looks like a startup pretending to be a bank.
- **Healthcare ⊕ aggressive red alerts** = NEVER (unless emergency). Use calm semantic colors.
- **B2B SaaS ⊕ cartoon mascots** = avoid unless brand is intentionally playful (Mailchimp tier).
- **Luxury ⊕ sale banners** = NEVER. Luxury whispers, doesn't shout.
- **Developer tools ⊕ light mode default** = often wrong. Dark is the working mode.
- **Government / civic ⊕ trendy gradients** = NEVER. Stability and trust signal flat surfaces.
- **Children's apps ⊕ corporate B2B aesthetic** = NEVER. Use warm, playful, illustrated.

When in doubt, use the AI Slop Test from `anti-patterns.md`.
