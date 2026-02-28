---
description: Convert Figma designs to Drupal SDC components and theme structure. Use when user says "implement this design", "Figma to Drupal", "design to code", "convert design", "create components from design", provides a Figma URL, or wants to translate visual designs into Drupal theme code.
user_invocable: true
---

# Design-to-Drupal Workflow

## Overview

This skill converts Figma designs into production-ready Drupal SDC components, design tokens, and theme structure. It uses the Figma MCP to read designs and generates Drupal-native code.

## Step-by-Step Process

### Step 1: Read the Design

Use Figma MCP tools to understand the design:

1. `get_design_context` — Get component code + screenshot + hints
2. `get_screenshot` — Visual reference for the design
3. `get_metadata` — File structure, pages, components list

Extract from the design:
- **Colors** — All unique color values
- **Typography** — Font families, sizes, weights, line heights
- **Spacing** — Padding, margins, gaps
- **Border radii** — Corner radius values
- **Shadows** — Box shadow definitions
- **Components** — Reusable UI elements
- **Layout patterns** — Grid systems, flex layouts

### Step 2: Generate Design Tokens

Create `css/base/tokens.css` in the theme:

```css
:root {
  /* Colors */
  --color-primary: #0057b8;
  --color-primary-hover: #004a9e;
  --color-surface: #ffffff;
  --color-surface-alt: #f5f5f5;
  --color-border: #e0e0e0;
  --color-text: #1a1a1a;
  --color-text-muted: #666666;
  --color-success: #2e7d32;
  --color-warning: #f57f17;
  --color-error: #c62828;

  /* Typography */
  --font-family-body: 'Inter', system-ui, sans-serif;
  --font-family-mono: 'JetBrains Mono', monospace;
  --font-size-xs: 0.75rem;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.25rem;
  --font-size-xl: 1.5rem;
  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-bold: 700;

  /* Spacing (4px base) */
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-6: 1.5rem;
  --space-8: 2rem;
  --space-12: 3rem;

  /* Borders */
  --radius-sm: 0.25rem;
  --radius: 0.5rem;
  --radius-lg: 0.75rem;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 25px rgba(0, 0, 0, 0.15);

  /* Transitions */
  --transition-fast: 150ms ease;
  --transition-normal: 250ms ease;
}
```

### Step 3: Map Components to SDC

For each design component, create an SDC:

1. **Identify the component** — Name, purpose, variants
2. **Define the schema** — Props, types, required fields
3. **Write the template** — Twig with BEM classes
4. **Write the styles** — CSS using ONLY token custom properties
5. **Write the behavior** — JS if interactive (Drupal.behaviors + once)

### Step 4: Map to Drupal Entities

Design elements map to Drupal structures:

| Design Element | Drupal Mapping |
|---|---|
| Page layout | Layout Builder / page template |
| Card component | SDC + Paragraph type or ViewMode |
| Navigation | Menu + SDC template |
| Form | Form API + SDC wrapper |
| List/Grid | View + SDC row template |
| Hero section | Paragraph type + SDC |
| Footer | Block region + SDC |

### Step 5: Generate Theme Structure

```
themes/custom/mytheme/
  mytheme.info.yml
  mytheme.libraries.yml
  mytheme.theme
  css/
    base/
      tokens.css
      reset.css
      typography.css
    layout/
      grid.css
    component/
      buttons.css
  components/
    card/
    hero/
    navigation/
    footer/
  templates/
    page.html.twig
    node--article--teaser.html.twig
```

## Translation Rules: Design → Drupal

### Colors
- Figma hex values → CSS custom properties in `tokens.css`
- Never hardcode hex in component CSS
- Map Figma color styles to semantic tokens (`--color-primary`, not `--blue-500`)

### Typography
- Figma text styles → `--font-size-*`, `--font-weight-*`, `--line-height-*` tokens
- Include web font loading in `.libraries.yml`
- Use `rem` units, never `px` for font sizes

### Spacing
- Figma auto-layout gaps/padding → `--space-*` tokens
- Establish a spacing scale (4px or 8px base)
- Map ALL spacing to the scale — round to nearest value

### Layout
- Figma frames → CSS Grid or Flexbox
- Auto-layout → Flexbox with `gap`
- Grids → CSS Grid with `grid-template-columns`
- Never use absolute positioning (unless overlay/modal)
- Never use floats

### Interactive States
- Figma hover/pressed/disabled variants → CSS `:hover`, `:active`, `[disabled]`
- Focus state: ALWAYS add `:focus-visible` with visible ring
- Transitions from design or default `var(--transition-fast)`

### Responsive
- Figma responsive variants → `@media` queries
- Mobile-first approach
- If Figma has mobile + desktop → derive tablet from spacing/layout interpolation

## Quality Checks

After generating components:
1. All CSS uses custom properties (no hardcoded values)
2. All components have proper `.component.yml` schema
3. BEM naming is consistent
4. Twig uses `attributes.addClass()` for root element
5. JS uses `Drupal.behaviors` + `once()`
6. WCAG 2.1 AA: color contrast 4.5:1, focus visible, aria attributes
7. Responsive: works at 375px, 768px, 1440px
