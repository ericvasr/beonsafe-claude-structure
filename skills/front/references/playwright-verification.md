# Playwright Verification — Page QA After Each Deliverable

Use this AFTER code is written, BEFORE declaring the deliverable done. Also used in Phase 1 (pre-evaluation) to screenshot existing state.

## Tool reference

The Playwright Claude plugin provides MCP tools with this prefix:
```
mcp__plugin_playwright_playwright__browser_*
```

### Available tools

| Tool | Purpose |
|------|---------|
| `browser_navigate` | Open a URL in the browser |
| `browser_take_screenshot` | Capture the current page |
| `browser_resize` | Change viewport dimensions |
| `browser_snapshot` | Get accessibility tree (a11y audit) |
| `browser_console_messages` | Read console log/warn/error |
| `browser_network_requests` | List all network requests |
| `browser_click` | Click an element |
| `browser_fill_form` | Fill form inputs |
| `browser_hover` | Hover over element |
| `browser_type` | Type text into focused element |
| `browser_press_key` | Press keyboard key |
| `browser_evaluate` | Execute arbitrary JS in page context |
| `browser_select_option` | Select dropdown option |
| `browser_wait_for` | Wait for element/condition |
| `browser_tabs` | List open tabs |
| `browser_close` | Close browser |

All calls use the full prefix: `mcp__plugin_playwright_playwright__browser_navigate`, etc.

---

## Standard verification flow (5 steps)

```
1. NAVIGATE   → Open the page in browser
2. SCREENSHOT → Capture at 3 viewports
3. INSPECT    → Console, network, a11y snapshot
4. CRITIQUE   → Self-judge against 5D rubric + slop test
5. REPORT     → Surface findings; fix CRITICAL before done
```

### Step 1 — Navigate

```
mcp__plugin_playwright_playwright__browser_navigate({ url: "http://localhost:3000" })
```

If the user has a dev server running, use that URL. Otherwise:
- Ask: "Dev server running? URL?"
- For static files: `file:///absolute/path/to/index.html`

### Step 2 — Screenshot (3 viewports)

**Desktop (1440×900):**
```
mcp__plugin_playwright_playwright__browser_resize({ width: 1440, height: 900 })
mcp__plugin_playwright_playwright__browser_take_screenshot()
```

**Tablet (768×1024):**
```
mcp__plugin_playwright_playwright__browser_resize({ width: 768, height: 1024 })
mcp__plugin_playwright_playwright__browser_take_screenshot()
```

**Mobile (390×844):**
```
mcp__plugin_playwright_playwright__browser_resize({ width: 390, height: 844 })
mcp__plugin_playwright_playwright__browser_take_screenshot()
```

After capture, **visually inspect** each screenshot:
- Layout integrity (nothing overflowing, nothing missing)
- Type hierarchy clear
- Color palette coherent
- No accidental scrollbars
- Hero section readable on mobile (most common failure mode)

### Step 3 — Inspect (3 channels)

**Console:**
```
mcp__plugin_playwright_playwright__browser_console_messages()
```
Expected: **zero errors**. Warnings investigated or explained.

**Network:**
```
mcp__plugin_playwright_playwright__browser_network_requests()
```
Check for:
- 404s (broken images, missing CSS/JS)
- Oversized assets (> 500kB without reason)
- Excessive requests (> 50 on first load)
- Third-party trackers if not expected

**Accessibility:**
```
mcp__plugin_playwright_playwright__browser_snapshot()
```
Inspect the tree for:
- Correct heading hierarchy (one `<h1>`, descending logical order)
- Landmarks present (`<main>`, `<nav>`, `<header>`, `<footer>`)
- Buttons have accessible names (not empty `<button>`)
- Form inputs have labels
- Images have alt text (or `alt=""` for decorative)
- Color contrast (WCAG AA minimum: 4.5:1 body, 3:1 large text)

### Step 4 — Self-critique (5D rubric + slop test)

**5D Rubric** (from `impeccable-commands.md → critique`):

| Dimension | What to check | Pass threshold |
|-----------|---------------|----------------|
| Philosophy coherence | Does one direction dominate, or did averaging happen? | 7/10 |
| Visual hierarchy | Can the eye find the primary action in < 2 seconds? | 7/10 |
| Execution craft | Spacing rhythm tight? Alignment perfect? Type scale clean? | 8/10 |
| Functionality | Does the surface serve the user's goal, or decorate? | 8/10 |
| Innovation | Is there ONE moment that's memorable? | 6/10 |

Below threshold on any dimension → fix before declaring done. Below 5/10 on philosophy or hierarchy → reconsider approach.

**Anti-AI Slop Test** (mandatory):
- Show screenshot to an imaginary stranger. Can they guess the product category from the design alone?
- If yes → identify the weakest dimension (usually: default fonts, symmetric layout, or category-default color) and fix it.
- Run the full checklist from `anti-patterns.md`.

### Step 5 — Report

Output a verification block:

```
## /front verify · result

### Viewports tested
- Desktop 1440×900 ✓
- Tablet 768×1024 ✓
- Mobile 390×844 ✓

### Channels
- Console: 0 errors, 0 warnings ✓
- Network: 0 4xx/5xx ✓, largest asset [n]kB
- A11y: heading hierarchy clean, all buttons named, no contrast issues

### Anti-AI Slop Gate: PASS
- Distinctive font pairing: [fonts used]
- Tinted neutrals: [chroma values]
- Layout breaks: [where grid is intentionally broken]
- Memorable moment: [what it is]

### 5D Rubric
- Philosophy: [n]/10 ([direction used])
- Hierarchy: [n]/10
- Craft: [n]/10
- Function: [n]/10
- Innovation: [n]/10

### Issues found + fixed inline
- [list of fixes applied]

### Status: SHIP
```

If anything was NOT fixed: `### Status: BLOCKED — open items: ...`

---

## Specialised checks

### For scroll / animation-heavy surfaces

Capture multiple scroll positions:
```
mcp__plugin_playwright_playwright__browser_evaluate({ code: "window.scrollTo(0, 0)" })
mcp__plugin_playwright_playwright__browser_take_screenshot()

mcp__plugin_playwright_playwright__browser_evaluate({ code: "window.scrollTo(0, document.body.scrollHeight / 2)" })
mcp__plugin_playwright_playwright__browser_take_screenshot()

mcp__plugin_playwright_playwright__browser_evaluate({ code: "window.scrollTo(0, document.body.scrollHeight)" })
mcp__plugin_playwright_playwright__browser_take_screenshot()
```

Check each position for:
- Layout shift during scroll
- Elements overlapping incorrectly
- Sticky/fixed elements behaving properly
- `prefers-reduced-motion` respected

### For form-heavy surfaces

Run interactive checks:
```
mcp__plugin_playwright_playwright__browser_fill_form({ ... })
mcp__plugin_playwright_playwright__browser_click({ element: "Submit button" })
mcp__plugin_playwright_playwright__browser_take_screenshot()
```

Verify:
- Error states render correctly
- Success states provide feedback
- Empty states are actionable
- Validation messages are clear

### For dashboards / data UIs

Evaluate with different data states:
```
# Check empty state
mcp__plugin_playwright_playwright__browser_evaluate({ code: "..." })
mcp__plugin_playwright_playwright__browser_take_screenshot()
```

Verify:
- Empty state is actionable (not just "No data")
- Long text truncates gracefully
- Large numbers format correctly
- Null/missing fields have fallback display

### For multi-page flows

Walk the flow end-to-end:
```
mcp__plugin_playwright_playwright__browser_navigate({ url: "/" })
mcp__plugin_playwright_playwright__browser_click({ element: "Sign up link" })
mcp__plugin_playwright_playwright__browser_take_screenshot()
... continue through flow
```

Screenshot each step. Verify hand-offs (state passing between routes).

---

## Video/animation capture (frame-by-frame approach)

Playwright does NOT have video recording tools. For capturing animation sequences:

1. Use `browser_evaluate` to control animation state (set `t` parameter, trigger keyframes)
2. Take sequential screenshots at key moments
3. For full video export, use the FFmpeg pipeline from `motion-pipeline.md` Section D

```
# Frame-by-frame capture
mcp__plugin_playwright_playwright__browser_evaluate({ code: "window.setAnimationTime(0)" })
mcp__plugin_playwright_playwright__browser_take_screenshot()

mcp__plugin_playwright_playwright__browser_evaluate({ code: "window.setAnimationTime(0.25)" })
mcp__plugin_playwright_playwright__browser_take_screenshot()

# ... etc, then assemble with FFmpeg
```

---

## Failure modes to watch for

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Screenshot all white | Page errored before paint; check console | Fix JS error |
| Screenshot full of placeholder boxes | Images failing to load (CORS, 404, hotlink) | Use real assets or `picsum.photos` |
| Mobile screenshot fits desktop content squashed | No responsive CSS or breakpoints | Add `@media` rules or Tailwind responsive variants |
| Console has "key prop" warnings | Missing `key` in `.map()` | Add stable keys |
| Network shows fonts loaded multiple times | Multiple font `<link>` URLs | Consolidate to one fonts request |
| A11y tree missing landmarks | `<div>` soup instead of semantic HTML | Use `<header>`, `<main>`, `<nav>`, `<footer>` |
| Layout shifts visible during load | Images/fonts without dimensions | Add `width`/`height` or `aspect-ratio` |

---

## When Playwright is unavailable

If MCP tools aren't loaded, do verification manually:

1. Ask user to open the page in a browser
2. Ask them to paste:
   - A screenshot (desktop + mobile)
   - Console output (DevTools console tab)
   - Network panel (filter by Status > 399)
3. Inspect what they send and apply the same 5D critique + slop test
4. Suggest installing the Playwright plugin for next time

---

## Integration with /front phases

- **Phase 1** (pre-evaluation): use navigate + resize + screenshot to capture CURRENT state before changes
- **Phase 5** (verification): full flow above — screenshot + inspect + critique + slop gate + report
- Both phases are **mandatory** for non-trivial deliverables
