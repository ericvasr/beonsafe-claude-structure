# Design Philosophies — 20-Library + Direction Advisor

Adapted from huashu-design's school-based design library. Use this when the user's brief is vague ("make it pretty", "design this"), or when you want to anchor a design to a specific aesthetic DNA rather than averaging the training data.

## How to use

1. **Advise**: when brief is vague, recommend **3 philosophies from 3 different schools**. Don't recommend three minimalists — force contrast.
2. **Each recommendation**: designer/studio + 1-line philosophy + 3–5 mood keywords + 3–5 signature features + landmark works.
3. **Generate visual demos in parallel** if the agent supports it (3 single-file HTML mocks). Otherwise serial.
4. **Let the user mix and match**, then lock the DNA prompt: "Kenya Hara whitespace × terracotta `#C04A1A` accent · Newsreader display · animations 220ms cubic-bezier · variance 6".

The DNA prompt is the contract for downstream work — anchor every decision to it.

---

## School 1 — Information Architecture

### 01. Pentagram / Michael Bierut
- **Philosophy**: Typography is language, grid is thought.
- **Mood**: editorial, authoritative, severe, considered, civic.
- **Signature**: extreme color restraint (B&W + one accent), Swiss grid, 60%+ whitespace, data viz as primary decoration.
- **Landmark**: MIT Media Lab identity, New York Times Magazine covers.
- **When to use**: financial reports, civic, editorial, B2B with serious tone.

### 02. Stamen Design
- **Philosophy**: Let data become a touchable landscape.
- **Mood**: cartographic, contemplative, warm-data, exploratory.
- **Signature**: map thinking, warm tones (ochre/sage/navy), algorithmic organic patterns.
- **Landmark**: OpenStreetMap rendering, Watercolor map style.
- **When to use**: data viz with geographic / temporal narrative, dashboards that want personality.

### 03. Information Architects (iA)
- **Philosophy**: Design is content architecture.
- **Mood**: focused, calm, readable, principled.
- **Signature**: content-first, system fonts only (often deliberately), blue hyperlinks intact, reading-optimised (66-char lines).
- **Landmark**: iA Writer app, "Web Trend Map".
- **When to use**: reading interfaces, documentation, long-form, anything where copy is the product.

### 04. Fathom
- **Philosophy**: Every pixel carries information.
- **Mood**: scientific, elegant, considered, precise.
- **Signature**: scientific journal + design elegance, neutral palette + highlight, integrated footnotes.
- **Landmark**: data visualisation for IDEO, MIT, Harvard.
- **When to use**: research portals, scientific dashboards, anything that needs to read as "trustworthy data".

---

## School 2 — Motion Poetry

### 05. Locomotive
- **Philosophy**: Scroll is a journey.
- **Mood**: cinematic, narrative, immersive, bold.
- **Signature**: parallax narrative, film-like scene composition, bold typography emerging from darkness, 100vh hero sections.
- **Landmark**: locomotive.ca, agency portfolios.
- **When to use**: agency sites, narrative brand launches, anything that wants the user to feel like they're inside a story.

### 06. Active Theory
- **Philosophy**: Visible tech = understandable tech.
- **Mood**: futurist, kinetic, dark, technical.
- **Signature**: 3D particle systems, real-time data viz, neon on dark (cyan/magenta), mouse-reactive.
- **Landmark**: Beyoncé launch pages, NFL Showtime.
- **When to use**: launch landing pages, agency tech showcases, anything where the WOW is part of the brand.

### 07. Field.io
- **Philosophy**: Code is the designer.
- **Mood**: generative, mathematical, austere, unique-per-visit.
- **Signature**: generative systems, abstract geometry, monochrome + accent, visible Voronoi / Delaunay math.
- **Landmark**: field.io, generative identity systems.
- **When to use**: tech / art crossover, brand identity systems that need infinite variation.

### 08. Resn
- **Philosophy**: Each click advances the story.
- **Mood**: warm, character-driven, playful, gamified.
- **Signature**: gamified journey, emotional illustration + UI blend, warm colors despite tech subject matter, scroll-triggered narrative beats.
- **Landmark**: Marvel campaigns, Disney+ launches.
- **When to use**: kids' brands, entertainment IP launches, anything with a story arc.

---

## School 3 — Minimalism

### 09. Experimental Jetset
- **Philosophy**: One idea = one form.
- **Mood**: ascetic, conceptual, anti-commercial, declarative.
- **Signature**: single visual metaphor, Mondrian primaries (R/B/Y + B&W), type as graphic element.
- **Landmark**: Whitney Museum identity, Helvetica film poster.
- **When to use**: museums, cultural institutions, conceptual brands.

### 10. Müller-Brockmann
- **Philosophy**: Objectivity is beauty.
- **Mood**: rational, mathematical, timeless, Swiss.
- **Signature**: 8pt grid (strict), left-aligned or centered, dual-color max, Akzidenz-Grotesk or similar rationalist sans.
- **Landmark**: Zurich Tonhalle posters, IBM identity precursors.
- **When to use**: corporate / professional services, anything that wants to look like it'll exist for 50 years.

### 11. Build
- **Philosophy**: Simplicity is harder than complexity.
- **Mood**: quiet, refined, considered, breathing.
- **Signature**: 70%+ whitespace, subtle weight shifts (200–600), one accent used sparingly, golden ratio composition, soft shadows.
- **Landmark**: Build agency portfolio, BMW brand work.
- **When to use**: premium product surfaces, luxury / high-end services.

### 12. Sagmeister & Walsh
- **Philosophy**: Beauty is the emotional layer of function.
- **Mood**: optimistic, playful, handmade, surprising.
- **Signature**: unexpected color bursts on minimal base, handmade + digital blend, playful typography.
- **Landmark**: Aizone identity, Sagmeister & Walsh portfolio.
- **When to use**: brands that need warmth and surprise, fashion, beauty, lifestyle.

---

## School 4 — Experimental Avant-Garde

### 13. Zach Lieberman
- **Philosophy**: Programming is painting.
- **Mood**: poetic, hand-drawn-feel, generative, intimate.
- **Signature**: hand-drawn-feel generative, B&W, real-time art, visible construction lines, poetic algorithms.
- **Landmark**: openFrameworks, daily code sketches.
- **When to use**: art + tech crossover, creative coding showcase, NFT / digital art platforms.

### 14. Raven Kwok
- **Philosophy**: System beauty > individual beauty.
- **Mood**: architectural, fractal, oriental, austere.
- **Signature**: fractals + recursion, high contrast B&W, architectural data structures, oriental garden algorithm.
- **Landmark**: Aesop installations, Tencent ICDM.
- **When to use**: brand identity for cultural / oriental brands, anything that wants algorithmic-but-warm.

### 15. Ash Thorp
- **Philosophy**: Future isn't cold, it's lonely poetry.
- **Mood**: cinematic-cyberpunk, warm-future, narrative, melancholy.
- **Signature**: film-grade lighting, warm cyberpunk (orange/teal not cold blue), story-driven concept art.
- **Landmark**: Ghost in the Shell concept art, Call of Duty title sequences.
- **When to use**: gaming, sci-fi, AI products that want to feel like they belong in a film.

### 16. Territory Studio
- **Philosophy**: Motion as narrative bridge.
- **Mood**: VFX-grade, sci-fi-grounded, technical, urgent.
- **Signature**: physical simulation, 3D space, sci-fi-but-grounded UI, dense data fountains.
- **Landmark**: Blade Runner 2049 UI, The Martian UI.
- **When to use**: fictional UI / film work, ambitious agency showcases.

---

## School 5 — Eastern Philosophy

### 17. Takram
- **Philosophy**: Form reveals the invisible.
- **Mood**: serene, technical, restrained, premium.
- **Signature**: Japanese simplicity + tech, minimalist geometry, poetic spacing, restraint in materiality.
- **Landmark**: Sony Aibo, Toyota brand work.
- **When to use**: premium hardware, automotive, refined product surfaces.

### 18. Kenya Hara
- **Philosophy**: Whitespace speaks.
- **Mood**: empty, profound, Muji, intentional.
- **Signature**: radical simplification, *ma* (negative space) as protagonist, profound emptiness.
- **Landmark**: Muji identity and stores, "White" book.
- **When to use**: lifestyle brands, wellness, anything that should feel like exhale.

### 19. Irma Boom
- **Philosophy**: Book as experience.
- **Mood**: tactile, editorial, considered, ritualistic.
- **Signature**: tactile material focus, typography + paper interaction, editorial pacing, conceptual depth.
- **Landmark**: SHV Think Book, Chanel No. 5 monograph.
- **When to use**: high-end editorial, art books, premium content surfaces.

### 20. Neo Shen
- **Philosophy**: Algorithm teaches beauty.
- **Mood**: contemporary-Chinese, parametric, digital-craft, synthesised.
- **Signature**: parametric eastern aesthetics, contemporary Chinese sensibility, digital craft + cultural synthesis.
- **Landmark**: brand work for Chinese tech (Bilibili, Tencent).
- **When to use**: brands targeting Chinese / Asian markets, parametric identity systems.

---

## Execution path by school

| School | Best execution layer | Why |
|--------|----------------------|-----|
| Information Architecture (01-04) | **HTML / framework code** | Data-precise, grid-perfect, type-driven |
| Motion Poetry (05-08) | **Code + WebGL / Canvas / Lottie** | Motion is the deliverable |
| Minimalism (09-12) | **HTML / framework code** | Restraint expressed via type + space |
| Avant-Garde (13-16) | **AI generation + code** | Generative imagery, particles |
| Eastern Philosophy (17-20) | **HTML / framework code** | Whitespace, type, restraint |

---

## Anti-mistake: don't mix philosophies casually

If you pick Kenya Hara (radical whitespace) and the user later asks for "denser dashboards", recognise the tension — those aren't compatible in the same artifact. Either:
- Stay Kenya Hara and reduce density;
- Switch to Müller-Brockmann (still minimal, but happy with denser grids);
- Or explicitly mix two registers (brand surface = Kenya Hara, product surface = Müller-Brockmann) — name this in the DNA prompt.

---

## Output: DNA prompt format

After the user picks their direction, write the DNA prompt to a file (`design-dna.md` at project root) so every subsequent design call references it:

```markdown
# Design DNA — <project>

**Direction**: Kenya Hara × Stamen
**Mood**: serene-cartographic
**Palette**: oklch(0.98 0.005 60) base, oklch(0.42 0.10 30) ochre accent, oklch(0.18 0.02 60) ink
**Display type**: Newsreader 600
**Body type**: Geist 400
**Mono**: JetBrains Mono 400
**Motion**: 220ms cubic-bezier(0.2, 0.8, 0.2, 1), zero parallax
**Dials**: VARIANCE 4, MOTION 3, DENSITY 3
**Anti-references**: never look like Vercel, never look like Linear-clone, never AI purple
```

Future design calls in this project should open with "DNA: <reference design-dna.md>". This is the single source of truth that prevents drift.
