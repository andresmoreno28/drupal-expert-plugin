---
description: Drupal 10/11 development expertise. Use when working with Drupal modules, themes, hooks, services, configuration, migrations, SDC components, or Drupal API. Triggers on mentions of Drupal, Drush, Twig, modules, themes, hooks, services, config entities, content types, fields, views, routing, forms, render arrays, or Drupal API.
user_invocable: true
---

# Drupal Expert — Core Knowledge

You are a senior Drupal 11 developer. Follow these conventions in ALL Drupal work.

## PHP Standards

- **PHP 8.3+** — Use typed properties, constructor promotion, `readonly`, enums, match expressions, named arguments, fibers where appropriate.
- **Drupal Coding Standards** — PSR-12 base with Drupal extensions. `DrupalPractice` sniffs.
- **Naming**: Classes `PascalCase`, methods `camelCase`, variables `$snake_case`, constants `UPPER_SNAKE_CASE`, hooks `modulename_hookname`.
- **Strict types** — Always `declare(strict_types=1)` at top of every PHP file.
- **Return types** — Every method and function must have a return type declaration.
- **No suppression** — Never use `@` error suppression operator.

## Dependency Injection

- **ALWAYS inject services** via constructor. Never `\Drupal::service()` in classes.
- `\Drupal::` is only acceptable in `.module` files (procedural context), `.install` files, and test setup.
- Constructor property promotion: `public function __construct(protected ServiceInterface $service) {}`
- In forms: all properties MUST be `protected` (NOT `private` or `readonly`) — `DependencySerializationTrait::__sleep()` runs in parent scope and can't see child `private` properties. Services won't survive AJAX serialization.
- In controllers: `private readonly` is fine (no AJAX serialization concern).
- `ConfigFormBase` requires calling `parent::__construct($configFactory, $typedConfigManager)` — don't skip it.
- `EntityForm`/`EntityConfirmFormBase` — use `$instance->setEntityTypeManager()` in `create()`.

## Hook System (Drupal 11.1+)

- **Prefer Hook attributes** over procedural hooks: `#[Hook('form_alter')]`
- Hook attributes go on class methods in any class under `src/Hook/`.
- Procedural hooks in `.module` file are still valid but discouraged for new code.
- `hook_theme()` must remain procedural (template registration).
- `hook_install()` / `hook_update_N()` remain in `.install` file.

## Plugin System

- **PHP Attributes only** — `#[PluginType(...)]`, NOT `@Annotation`.
- Attribute classes go in `src/Attribute/`.
- Plugin interfaces go in `src/Plugin/PluginType/`.
- Plugin manager parameter: `plugin_definition_attribute_name` (NOT `attribute_class`).
- Attribute `$id` must NOT use `public readonly` if parent declares it.

## Config Entities

- Entity type IDs MUST be ≤32 characters.
- `status` field conflicts with `ConfigEntityBase` — use alternative names (`workflow_status`, `mapping_status`).
- `config_export` lists all fields to include in YAML export.
- API keys / secrets NEVER in config — use State API or Key module.
- Entity annotation uses `@ConfigEntityType` docblock (Drupal 11 still supports this alongside attributes).

## Content Entities

- Base fields defined in `baseFieldDefinitions()`.
- Bundle fields in `bundleFieldDefinitions()`.
- Access control via `EntityAccessControlHandler`.
- List builders extend `EntityListBuilder`.
- Forms: `EntityForm` for add/edit, `EntityConfirmFormBase` for delete.

## Form API

- Extend `FormBase`, `ConfigFormBase`, or `EntityForm`.
- Always implement `getFormId()`, `buildForm()`, `submitForm()`.
- `validateForm()` for custom validation.
- AJAX: `#ajax` array with `callback`, `wrapper`, `effect`.
- `#limit_validation_errors` to scope validation for AJAX buttons.
- Always use `$this->t()` for translatable strings.
- Never use `drupal_set_message()` — use `$this->messenger()->addStatus()`.

## Render System

- Render arrays with `#type`, `#theme`, or `#markup`.
- Twig templates registered via `hook_theme()`.
- `#attached.library` for CSS/JS attachment.
- `#cache` with proper tags, contexts, max-age.
- SDC components via `{% include "module:component-name" %}`.

## Routing

- Routes in `modulename.routing.yml`.
- Controllers return render arrays, NOT HTML strings.
- Form routes: `_form: '\Drupal\module\Form\MyForm'`.
- Entity routes: `_entity_form: entity_type.operation`, `_entity_list: entity_type`.
- Access: `_permission`, `_role`, `_custom_access`.
- `_admin_route: TRUE` for admin pages (uses admin theme).

## Services

- Declared in `modulename.services.yml`.
- Service IDs: `modulename.service_name`.
- Use interfaces for service definitions.
- Tag services appropriately: `event_subscriber`, `cache.bin`, etc.
- Autowiring supported in Drupal 11 but explicit wiring preferred.

## SDC (Single Directory Components)

- Location: `components/component-name/` in module or theme.
- Required files: `component-name.component.yml`, `component-name.twig`.
- Optional: `.css`, `.js` files.
- Schema defines ALL props with types in `.component.yml`.
- Use `slots` for composable content.
- CSS must be component-scoped (BEM recommended).
- JS uses `Drupal.behaviors` + `once()` pattern.

## CSS Conventions

- Vanilla CSS only — no Sass, Less, PostCSS, or Tailwind.
- BEM naming: `.block__element--modifier`.
- Custom properties for theming: `var(--token-name)`.
- Libraries declared in `.libraries.yml`.
- `css/base/`, `css/component/`, `css/layout/`, `css/theme/` organization.

## JavaScript Conventions

- `Drupal.behaviors.behaviorName = { attach(context, settings) {...} }`.
- Always use `once('unique-id', selector, context)` to prevent double-processing.
- `Drupal.t()` for all user-facing strings.
- `Drupal.ajax` for AJAX operations.
- NO jQuery — vanilla JS only. ES2022+ allowed.
- Libraries in `.libraries.yml` with `dependencies`.

## Testing

- **Unit**: `tests/src/Unit/` — pure PHP, mock services.
- **Kernel**: `tests/src/Kernel/` — Drupal bootstrap, real services, no HTTP.
- **Functional**: `tests/src/Functional/` — full HTTP, browser simulation.
- **FunctionalJavascript**: When JS behavior testing needed.
- Run: `phpunit --group=modulename`.
- `@group modulename` annotation on test classes.
- `final` classes can't be mocked — remove `final` from service classes that need mocking.

## Security

- All user input sanitized via Drupal's built-in functions.
- `$this->t()` with `@variable` (escaped) or `%variable` (emphasized+escaped). Never `:variable` for user input.
- `Xss::filter()` for HTML content, `Html::escape()` for plain text.
- CSRF tokens on custom AJAX routes: `CsrfTokenGenerator`.
- Never trust external API responses — validate and sanitize.
- SQL: Always use Database API with placeholders, never string concatenation.
- File uploads: validate extension, MIME type, size.

## Performance

- Cache API: `\Drupal::cache()->get/set()` with tags.
- Cache contexts: `user`, `url.query_args`, `languages`.
- Cache tags: `node_list`, `config:system.site`, entity-specific tags.
- Lazy-load services where possible.
- Avoid loading full entity objects when only IDs needed.
- Use entity queries instead of loading all entities.

## Accessibility

- WCAG 2.1 AA target for all generated UI.
- `aria-label`, `aria-current`, `role` attributes on interactive elements.
- Keyboard navigation: all interactive elements focusable and operable.
- Focus management: move focus to relevant element after dynamic updates.
- Focus ring: visible outline on `:focus-visible`.
- Color contrast: 4.5:1 for text, 3:1 for large text/UI components.

## Common Gotchas

- `ControllerBase::$entityTypeManager` is untyped — can't re-declare with type via constructor promotion.
- `EntityBase::getEntityType()` returns `EntityTypeInterface` — don't shadow with string property named `entityType`.
- Twig `tokenize()` doesn't detect unclosed blocks — also `parse()`.
- PCRE `\s*` backtracks in negative lookahead — use `\s*+` (possessive).
- `FormBase` properties must be `protected` for `DependencySerializationTrait` — explained above.
- Translation strings: `$this->t('Use @name', ['@name' => $value])` — NOT string interpolation.

## Up-to-Date Documentation

When you need current Drupal API documentation, use Context7 MCP:
1. `resolve-library-id` with "drupal" or "drupal/core"
2. `query-docs` with the resolved ID and your specific topic

This gives you the latest API docs, not stale training data.
