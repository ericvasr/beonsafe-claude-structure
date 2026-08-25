# UX & Interaction — states, flows, forms, accessibility as design

Load in Phase 3 (plan the states) and Phase 4 (build them). The visual references make a page *beautiful*; this one makes a product *work under real conditions*. A screen is not done when the happy path renders — it is done when empty, loading, error, and success all feel intentional.

**Prime rule:** every screen has states, not a state. Design the whole set before shipping the first.

---

## 1. The five states — anatomy, not checklist

For any data-backed surface (list, dashboard, table, card grid, detail view) design all five. "It should have an empty state" is not design; the anatomy below is.

### Empty
Three kinds — never render a blank box:
- **First-use (nothing yet):** icon/illustration + one-line headline ("No projects yet") + one sentence of *why it's empty and what to do* + **primary action** ("Create your first project"). This is onboarding, not an error — make it inviting.
- **No-results (filter/search):** state the query ("No results for 'foo'") + how to broaden ("Clear filters" / "Try fewer words"). Never the first-use copy here.
- **Cleared (user emptied it):** brief confirmation tone, offer undo if destructive.

### Loading
Pick by *expected latency*, not by habit:
- **< 300ms:** nothing. A flash of spinner is worse than the wait.
- **300ms–1s:** skeleton that mirrors the real layout (same boxes, shimmer sweep). Preserves layout → no CLS.
- **> 1s or unknown:** skeleton + progress affordance; for actions, optimistic UI (render the result immediately, reconcile on response, roll back on failure).
- Never a full-page spinner when only a region is loading. Scope the loader to what's actually pending.

### Error
Errors are UX copy + recovery, never a raw stack:
- **What failed** in human terms ("Couldn't save your changes").
- **Why / what now** ("Check your connection and retry" — actionable, not "Error 500").
- **Recovery action** inline: Retry, Undo, Contact. Keep the user's input — never clear a form on error.
- **Scope:** field error → inline at the field; section error → banner in the section; app error → boundary screen with a way back. Match blast radius to scope.

### Success
- Confirm without nagging: inline check, toast (auto-dismiss 4–6s), or state change. Destructive/irreversible actions get a persistent confirmation + undo window.
- Don't toast the obvious (a saved toggle that visibly toggled needs no toast).

### Disabled
- Disabled must say *why* (tooltip / helper text) — a dead button with no reason is a dead end.
- Prefer "enabled but validates on click with a reason" over silently disabled when the fix is non-obvious.

---

## 2. Forms — the highest-friction surface

- **Validation timing:** validate on blur for format ("valid email"), on submit for completeness, never on every keystroke (except positive affordances like a password-strength meter). Show success inline once a field passes.
- **Errors:** inline, adjacent to the field, specific ("Password needs 8+ characters" not "Invalid"). On submit with multiple errors: summary at top with anchor links + inline markers. Move focus to the first error.
- **Input states:** design default / focus / filled / error / disabled / loading (async validation, e.g. "checking username…") for every input.
- **Required:** mark it (asterisk + legend, or mark optional if most are required). Never make the user guess.
- **Affordance:** labels always visible (placeholder is not a label — it vanishes). Input type triggers the right mobile keyboard (`type=email/tel/number`, `inputmode`). Autocomplete tokens set.
- **Submit:** disable-and-spinner on the button during submit to prevent double-send; keep all entered data; on success, clear or advance intentionally.

---

## 3. Multi-step flows (wizard, checkout, onboarding)

Scroll narratives (see `page-architecture.md`) are *reading* flows; these are *task* flows.
- **Progress:** always show where I am and how many steps ("Step 2 of 4"). Let me go back without losing data.
- **Per-step validation:** validate before advancing; don't dump all errors at the end.
- **State between steps:** persist entered data (draft), survive refresh for long flows.
- **Error recovery mid-flow:** a failure at step 3 returns me to step 3 with context, not to step 1.
- **Exit:** confirm before discarding a partially-filled flow; offer "save & finish later" for long ones.
- **Completion:** a real success screen — what happened, what's next, a way forward. Not a dead "Done."

---

## 4. Accessibility as UX (not just contrast)

Contrast/AA lives in `anti-patterns.md`. This is the *interaction* half — it is UX, not compliance box-ticking:

- **Keyboard:** every interactive element reachable and operable by keyboard. Logical tab order (matches visual order). Composite widgets (menus, tabs, grids) use roving tabindex + arrow keys, not 30 tab stops.
- **Focus visible:** never remove the focus ring — restyle it (`:focus-visible`, 2px offset ring in an accent). Focus must always be locatable.
- **Focus management:** open a modal → move focus in and trap it; close → return focus to the trigger. SPA route change → move focus to the new page's `<h1>` or a live region so screen-readers announce the change. This is the #1 thing agents forget.
- **Screen-reader flow:** async content updates via `aria-live` (`polite` for status, `assertive` for errors); `aria-busy` during load; form errors announced. Icon-only buttons get `aria-label`. Decorative images `alt=""`.
- **ARIA patterns per component:** use the established roles — `dialog` (+ `aria-modal`), `tablist/tab/tabpanel`, `combobox`, `disclosure`, `menu`. Don't invent; follow the WAI-ARIA Authoring Practices pattern for the widget.
- **Targets & motion:** touch targets ≥ 44×44px; honor `prefers-reduced-motion` (see `motion-pipeline.md`); don't convey state by color alone (add icon/text).

---

## 5. Feedback & affordance

- **Affordance:** clickable things look clickable (cursor, hover state, elevation/underline). Non-obvious interactions get a hint.
- **Responsiveness of feedback:** every action acknowledges within 100ms (press state), even if the result is async (then loading, then result). Silence reads as "broken."
- **Optimistic where safe:** toggles, likes, reorder — render instantly, reconcile in background, roll back visibly on failure.
- **Toasts vs inline:** transient/non-blocking → toast; consequential/needs decision → inline or dialog. Never a toast for an error the user must act on.

---

## Quick gate (Phase 5 add-on)

Before shipping any interactive surface:
- [ ] All five states designed (empty/loading/error/success/disabled), not just happy path
- [ ] Loading choice matches expected latency; skeleton mirrors layout (no CLS)
- [ ] Errors keep user input + give a recovery action, scoped correctly
- [ ] Forms: blur/submit validation, inline specific errors, focus moves to first error
- [ ] Keyboard: full operability, visible focus, modal focus trap + return, route-change focus/announce
- [ ] Async updates announced (`aria-live`); icon buttons labeled
- [ ] Every action gives feedback < 100ms
