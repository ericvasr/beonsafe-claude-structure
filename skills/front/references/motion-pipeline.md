# Motion Pipeline — Animation, Video, Audio

Adapted from huashu-design's stage + sprite + interpolate API, plus taste-skill's perpetual micro-interactions doctrine.

## When to load this reference

- **§A-B load by default** on every page / section / app build — motion is a premise, not an add-on (default MOTION_INTENSITY 6). Do not wait for the user to say "animation".
- **§C** (hero motion) on landing/marketing builds.
- **§D-F** (video export, TTS narration, BGM/SFX) stay on-demand: only when the user asks for a recorded demo, 60fps export, MP4/GIF/WEBM, or narrated explainer.

## Motion tokens (copy-paste — single source of truth)

Use these; do not invent ad-hoc values. Durations and easings are the design tokens of motion.

| Interaction | Duration | Easing / spring |
|-------------|----------|-----------------|
| Micro-feedback (hover, press, toggle) | 120–200ms | `cubic-bezier(0.2, 0.8, 0.2, 1)` |
| Entrance / reveal (fade+rise, cards) | 400–600ms | `cubic-bezier(0.16, 1, 0.3, 1)` (ease-out-expo) |
| Exit / dismiss | 150–250ms | `cubic-bezier(0.4, 0, 1, 1)` (ease-in) |
| Layout / shared-element (FLIP) | 300–450ms | spring UI (below) |
| Page / route transition | 250–400ms | `cubic-bezier(0.4, 0, 0.2, 1)` |
| Stagger between siblings | 40–60ms delay each | — |

Spring presets (Framer Motion `stiffness` / `damping` / `mass 1`):
- **UI (default)** — `stiffness: 220, damping: 26` — buttons, toggles, most interface motion.
- **Snappy** — `stiffness: 320, damping: 30` — small, fast feedback (tap, switch).
- **Playful** — `stiffness: 140, damping: 14` — bouncy, expressive (onboarding, delight).

> Use the **UI** preset as the baseline everywhere unless the DNA calls for snappy/playful. This is the canonical set — older snippets in this file and in `taste-dials.md` that show other spring numbers defer to this table.

## Decision tree

```
User wants...
   │
   ├─ Subtle interface motion?     → Section A: Micro-interactions
   ├─ Scroll-triggered narrative?   → Section B: Scroll choreography
   ├─ Hero / landing animation?     → Section C: Hero motion
   ├─ Recorded MP4/GIF demo?        → Section D: Video export
   ├─ Narrated explainer with TTS?  → Section E: Narration pipeline
   └─ Audio (BGM + SFX) overlay?    → Section F: Audio design
```

---

## A. Micro-interactions (universal baseline)

At MOTION_INTENSITY ≥ 5, every interactive surface should feel alive. The non-negotiable:

### Spring physics (not easing curves)

```js
// Framer Motion
<motion.button
  whileHover={{ scale: 1.04 }}
  whileTap={{ scale: 0.96 }}
  whileFocus={{ scale: 1.02 }}
  transition={{ type: "spring", stiffness: 220, damping: 26 }}  // UI preset (see Motion tokens)
/>
```

### Stagger reveals for groups

```js
<motion.ul
  initial="hidden"
  animate="show"
  variants={{
    show: { transition: { staggerChildren: 0.05 } }
  }}
>
  {items.map(item => (
    <motion.li variants={{
      hidden: { opacity: 0, y: 8 },
      show: { opacity: 1, y: 0 }
    }} />
  ))}
</motion.ul>
```

### Perpetual life (one element per surface)

At MOTION ≥ 6, at least one element should pulse / breathe / shimmer / float:

```css
/* CSS-only example: subtle breathing dot */
.live-dot {
  animation: breathe 2.4s ease-in-out infinite;
}
@keyframes breathe {
  0%, 100% { opacity: 0.85; transform: scale(1); }
  50%      { opacity: 1; transform: scale(1.08); }
}
```

Isolate in its own Client Component so it doesn't re-render the parent.

### GPU-safe only

Animate `transform`, `opacity`, `filter`. **Never** animate `top`/`left`/`width`/`height` (layout-trigger = frame drops).

### Respect `prefers-reduced-motion`

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

For Framer Motion: use `useReducedMotion()` hook + branch.

---

## A2. State & transition motion (load with §A by default)

The functional half of motion — what makes state changes legible instead of jarring. Missing these is the #1 reason UI feels static even when hovers are animated.

### Focus motion
Focus is a state, animate it (never remove the ring):
```css
.btn:focus-visible { outline: none; box-shadow: 0 0 0 2px var(--ring); transition: box-shadow 160ms cubic-bezier(0.2,0.8,0.2,1); }
```
In Framer Motion pair `whileFocus` with `whileHover` (see §A example).

### View Transitions API (state & DOM transitions)
The modern default for animating between two DOM states (filter change, tab switch, list reorder, expand/collapse):
```js
if (document.startViewTransition) {
  document.startViewTransition(() => updateDOM());   // browser cross-fades old→new
} else { updateDOM(); }                               // graceful fallback
```
Name persistent elements so they morph instead of cross-fade:
```css
.card { view-transition-name: card-hero; }
::view-transition-old(card-hero), ::view-transition-new(card-hero) { animation-duration: 300ms; }
@media (prefers-reduced-motion) { ::view-transition-group(*){ animation: none; } }
```

### Route / page transitions
- **Next App Router:** wrap route content in a client transition (`AnimatePresence mode="wait"`) or use `next-view-transitions`. Animate on `pathname` change.
- **Framer Motion SPA:**
```jsx
<AnimatePresence mode="wait">
  <motion.main key={pathname}
    initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }}
    transition={{ duration: 0.3, ease: [0.4,0,0.2,1] }} />
</AnimatePresence>
```
On route change also move focus to the new `<h1>`/live region (see `ux-interaction.md` §4).

### Loading motion (skeleton — first-class, not decoration)
Skeleton that mirrors the real layout (prevents CLS), shimmer sweeps across:
```css
.skeleton { background: linear-gradient(90deg, var(--surface-2) 25%, var(--surface-3) 37%, var(--surface-2) 63%);
  background-size: 400% 100%; animation: shimmer 1.4s ease infinite; border-radius: 8px; }
@keyframes shimmer { 0%{background-position:100% 0} 100%{background-position:0 0} }
@media (prefers-reduced-motion){ .skeleton{ animation:none; background: var(--surface-2); } }
```
Use skeleton for 300ms–1s waits; optimistic UI for actions; nothing under 300ms (see `ux-interaction.md` §1).

### Layout / shared-element (FLIP)
Framer Motion `layout` prop animates size/position changes automatically (reorder, expand, grid resize):
```jsx
<motion.div layout transition={{ type:"spring", stiffness:220, damping:26 }} />
```

---

## B. Scroll choreography (MOTION ≥ 7)

For story-driven sites, scroll = camera dolly. Tools:

### CSS-only (lightweight)

- `position: sticky` for pinned hero
- `scroll-snap` for sectioned narratives
- CSS scroll-driven animations (`animation-timeline: scroll()`) — modern browsers

### Framer Motion `useScroll`

```js
const { scrollYProgress } = useScroll({ target: ref, offset: ["start end", "end start"] });
const y = useTransform(scrollYProgress, [0, 1], [0, -200]);
const opacity = useTransform(scrollYProgress, [0, 0.5, 1], [0, 1, 0]);
```

### Anti-patterns

- Locomotive-style scroll-hijack on mobile (kills accessibility)
- Animations that block scrolling (always allow native scroll)
- Pinned sections > 200vh (user feels stuck)

---

## C. Hero motion

The hero is the trailer. Choose ONE move:

| Move | Implementation | Best for |
|------|----------------|----------|
| **Type reveal** | Letter-by-letter stagger or mask wipe | Editorial, brand launches |
| **Image kenburn** | Slow scale (1 → 1.08) + slow translate over 8-12s | Photography, lifestyle |
| **Mesh gradient drift** | Animate gradient stops, very slow | Atmospheric SaaS, AI |
| **Particle field** | WebGL particles with gentle drift | Tech, sci-fi, gaming |
| **Magnetic cursor** | Cursor warps neighbouring elements | Agency, portfolio |
| **3D model entry** | Three.js / Spline scene with one rotation | Product showcase |
| **Number counter** | Animated number reveal (KPI hero) | Dashboards, fintech |

Constraint: NEVER more than one hero move. Two = chaos.

---

## D. Video export pipeline

For exporting MP4 / GIF / WEBM from HTML animation:

### Stack

- **Stage + Sprite + interpolate API** from huashu's `animations.jsx` starter (or roll your own with `requestAnimationFrame`)
- **Playwright** for headless capture at deterministic FPS
- **FFmpeg** for encoding (MP4 H.264, GIF palette-optimised, WEBM VP9)

### Workflow

```
1. Write HTML scene with all motion driven by a single `t` parameter (0–1)
   - Expose a global function: window.setAnimationTime(t) that sets t=0..1
2. Playwright frame capture (using browser_evaluate + browser_take_screenshot):
   - mcp__plugin_playwright_playwright__browser_navigate to the page
   - Loop: browser_evaluate("window.setAnimationTime(N/totalFrames)")
           browser_take_screenshot for each frame
3. FFmpeg: assemble frames → MP4 (25fps base) → MP4 60fps interpolated → GIF
```

> **Note**: Playwright plugin does NOT have video recording. Use the frame-by-frame
> screenshot approach above, then assemble with FFmpeg.

### Sample FFmpeg commands

```bash
# 25fps base MP4 from frames
ffmpeg -framerate 25 -i frame-%04d.png -c:v libx264 -pix_fmt yuv420p -crf 18 out-25fps.mp4

# 60fps interpolated (smooth motion)
ffmpeg -i out-25fps.mp4 -vf "minterpolate=fps=60:mi_mode=mci" out-60fps.mp4

# Palette-optimised GIF
ffmpeg -i out-25fps.mp4 -vf "fps=15,palettegen" palette.png
ffmpeg -i out-25fps.mp4 -i palette.png -lavfi "fps=15,paletteuse" out.gif

# WEBM (web-optimised)
ffmpeg -i out-25fps.mp4 -c:v libvpx-vp9 -crf 30 -b:v 0 out.webm
```

### Playwright frame capture example

```
# Navigate to the scene
mcp__plugin_playwright_playwright__browser_navigate({ url: "file:///path/to/scene.html" })
mcp__plugin_playwright_playwright__browser_resize({ width: 1920, height: 1080 })

# Capture frames (25fps × 10s = 250 frames)
for t in 0..249:
  mcp__plugin_playwright_playwright__browser_evaluate({ code: `window.setAnimationTime(${t}/250)` })
  mcp__plugin_playwright_playwright__browser_take_screenshot()
  # Save frame to /tmp/frames/frame-NNNN.png
```

### Render duration guidance

| Output | Recommended duration | Notes |
|--------|---------------------|-------|
| Social GIF | 3-6s, ≤ 5MB | Loop seamlessly; cut at zero-velocity points |
| Hero loop MP4 | 8-15s | Loop point hidden; muted; autoplay |
| Demo MP4 | 30-90s | With narration (Section E) |
| Long-form explainer | 2-8 min | Narration-driven (Section E) |

---

## E. Narration pipeline (TTS → animation timeline)

For long-form explainers / tutorials. The ironclad rule: **don't animate first then narrate** — that produces PowerPoint-with-audio (= zero quality).

### Workflow (8 steps)

```
1. Write script in markdown:
   ## scene-1
   Welcome to /front. This skill orchestrates four design systems.
   [[cue:fade-in-logo]]
   ## scene-2
   ...

2. Run TTS pipeline (e.g., 豆包/Doubao, ElevenLabs, OpenAI TTS):
   narrate-pipeline.mjs script.md → voiceover.mp3 + timeline.json

   timeline.json contains:
   [
     { scene: "scene-1", start_ms: 0, end_ms: 4200, cues: ["fade-in-logo"] },
     { scene: "scene-2", start_ms: 4200, end_ms: 9500, cues: [] }
   ]

3. Design animation USING timeline as source of truth:
   - At t=0: page is empty
   - At t=cue("fade-in-logo"): logo fades in
   - At t=scene-2.start: next slide enters
   ...

4. Render NarrationStage component (huashu pattern):
   - Subtitles auto-wrap ≤ 12 chars per line
   - Style: dark ink + white outer glow (B站 / Bilibili style for readability)
   - Subtitles match scene boundaries from timeline.json

5. Playwright frame capture at 25fps using browser_evaluate + browser_take_screenshot
   (see Section D for the frame-by-frame approach)

6. FFmpeg assemble: video.mp4 + voiceover.mp3 → final.mp4 with -c:v libx264 -c:a aac

7. Optional 60fps interpolation pass (Section D)

8. QA: watch end-to-end. Check that animation cues land EXACTLY on narration beats.
```

### Three rigid laws of narration design (from huashu)

1. **Is there a hero element?** Every scene must have ONE primary thing on screen. Cannot have "scene with 5 cards of equal weight" — that's PowerPoint.
2. **What is the 7-segment morph?** Between scenes, ONE thing should morph / persist (logo → product → user → result → ...) — gives continuity. Never full-page opacity switch (= slide deck).
3. **Does any frame have motion?** At any given t, SOMETHING should be in motion (subtle drift, slow zoom, particles, etc). Never a 0.5s of "fully static frame mid-scene" — that's dead air, viewer feels the void.

Failure mode #1: each scene is independent + fade-up on cue + full-page opacity switch between scenes = PowerPoint with audio = zero quality. Refuse to ship.

---

## F. Audio design (BGM + SFX)

From huashu's audio library + audio-design-rules.

### BGM (background music) — 6 scene moods

Use scene-appropriate BGM:

| Mood | When to use | Style cue |
|------|-------------|-----------|
| Tech / corporate | SaaS demos, B2B explainers | Subtle synth bed, low-energy 100bpm |
| Ad / energetic | Brand reveals, product launches | Upbeat percussive, 120bpm+ |
| Educational | Tutorials, explainers | Mid-energy, melodic but ambient |
| Tutorial / chill | Long-form how-to | Lo-fi, soft drums |
| Cinematic | Story-driven launches | Orchestral, building tension |
| Sci-fi / atmospheric | AI / tech / future products | Pad-heavy ambient |

### SFX (sound effects) — 6 density levels (A-D + 2 specials)

| Density | Description |
|---------|-------------|
| A — Silent | No SFX. Use for meditation, luxury, somber content. |
| B — Minimal | Only critical feedback (click, success, error). |
| C — Standard | Click, hover, transition, success, error, notification (3-5 per minute) |
| D — Dense | Standard + UI keyboard sounds + scroll feedback (8-15 per minute) — for tactical/cockpit demos |

37 SFX categories: UI feedback (click, hover, toggle), keyboard typing, success chimes, error tones, transition swooshes, impact thuds, magic chimes, progress ticks, terminal beeps, transition whooshes.

### Frequency separation (avoid mud)

- **BGM**: low frequencies (60–500Hz dominant)
- **SFX**: high frequencies (1kHz+)
- No ducking silence — keep both tracks alive, just in different bands

### Audio is NOT optional

For non-silent video deliverables (demos, hero loops, narrated explainers), missing audio = 1/3 quality. The viewer's gut reaction to "画在动但没声音响应" (it's moving but there's no sound reacting) is: **cheap**.

Skip audio ONLY if user explicitly says:
- "Pure silent"
- "I'll narrate / add sound later"
- "No BGM"

Otherwise pick BGM mood + SFX density and include both.

---

## Quality gate (run before declaring motion deliverable done)

- [ ] All motion respects `prefers-reduced-motion`
- [ ] No animation of layout-triggering properties
- [ ] Spring physics at MOTION ≥ 5 (no linear easing for visible motion)
- [ ] At least one perpetual element at MOTION ≥ 6 (isolated component)
- [ ] Stagger pattern used for groups (not all-at-once reveal)
- [ ] No autoplay video with sound (browser will block; UX-hostile)
- [ ] Video deliverables include audio (BGM mood + SFX density specified)
- [ ] Narration timeline drives animation, not vice versa
- [ ] Subtitles styled for readability (dark ink + outer glow if dark BG, etc)
- [ ] FFmpeg encoding optimised (CRF 18-23 for MP4, palette-gen for GIF)
- [ ] Tested at 60fps interpolated (not just 25fps base)

---

## Anti-patterns

| Bad | Why |
|-----|-----|
| Bounce easing on UI feedback | Dated 2010s tic |
| Animation > 320ms for button hover | Feels sluggish |
| Full-page opacity fade between sections | PowerPoint-quality |
| Auto-play video with sound | Browser blocks; user-hostile |
| BGM without SFX (or SFX without BGM) | Asymmetric: BGM alone = "I have music"; SFX alone = "I have UI". Both = system. |
| Animation that ignores `prefers-reduced-motion` | Accessibility violation |
| Locomotive scroll-hijack on mobile | Breaks native scroll, kills accessibility |
| Particle field that doesn't respect viewport / GPU | Phone fans spinning |
