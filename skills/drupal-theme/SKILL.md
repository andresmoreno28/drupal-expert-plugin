---
description: Drupal theme and SDC component development. Use when user says "create a theme", "create a component", "SDC component", "Twig template", "create a template", "theme hook", "preprocess", "CSS for Drupal", "JS behavior", or works with Drupal theming, templates, or frontend.
user_invocable: true
---

# Drupal Theme & SDC Component Development

## SDC Component Structure

Every component lives in `components/component-name/`:

```
components/
  my-component/
    my-component.component.yml   # Schema (required)
    my-component.twig            # Template (required)
    my-component.css             # Styles (optional)
    my-component.js              # Behavior (optional)
```

## component.yml Schema

```yaml
name: My Component
status: stable
description: Brief description of the component.
props:
  type: object
  properties:
    title:
      type: string
      title: Title
      description: The component title.
    variant:
      type: string
      title: Variant
      enum:
        - default
        - highlighted
    items:
      type: array
      title: Items
      items:
        type: object
        properties:
          label:
            type: string
          url:
            type: string
  required:
    - title
slots:
  content:
    title: Content
    description: Main content area.
libraryOverrides:
  css:
    component:
      my-component.css: {}
  js:
    my-component.js: {}
  dependencies:
    - core/once
```

## Twig Template Pattern

```twig
{#
/**
 * @file
 * My Component template.
 *
 * Available variables:
 * - title: The title text.
 * - variant: The visual variant.
 * - items: Array of item objects.
 * - content: Slot content.
 * - attributes: HTML attributes.
 */
#}
{%- set classes = [
  'my-component',
  variant ? 'my-component--' ~ variant : '',
] -%}
<div{{ attributes.addClass(classes) }}>
  <h3 class="my-component__title">{{ title }}</h3>
  {% if items %}
    <ul class="my-component__list">
      {% for item in items %}
        <li class="my-component__item">
          <a href="{{ item.url }}">{{ item.label }}</a>
        </li>
      {% endfor %}
    </ul>
  {% endif %}
  {% if content %}
    <div class="my-component__content">
      {{ content }}
    </div>
  {% endif %}
</div>
```

## CSS Pattern (BEM + Custom Properties)

```css
/**
 * @file
 * My Component styles.
 */

.my-component {
  padding: var(--space-4, 1rem);
  border: 1px solid var(--color-border, #ccc);
  border-radius: var(--radius, 0.5rem);
  background-color: var(--color-surface, #fff);
}

.my-component__title {
  font-size: var(--font-size-lg, 1.25rem);
  font-weight: var(--font-weight-bold, 700);
  margin-bottom: var(--space-2, 0.5rem);
}

.my-component--highlighted {
  border-color: var(--color-primary, #0057b8);
  background-color: var(--color-primary-light, #e6f0ff);
}
```

## JavaScript Behavior Pattern

```js
/**
 * @file
 * My Component behavior.
 */
(function (Drupal, once) {
  'use strict';

  Drupal.behaviors.myComponent = {
    attach: function (context) {
      var elements = once('my-component', '.my-component', context);

      elements.forEach(function (element) {
        // Initialize component.
        element.addEventListener('click', function (event) {
          // Handle click.
        });
      });
    },

    detach: function (context, settings, trigger) {
      if (trigger === 'unload') {
        // Cleanup.
      }
    },
  };

})(Drupal, once);
```

## Using SDC in Templates

```twig
{# Include with named props #}
{% include "module_or_theme:component-name" with {
  title: 'Hello',
  variant: 'highlighted',
} only %}

{# Include with slot content #}
{% embed "module_or_theme:component-name" with { title: 'Card' } %}
  {% block content %}
    <p>Slot content here.</p>
  {% endblock %}
{% endembed %}
```

## Theme Hook Registration

```php
function modulename_theme(): array {
  return [
    'my_template' => [
      'variables' => [
        'title' => NULL,
        'items' => [],
      ],
      'template' => 'my-template',
    ],
  ];
}
```

## Preprocess Functions

```php
function modulename_preprocess_my_template(array &$variables): void {
  // Data preparation ONLY — no business logic.
  $variables['formatted_date'] = \Drupal::service('date.formatter')
    ->format($variables['timestamp'], 'short');
}
```

## Libraries (.libraries.yml)

```yaml
my_library:
  css:
    component:
      css/my-component.css: {}
  js:
    js/my-component.js: {}
  dependencies:
    - core/drupal
    - core/once
```

## Theme Scaffolding Checklist

1. `themename.info.yml` — Theme metadata with `base theme: starterkit_theme` or `claro`
2. `themename.libraries.yml` — Asset libraries
3. `themename.theme` — Preprocess functions
4. `templates/` — Template overrides
5. `components/` — SDC components
6. `css/` — Global stylesheets
7. `js/` — Global scripts

## Design Token Strategy

For projects with design systems:
1. Define all tokens as CSS custom properties in a `tokens.css` file
2. Every component CSS uses ONLY custom properties — no hardcoded values
3. Map to design tool tokens (Figma variables, etc.)
4. Provide fallback values: `var(--token, fallback)`

## Responsive Patterns

- Mobile-first: start with mobile styles, add `@media (min-width: ...)` for larger
- Use CSS Grid and Flexbox — no floats
- Common breakpoints: 768px (tablet), 1024px (desktop), 1440px (wide)
- Container queries supported in modern Drupal themes
