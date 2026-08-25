# /front — Frontend Design Orchestrator

A meta-skill installed in `~/.claude/skills/front/` that orchestrates four frontend design systems + Playwright verification into a single tool. Available globally in any Claude Code session.

## Quickstart

In any Claude Code session, type:

```
/front <command-or-natural-language> <target>
```

Or just describe a frontend task naturally — the skill auto-triggers on words like *design, UI, polish, audit, redesign, dashboard, landing, mockup, palette, typography, motion, anti-slop*.

### Examples

```
/front craft landing page for fintech startup
/front audit the dashboard at localhost:3000
/front polish the hero section
/front bolder the homepage
/front live the pricing card  ← variant playground mode
/front verify  ← post-implementation Playwright pass
```

Or natural:

```
Redesign this dashboard to feel more like ops cockpit
Make the LLM panel feel less AI-template
Add a hero animation that doesn't scream Vercel
Check this page for slop and AI tells
```

## What it integrates

| Layer | Source | Role |
|-------|--------|------|
| 23 commands | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | craft / audit / polish / distill / harden / animate / colorize / live / … |
| Parametric dials | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) | DESIGN_VARIANCE / MOTION_INTENSITY / VISUAL_DENSITY |
| Direction advisor + motion/audio | [alchaincyf/huashu-design](https://github.com/alchaincyf/huashu-design) | 20-philosophy library, brand-asset protocol, BGM/SFX pipeline |
| Data-driven reasoning | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | 161 products × 67 styles × 161 palettes × 57 typography pairings |
| Page QA | [Playwright Claude plugin](https://claude.com/plugins/playwright) | Screenshot / console / network / a11y |

## File structure

```
~/.claude/skills/front/
├── SKILL.md                    ← orchestrator + decision tree
├── README.md                   ← this file
└── references/                 ← loaded on demand
    ├── anti-patterns.md
    ├── design-philosophies.md
    ├── impeccable-commands.md
    ├── taste-dials.md
    ├── ui-styles-catalog.md
    ├── color-system.md
    ├── typography-system.md
    ├── motion-pipeline.md
    ├── brand-asset-protocol.md
    ├── playwright-verification.md
    └── workflow-templates.md
```

The orchestrator loads only the references needed for the current task (progressive disclosure).

## Iron principles

1. Anti-AI-slop is the prime directive. If a stranger could guess theme + palette + layout from category alone, you have not designed — you have averaged a training set.
2. Real working code, not figma exports.
3. Commit to a register (brand vs product).
4. Context first, blank page last.
5. Variations beat single answers.
6. Verify visually with Playwright before declaring done.

## Updating / customising

Edit any reference file. The orchestrator loads them on demand, so changes take effect on next invocation.

To add a new philosophy / pairing / style, append to the relevant reference (`design-philosophies.md`, `typography-system.md`, etc).

To change which references are loaded for a given task, edit the decision tree in `SKILL.md`.

## Removing

```bash
rm -rf ~/.claude/skills/front/
```

Or back to the generic `frontend-design:frontend-design` skill — that one continues to work alongside `/front`. `/front` is the more opinionated, anti-slop replacement.

## Procedência e licença

Esta skill é uma composição. A orquestração e a maior parte das referências são autorais;
parte do conteúdo consolida conceitos de quatro projetos de terceiros:

| Fonte | Licença | Copyright |
|---|---|---|
| [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | Apache-2.0 | Copyright 2025 Paul Bakaus |
| [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) | MIT | Copyright (c) 2026 Leonxlnx |
| [alchaincyf/huashu-design](https://github.com/alchaincyf/huashu-design) | MIT | Copyright (c) 2026 alchaincyf (花叔 · 花生) |
| [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | MIT | Copyright (c) 2024 Next Level Builder |

O Playwright é **citado, não redistribuído** — instale o plugin oficial da Microsoft.

**A atribuição completa está em [`PROCEDENCIA.md`](PROCEDENCIA.md)**: o texto de cada
licença, onde cada fonte entra arquivo por arquivo, a declaração de modificação exigida
pela Apache-2.0 §4(b) e os avisos do NOTICE original do impeccable.

Licença da composição: MIT. As condições de origem continuam valendo sobre as partes
derivadas de cada fonte.
