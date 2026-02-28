---
description: Generate Drupal Recipes for automated site configuration. Use when user says "create a recipe", "generate a recipe", "automate config", "site scaffolding", "distribution alternative", or wants to package Drupal configuration as a reusable recipe.
user_invocable: true
---

# Drupal Recipe Generation

## What Are Recipes?

Recipes are a Drupal core feature (11.1+) that apply configuration, install modules, and set up site structure in a reproducible way. They replace install profiles for composable site building.

## Recipe Structure

```
recipes/my-recipe/
  recipe.yml          # Recipe manifest (required)
  config/
    actions/          # Config actions (modify existing config)
    install/          # Full config objects to import
  content/            # Default content (optional)
```

## recipe.yml Template

```yaml
name: 'My Recipe'
description: 'Sets up a blog section with content types, views, and permissions.'
type: 'Content type'

install:
  - node
  - views
  - taxonomy
  - path
  - pathauto

config:
  import:
    node: '*'
  actions:
    user.role.content_editor:
      grantPermissions:
        - 'create article content'
        - 'edit own article content'
        - 'delete own article content'
    system.site:
      simple_config_update:
        page.front: '/blog'

recipes:
  - core/recipes/standard
```

## Config Actions Reference

### grantPermissions
```yaml
user.role.authenticated:
  grantPermissions:
    - 'access content'
    - 'view own unpublished content'
```

### simple_config_update
```yaml
system.site:
  simple_config_update:
    name: 'My Site'
    slogan: 'Built with Recipes'
```

### createIfNotExists
```yaml
node.type.article:
  createIfNotExists:
    type: article
    name: 'Article'
    description: 'Blog articles.'
    new_revision: true
```

### setComponents (for entity form/view displays)
```yaml
core.entity_form_display.node.article.default:
  setComponents:
    field_tags:
      type: entity_reference_autocomplete
      weight: 5
      region: content
```

## Applying Recipes

```bash
# Via Drush
drush recipe recipes/my-recipe

# Via Composer (for contrib recipes)
composer require drupal/recipe-name
drush recipe vendor/drupal/recipe-name
```

## Recipe Best Practices

1. **Composable** — Break large recipes into small, focused ones. Chain with `recipes:` key.
2. **Idempotent** — Recipes can be applied multiple times safely. Use `createIfNotExists` not `create`.
3. **No install profiles** — Recipes replace the need for custom install profiles.
4. **Config actions over full config** — Prefer `config/actions/` to modify existing config. Use `config/install/` only for new config objects.
5. **Dependencies explicit** — List all required modules in `install:`.
6. **Test before deploy** — Apply to a clean site, verify all config is correct.

## Common Recipe Patterns

### Content Type Recipe
```yaml
name: 'Blog Content Type'
description: 'Creates Article content type with common fields.'
type: 'Content type'
install:
  - node
  - taxonomy
  - text
  - image
  - path
```

### Role & Permissions Recipe
```yaml
name: 'Editor Workflow'
description: 'Sets up editor role with content permissions.'
type: 'Workflow'
install:
  - content_moderation
config:
  actions:
    user.role.editor:
      createIfNotExists:
        id: editor
        label: 'Editor'
      grantPermissions:
        - 'use editorial transition create_new_draft'
        - 'view any unpublished content'
```

### Theme Configuration Recipe
```yaml
name: 'Theme Setup'
description: 'Installs and configures the site theme.'
type: 'Theme'
install:
  - my_custom_theme
config:
  actions:
    system.theme:
      simple_config_update:
        default: my_custom_theme
        admin: claro
```

## SDC Components in Recipes

Recipes can include SDC components by:
1. Installing the theme/module that contains the components
2. Configuring layout builder to use specific components
3. Setting up default content that references components

## Design-to-Recipe Workflow

1. Extract design tokens → generate `tokens.css` in theme
2. Map components → generate SDC component files
3. Create content types → recipe with field definitions
4. Configure displays → recipe with view/form display actions
5. Set permissions → recipe with role/permission actions
6. Apply: `drush recipe recipes/my-design-system`
