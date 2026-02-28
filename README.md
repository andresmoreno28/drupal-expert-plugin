# Drupal Expert — Claude Code Plugin

A Claude Code plugin that turns your AI assistant into a senior Drupal 11 developer. Enforces coding standards, best practices, SOLID/DRY/Clean Code principles, security, accessibility, and performance across any Drupal project.

## Installation

```bash
claude plugin marketplace add https://github.com/andresmoreno28/drupal-expert-plugin.git
claude plugin install drupal-expert@drupal-expert-plugin
```

Restart Claude Code after installation.

## What's Included

### 8 Skills

| Skill | Command | What it does |
|-------|---------|-------------|
| **Core Expert** | `/drupal-expert` | PHP standards, DI, hooks, plugins, forms, routing, caching, security — the foundational Drupal knowledge |
| **Module Dev** | `/drupal-module` | Scaffold modules, config entities, services, events, permissions, routing patterns |
| **Theme & SDC** | `/drupal-theme` | SDC components, Twig templates, BEM/CSS, JS behaviors, libraries, design tokens |
| **Migrations** | `/drupal-migration` | D7→D11 migrations, source/process/destination plugins, Drush commands, CSV/JSON/SQL sources |
| **Recipes** | `/drupal-recipe` | Generate Drupal Recipes, config actions, composable site building |
| **Code Review** | `/drupal-review` | 8-category review checklist: architecture, PHP quality, security, performance, a11y, CSS/JS |
| **Security Audit** | `/drupal-security` | OWASP Top 10 applied to Drupal, CSRF, XSS, SQL injection, file upload, access control |
| **Design to Drupal** | `/design-to-drupal` | Figma → design tokens → SDC components → theme structure (requires Figma MCP) |

### 2 Automated Hooks (PostToolUse)

- **PHP Validation** — After every `.php`, `.module`, `.install`, `.theme` edit: checks `strict_types`, service injection, form property visibility, return types, security anti-patterns
- **Twig Validation** — After every `.twig` edit: checks for business logic in templates, proper escaping, BEM naming, translation, accessibility, hardcoded URLs

### 1 Agent

- **drupal-reviewer** — Autonomous code reviewer that scans modules/themes against Drupal coding standards with confidence-based severity filtering

## Skills Auto-Trigger

You don't need to type `/drupal-expert` every time. Skills activate automatically when Claude detects Drupal-related work — mentions of modules, hooks, Twig, services, Drush, SDC, config entities, etc.

## Recommended Companion Tools

| Tool | Purpose | Install |
|------|---------|---------|
| [MCP Tools](https://www.drupal.org/project/mcp_tools) | 222 Drupal tools via MCP — create content types, fields, views directly | `composer require drupal/mcp_tools` |
| [Context7](https://github.com/anthropics/claude-plugins-official) | Up-to-date Drupal API docs in real time | `claude plugin install context7@claude-plugins-official` |
| [Figma MCP](https://github.com/figma/mcp-server-guide) | Read Figma designs for design-to-Drupal workflow | `claude plugin install figma@claude-plugins-official` |

## Requirements

- Claude Code CLI
- PHP 8.3+ (for the projects you work on)
- Drupal 10.3+ or 11

## Project Structure

```
drupal-expert-plugin/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── drupal-expert/SKILL.md
│   ├── drupal-module/SKILL.md
│   ├── drupal-theme/SKILL.md
│   ├── drupal-migration/SKILL.md
│   ├── drupal-recipe/SKILL.md
│   ├── drupal-review/SKILL.md
│   ├── drupal-security/SKILL.md
│   └── design-to-drupal/SKILL.md
├── hooks/
│   ├── hooks.json
│   ├── validate-drupal-code.sh
│   └── validate-twig.sh
├── agents/
│   └── drupal-reviewer.md
└── package.json
```

## Updating

```bash
claude plugin update drupal-expert@drupal-expert-plugin
```

## License

GPL-2.0-or-later
