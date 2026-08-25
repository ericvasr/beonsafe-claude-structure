# Workflow Templates — Per Deliverable Type

Pre-baked workflows for the most common deliverables. Pick the template that matches the user's brief, follow the steps, ship.

## Index

- [Landing page](#1-landing-page)
- [Product dashboard](#2-product-dashboard)
- [Mobile screen / app surface](#3-mobile-screen--app-surface)
- [Pitch deck / slides](#4-pitch-deck--slides)
- [Email template](#5-email-template)
- [Component library / design system](#6-component-library--design-system)
- [Brand identity board](#7-brand-identity-board)
- [Redesign existing surface](#8-redesign-existing-surface)
- [Demo animation / hero loop](#9-demo-animation--hero-loop)
- [Narrated explainer video](#10-narrated-explainer-video)

---

## 1. Landing page

**Goal**: convert a visitor to take ONE action.

**Steps**:
1. **Shape**: ask the user (one batched question):
   - Who is the visitor (specific persona)?
   - What's the ONE action they should take?
   - What 2-3 brands do you want this to NOT look like?
   - Brand involved? If yes → run brand-asset-protocol.md first.
2. **Pick direction**: from `design-philosophies.md`. Recommend 3 from different schools.
3. **Pick landing pattern**: from `ui-styles-catalog.md` 8 landing styles. Common choices:
   - Hero-Centric for brand surfaces
   - Conversion-Optimized for lead gen
   - Feature-Rich for SaaS
   - Storytelling-Driven for agencies
4. **Set dials**: usually VARIANCE 7-9, MOTION 6-7, DENSITY 3-4 for brand landings.
5. **Build**: produce the page in single-file HTML or framework code. Follow `anti-patterns.md` always.
6. **Verify**: run `playwright-verification.md` at desktop + mobile.
7. **Polish**: run `/front polish` from `impeccable-commands.md`.

**Anti-patterns specific to landing pages**:
- Centered hero with subtitle + two equal CTAs (template cliché)
- "Trusted by" logo strip without saying which year (stale)
- "How it works" with three icon-circle steps (template cliché)
- Pricing table with three equal cards highlighted middle (template cliché)
- Footer wall of links you'd find on any SaaS

**Deliverable checklist**:
- [ ] Hero readable on mobile at 320px
- [ ] One primary CTA, one secondary at most
- [ ] Real product screenshot or honest placeholder (no CSS-drawn product)
- [ ] All copy real (no Lorem)
- [ ] LCP < 2.5s
- [ ] Form (if present) has labels + error states + success state

---

## 2. Product dashboard

**Goal**: help a user understand and act on operational data.

**Steps**:
1. **Shape**: 
   - Who's looking? (Persona shapes everything: SRE at 2am vs. CFO during quarterly review)
   - What action does this data drive?
   - What's the read frequency? (Glanceable / Investigatory / Comparative)
2. **Pick pattern**: from `ui-styles-catalog.md` 10 dashboard styles. Common:
   - Real-Time Monitoring for ops
   - Executive for C-suite
   - Data-Dense for analysts
3. **Set dials**: usually DENSITY 6-9 (operations) or 4-5 (executive); MOTION 3-5 (functional only); VARIANCE 4-6 (grid-strict).
4. **Build**: 
   - Cockpit register (mono fonts, tight padding, hairline borders) for ops
   - Calmer register (sans, generous padding) for executive
5. **Surface hierarchy**: 
   - Top: the KPIs people scan in 2 seconds
   - Middle: drill-down dimensions
   - Bottom: tables / raw data
6. **Empty / loading / error states**: mandatory.
7. **Verify**: `playwright-verification.md`.

**Anti-patterns specific to dashboards**:
- All-cards-no-tables (data tables matter for actionable density)
- Pure black/white (always tinted neutrals)
- Charts without baseline labels (hard to compare)
- Sparklines without scale anchors
- Sortable tables that don't actually sort

**Deliverable checklist**:
- [ ] Glanceable: primary KPI visible in 2 seconds
- [ ] Real data shape (not "1,234" placeholder)
- [ ] Refresh / last-updated indicator visible
- [ ] Empty / loading / error states for every data surface
- [ ] Mobile collapse strategy (not just hide everything)
- [ ] Keyboard accessible

---

## 3. Mobile screen / app surface

**Goal**: deliver an iOS / Android product screen.

**Steps**:
1. **Shape**: which device frame? (iOS most common; Android variants; web mobile).
2. **Single-file architecture**: prefer inline React with Babel `<script type="text/babel">`. Avoid external JS imports (file:// blocks them).
3. **iPhone bezel HARDBOUND**: use `huashu's ios_frame.jsx` if available (Dynamic Island fixed 124×36 at top:12). Never hand-code the bezel — position bugs guaranteed.
4. **Delivery form** (ask user):
   - **Overview**: All screens flat-tiled (design review, compare layouts). One iPhone frame per screen, non-interactive.
   - **Flow demo**: Single iPhone, embedded state machine. User journey clickable through.
5. **Real images mandatory**: pull from Wikimedia / Unsplash (with license check) / brand assets. Don't substitute with CSS gradients or generic SVG cards. Test: "would removing this image lose information?" — if yes, use real.
6. **Quality anchors when no design system exists**:
   - Font: serif display (Newsreader / Source Serif / EB Garamond) + sans body (NOT Inter; use Geist / Switzer)
   - Color: one warm base + one accent (rust / green / deep red) across whole app
   - Density: minimal by default (fewer containers, fewer borders, fewer decorative icons) UNLESS product is AI/data-heavy (then 3+ data signals visible per screen to justify intelligence)
   - One signature detail per app (worth screenshotting): oil-paint texture, serif italic quote, full-screen waveform.
7. **Verify**: Playwright at 390×844, also at 320×568 (small mobile).

**Anti-patterns specific to mobile**:
- Desktop layout shoved into a phone (rethink, don't shrink)
- Sub-44px touch targets
- Bottom nav with 5+ icons (cluttered; 4 max with labels)
- `position: fixed` toolbar that covers content (use `position: sticky` + `safe-area-inset-bottom`)

---

## 4. Pitch deck / slides

**Goal**: slide deck for presentation.

**Steps**:
1. **Format**: HTML deck (browser-driven) by default — gives motion, interactivity, web fonts. Editable PPTX only if user explicitly needs offline.
2. **Layout**: 16:9 (`1920×1080` virtual canvas, scale with `transform: scale()` to viewport).
3. **One idea per slide**: hero element + supporting copy. Never crowded.
4. **Type hierarchy huge**: display 80–160px, body 32–48px. Slides are seen from across rooms.
5. **Speaker notes**: `<aside class="notes">` per slide for the human delivering.
6. **Navigation**: keyboard arrows, mouse click anywhere advances.
7. **Export**: 
   - PDF: Playwright headless print.
   - PPTX (editable): use `huashu/scripts/html2pptx.js` if available.
   - Video MP4: capture with Playwright frames + FFmpeg (see motion-pipeline.md).
8. **Verify**: Playwright at 1920×1080.

**Anti-patterns specific to slides**:
- 5 bullet points per slide (read it yourself instead)
- Stock photo with logo overlay (template cliché)
- "Thank you" slide that's blank (use it for one final point)
- Title with subtitle subtitle subtitle (lazy intro)

---

## 5. Email template

**Goal**: HTML email that renders consistently in Gmail / Outlook / Apple Mail.

**Steps**:
1. **Constraint reminder**: email HTML is 1999 HTML. No flexbox in Outlook, limited CSS support, table-based layout for cross-client.
2. **Tools**: use MJML if available — generates email-safe HTML from cleaner markup.
3. **Width**: 600px standard. Some templates use 640px.
4. **Type**: web-safe fallback chain: `font-family: "Geist", -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;`. Custom webfonts via `<link>` work in Apple Mail / Gmail web; not Outlook.
5. **Dark mode**: support `@media (prefers-color-scheme: dark)` for Apple Mail.
6. **Mobile**: stacked single column on phone; use `<meta name="viewport">`.
7. **Anti-patterns**:
   - No background image (Outlook strips it)
   - No `position: absolute`
   - Inline all CSS (gmail / outlook strip `<style>` blocks)
   - Test in Litmus / Email on Acid before shipping

---

## 6. Component library / design system

**Goal**: reusable components + tokens.

**Steps**:
1. **Tokens first**: define primitives (color scale 0-1000, type scale, spacing scale, radius scale, shadow scale).
2. **Semantic layer**: `--surface-1`, `--text-primary`, `--accent` — these reference primitives, never raw values.
3. **Component layer**: build `Button`, `Input`, `Card`, `Modal`, etc on top of semantic tokens.
4. **Variant matrix**: each component has variants × sizes × states. Document the matrix.
5. **Documentation**: Storybook / Ladle / inline doc page. Show every variant.
6. **Theme switching**: build for light + dark from the start. Token swaps, not CSS overrides.

See `ui-ux-pro-max-skill` references for token architecture details if needed.

---

## 7. Brand identity board

**Goal**: present brand direction to client.

**Steps**:
1. **Layout**: 3-7 boards covering: Logo / Color / Typography / Voice / Photography style / Layout grid / Sample compositions.
2. **One idea per board**: don't cram.
3. **Format**: HTML single-page (scroll through), or 16:9 PDF deck.
4. **Real or honest**: if logo not designed yet, use a placeholder + note (e.g., "Logo TBD — 3 directions proposed below"). Don't fake it.
5. **Tools**: see `huashu/brandkit/SKILL.md` if installed (board generation).

---

## 8. Redesign existing surface

**Goal**: improve an existing UI without rewriting from scratch.

**Steps**:
1. **Don't rewrite**: identify the highest-impact 3-5 issues, fix those.
2. **Audit pass**: run `audit` from impeccable-commands.md (technical: a11y, perf, responsive).
3. **Critique pass**: run `critique` (subjective: 5D rubric).
4. **Triage**: 
   - CRITICAL: ship-blockers (accessibility violation, broken interaction)
   - HIGH: clear quality lift (typography, color discipline, spacing rhythm)
   - MEDIUM: nice-to-have (motion polish, copy refinement)
   - LOW: defer or skip
5. **Apply CRITICAL + HIGH**. Skip MEDIUM unless cheap. Skip LOW.
6. **Verify** at original + new screens side-by-side.

**Anti-patterns**:
- Sweeping rewrite when the user asked for a polish
- Changing brand colors without authorization
- "Modernising" by adding gradients (when the issue is something else)

---

## 9. Demo animation / hero loop

**Goal**: 5-15 second looped video / GIF showing a product moment.

**Steps**:
1. **One move**: pick ONE primary motion (camera pan, particle reveal, type assembly, kinetic logo).
2. **Loop point**: hide the loop. Start and end at the same camera position.
3. **Duration**: 5-15s. < 5 = too short to watch. > 15 = needs narration.
4. **Audio**: short BGM stem + 1-2 SFX cues. Mute autoplay (browser blocks unmuted).
5. **Export**: see motion-pipeline.md Section D. MP4 H.264 + GIF + WebM.

---

## 10. Narrated explainer video

**Goal**: 2-8 minute video that explains something.

**Steps**:
1. **Write script first**: markdown with `## scene-N` headings + `[[cue:name]]` markers.
2. **Run TTS pipeline**: generate `voiceover.mp3` + `timeline.json`.
3. **Design animation USING timeline as source of truth** (not vice versa).
4. **Hero element per scene**: one primary thing on screen.
5. **7-segment morph**: one thing persists / morphs scene-to-scene (gives continuity).
6. **Always motion**: every frame has SOMETHING moving (drift, particles, zoom).
7. **Subtitles**: dark ink + white outer glow (B站 readable style); auto-wrap ≤ 12 chars.
8. **Render**: Playwright frames at 25fps → assemble with FFmpeg → optional 60fps interpolation pass.
9. **QA**: watch end-to-end, ensure cues land on narration beats.

See motion-pipeline.md Section E for full workflow.

---

## Universal closing checklist (every deliverable)

- [ ] Anti-patterns check (`anti-patterns.md`)
- [ ] Real copy, real images (no Lorem, no fake names, no CSS-drawn product mocks)
- [ ] Verified at relevant viewports
- [ ] Console clean
- [ ] One coherent aesthetic
- [ ] One memorable moment
- [ ] DNA prompt documented for future iteration
- [ ] Hand-off / next-step suggestion
