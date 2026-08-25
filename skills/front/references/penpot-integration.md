# Penpot Integration — Design-to-Code Style Pipeline

MCP server: `penpot` (HTTP at `http://localhost:4401/mcp`).
Requires: Penpot open with the MCP plugin connected ("Connected" status in plugin UI).

## When to use

- **User references a Penpot file/project** — extract styles before coding
- **Brand-specific work** — Penpot is the source of truth for colors, typography, spacing, components
- **Design handoff** — pull exact design tokens from Penpot instead of guessing
- **Audit against source** — compare implemented code vs. Penpot source design

## Style extraction workflow

### Step 1 — Discover available data

Use Penpot MCP tools to:
1. List available projects and files
2. Navigate to the relevant page/frame
3. Extract component hierarchy

### Step 2 — Extract design tokens

Pull from Penpot (in priority order):

| Token type | What to extract | Maps to |
|-----------|----------------|---------|
| **Colors** | Fill colors, stroke colors, gradients | oklch values for `color-system.md` compliance |
| **Typography** | Font family, size, weight, line-height, letter-spacing | Font pairing validation via `typography-system.md` |
| **Spacing** | Padding, margins, gaps between elements | Spacing scale derivation |
| **Border radius** | Corner radius values | Shape language consistency |
| **Shadows** | Box-shadow / drop-shadow specs | Elevation system |
| **Components** | Reusable component structure | Component architecture |
| **Layout** | Grid/flex structure, constraints | Responsive breakpoint strategy |

### Step 3 — Generate brand-spec from Penpot

After extraction, write `brand-spec.md` (or update existing) with:

```markdown
# Brand Spec — [Project Name]
Source: Penpot file "[file-name]", page "[page-name]"
Extracted: [date]

## Colors
- Primary: oklch(L C H) — original hex: #XXXXXX
- Secondary: ...
- Neutrals: ...

## Typography
- Display: [font] [weight] / [size]px / [line-height]
- Body: [font] [weight] / [size]px / [line-height]

## Spacing scale
- Base unit: Xpx
- Scale: [derived from Penpot measurements]

## Components (from Penpot)
- [component-name]: [structure notes]
```

### Step 4 — Validate against /front anti-patterns

After extracting Penpot styles, validate:
- Fonts not in ban list (`typography-system.md`)
- Colors converted to oklch, no pure `#000`/`#fff`
- If Penpot design uses banned patterns (emoji icons, gradient text), flag to user before implementing

## Bidirectional workflow

### Design → Code (primary)
1. Extract from Penpot → generate tokens → build with /front rules → verify with Playwright

### Code → Design (feedback)
1. After implementation, use Penpot MCP tools to update or annotate the Penpot file with:
   - Final CSS values used (if adjusted from source)
   - Responsive adaptations made
   - Component variants added during implementation

## Integration with /front decision tree

Penpot check inserts BEFORE the existing setup phase:

```
USER REQUEST involves design work
   │
   ├─ Penpot MCP available? (check tool list)
   │   ├─ YES → Query for relevant project/file
   │   │         Extract design tokens
   │   │         Generate/update brand-spec.md
   │   │         Continue to normal decision tree with real data
   │   │
   │   └─ NO → Skip (proceed without Penpot data)
   │
   └─ Continue normal /front decision tree
```

## Error handling

- **Plugin not connected**: Inform user: "Penpot plugin nao conectado. Abra o Penpot, carregue o plugin MCP e clique Connect."
- **No matching file**: Ask user which Penpot file/page to reference
- **Stale data**: Always re-extract if design was updated since last extraction (check file modification time via MCP)
