---
description: Create or modify Drupal custom modules. Use when user says "create a module", "add a service", "add a route", "create a form", "add a controller", "create a config entity", "add a plugin type", "create an event subscriber", or needs to scaffold or extend Drupal module functionality.
user_invocable: true
---

# Drupal Module Development

## Module Scaffolding Checklist

When creating a new module, generate these files in order:

1. `modulename.info.yml` — Module metadata
2. `modulename.module` — Hook implementations (if needed)
3. `modulename.services.yml` — Service definitions
4. `modulename.routing.yml` — Routes
5. `modulename.permissions.yml` — Permissions
6. `modulename.links.menu.yml` — Menu links
7. `modulename.links.task.yml` — Local tasks (tabs)
8. `modulename.links.action.yml` — Local actions
9. `src/` — PHP classes (controllers, forms, services, entities)
10. `config/install/` — Default configuration
11. `config/schema/` — Config schema
12. `templates/` — Twig templates
13. `tests/` — PHPUnit tests

## info.yml Template

```yaml
name: 'Module Name'
type: module
description: 'One-line description.'
package: Custom
core_version_requirement: ^10.3 || ^11
php: 8.3
dependencies:
  - drupal:system (>=10.3)
```

## Service Definition Pattern

```yaml
services:
  modulename.my_service:
    class: Drupal\modulename\Service\MyService
    arguments:
      - '@entity_type.manager'
      - '@logger.factory'
```

```php
<?php
declare(strict_types=1);
namespace Drupal\modulename\Service;

use Drupal\Core\Entity\EntityTypeManagerInterface;
use Psr\Log\LoggerInterface;

class MyService {
  public function __construct(
    protected EntityTypeManagerInterface $entityTypeManager,
    protected LoggerInterface $logger,
  ) {}
}
```

## Config Entity Pattern

```php
/**
 * @ConfigEntityType(
 *   id = "my_entity",
 *   label = @Translation("My Entity"),
 *   handlers = {
 *     "list_builder" = "Drupal\modulename\MyEntityListBuilder",
 *     "form" = {
 *       "add" = "Drupal\modulename\Form\MyEntityForm",
 *       "edit" = "Drupal\modulename\Form\MyEntityForm",
 *       "delete" = "Drupal\modulename\Form\MyEntityDeleteForm",
 *     },
 *   },
 *   config_prefix = "my_entity",
 *   admin_permission = "administer my module",
 *   entity_keys = {
 *     "id" = "id",
 *     "label" = "label",
 *   },
 *   links = {
 *     "collection" = "/admin/config/my-module/entities",
 *     "add-form" = "/admin/config/my-module/entities/add",
 *     "edit-form" = "/admin/config/my-module/entities/{my_entity}/edit",
 *     "delete-form" = "/admin/config/my-module/entities/{my_entity}/delete",
 *   },
 *   config_export = {
 *     "id",
 *     "label",
 *   },
 * )
 */
```

## Plugin Type Creation Pattern

1. Create attribute class in `src/Attribute/MyPlugin.php`
2. Create interface in `src/Plugin/MyPlugin/MyPluginInterface.php`
3. Create base class in `src/Plugin/MyPlugin/MyPluginBase.php`
4. Create manager in `src/Plugin/MyPlugin/MyPluginManager.php`
5. Register manager as service with `plugin_definition_attribute_name`

## Event Subscriber Pattern

```php
<?php
declare(strict_types=1);
namespace Drupal\modulename\EventSubscriber;

use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\RequestEvent;
use Symfony\Component\HttpKernel\KernelEvents;

class MySubscriber implements EventSubscriberInterface {
  public static function getSubscribedEvents(): array {
    return [KernelEvents::REQUEST => ['onRequest', 100]];
  }

  public function onRequest(RequestEvent $event): void {
    // Handle the event.
  }
}
```

## Route Patterns

```yaml
# Controller route
modulename.page:
  path: '/my-page'
  defaults:
    _controller: '\Drupal\modulename\Controller\MyController::page'
    _title: 'My Page'
  requirements:
    _permission: 'access content'

# Form route
modulename.settings:
  path: '/admin/config/modulename/settings'
  defaults:
    _form: '\Drupal\modulename\Form\SettingsForm'
    _title: 'Settings'
  requirements:
    _permission: 'administer modulename'
  options:
    _admin_route: TRUE

# Entity parameter
modulename.entity_view:
  path: '/my-entity/{my_entity}'
  defaults:
    _controller: '\Drupal\modulename\Controller\MyController::view'
  requirements:
    _permission: 'view my entity'
  options:
    parameters:
      my_entity:
        type: entity:my_entity
```

## Config Schema Pattern

```yaml
# config/schema/modulename.schema.yml
modulename.settings:
  type: config_object
  label: 'Module settings'
  mapping:
    option_one:
      type: string
      label: 'Option one'
    option_two:
      type: integer
      label: 'Option two'

modulename.my_entity.*:
  type: config_entity
  label: 'My Entity'
  mapping:
    id:
      type: string
      label: 'ID'
    label:
      type: label
      label: 'Label'
```

## Permissions Pattern

```yaml
# modulename.permissions.yml
administer modulename:
  title: 'Administer Module'
  description: 'Full administrative access.'
  restrict access: true

use modulename:
  title: 'Use Module'
  description: 'Access module features.'
```

## Pre-flight Checks

Before writing any module code:
1. Check if the functionality already exists in core or contrib
2. Check the Drupal API for the correct base classes and interfaces
3. Verify entity type ID is ≤32 characters
4. Verify service names follow `modulename.service_name` convention
5. Verify all dependencies are declared in `info.yml`
6. Use Context7 MCP to fetch current API docs if unsure about method signatures

## Advanced Module Patterns

### PrivateTempStore for Multi-Step Wizards

Use `\Drupal\Core\TempStore\PrivateTempStoreFactory` for multi-step forms/wizards. Inject `tempstore.private`, create store per module, store data keyed by a wizard ID. Clean up in final step with `->delete()`. Never store full entities — store IDs/values only.

### AJAX Strategy

- **Form AJAX callbacks**: Use `#ajax` on form elements. Callback returns part of the form or `AjaxResponse` with commands. Best for form-internal dynamic behavior.
- **Standalone AJAX routes**: Use for non-form AJAX (load content, API calls). Always add `_csrf_token: 'TRUE'` in route requirements. Return `JsonResponse` or `AjaxResponse`.
- Never mix both patterns in the same interaction.

### Library Architecture

Structure `modulename.libraries.yml` in layers:
- `base`: Reset/tokens CSS, loaded globally via `hook_page_attachments()`.
- `component-name`: Per-component CSS/JS, attached via `#attached` in render arrays.
- Declare `dependencies` between libraries (e.g., `- core/drupal`, `- core/once`).
- Use `header: true` only for critical CSS; everything else loads in footer by default.

### hook_theme() and Template Variables

```php
function modulename_theme(): array {
  return [
    'modulename_widget' => [
      'variables' => ['items' => [], 'title' => '', 'attributes' => NULL],
      'template' => 'modulename-widget',
    ],
  ];
}
```
- Template file: `templates/modulename-widget.html.twig`
- Every variable in `'variables'` array becomes a Twig variable.
- Use `template_preprocess_modulename_widget()` for computed variables.

### Full-Page Layout Override

1. Implement `hook_theme_suggestions_page_alter()` to add `page__my_custom` suggestion.
2. Create `templates/page--my-custom.html.twig` overriding the full page layout.
3. Use this for landing pages, dashboards, or special layouts that can't use standard regions.

### Error Handling for External APIs

```php
try {
  $response = $this->httpClient->request('GET', $url, ['timeout' => 10]);
  $data = Json::decode((string) $response->getBody());
} catch (GuzzleException $e) {
  $this->logger->error('API call failed: @message', ['@message' => $e->getMessage()]);
  return $this->fallbackResponse();
}
```
- Always set `timeout` (10s default, 30s max).
- Validate response structure before use.
- Provide fallback/cached response on failure.
- Log with context, never expose raw errors to users.

### Permission Design

```yaml
# Naming: "verb modulename noun"
administer modulename:
  title: 'Administer Module'
  restrict access: true  # Only for site-admin-level perms

manage modulename content:
  title: 'Manage Module Content'
  # No restrict access — for content editors

view modulename reports:
  title: 'View Module Reports'
```
- Tiers: `administer` (admin) → `manage` (editor) → `view`/`use` (user).
- `restrict access: true` only on admin-level permissions (hides from non-admin role config).

### Custom Events

```php
// src/Event/DataProcessedEvent.php
final class DataProcessedEvent extends Event {
  public const EVENT_NAME = 'modulename.data_processed';
  public function __construct(public readonly array $data) {}
}

// Dispatch:
$this->eventDispatcher->dispatch(new DataProcessedEvent($data), DataProcessedEvent::EVENT_NAME);

// Subscribe: tag service with `event_subscriber` in services.yml
```

### Drush Commands (Drupal 11.1+)

```php
// src/Drush/Commands/ModuleCommands.php
use Drush\Attributes as CLI;
use Drush\Commands\DrushCommands;

final class ModuleCommands extends DrushCommands {
  #[CLI\Command(name: 'modulename:sync')]
  #[CLI\Help(description: 'Sync external data.')]
  #[CLI\Option(name: 'force', description: 'Force full sync.')]
  public function sync(array $options = ['force' => false]): void {
    // Command logic
  }
}
```
- Use PHP attributes for command metadata (not annotations).
- Register in `drush.services.yml` with tag `drush.command`.

### Service Orchestrator Pattern

For modules with multiple tagged services (e.g., data processors):
```yaml
services:
  modulename.processor_manager:
    class: Drupal\modulename\Service\ProcessorManager
    arguments:
      - !tagged_iterator modulename.processor
```
- Tag individual processors: `tags: [{ name: modulename.processor, priority: 10 }]`.
- Manager iterates tagged services in priority order.

### Value Objects / DTOs

```php
final readonly class ApiResult {
  public function __construct(
    public string $id,
    public string $title,
    public \DateTimeImmutable $created,
  ) {}

  public static function fromApiResponse(array $data): self {
    return new self($data['id'], $data['title'], new \DateTimeImmutable($data['created']));
  }
}
```
- Use `final readonly` classes for data from external APIs or complex method returns.
- Static factory methods for creation from raw data.

### Deployment Orchestration

Structure deploy hooks in `modulename.deploy.php`:
- **Pre-deploy**: Schema changes, new fields (`hook_update_N()`).
- **During deploy**: Data migrations, config updates (`hook_deploy_NAME()`).
- **Post-deploy**: Cache clear, index rebuild.
- Gate: never deploy if `hook_requirements()` reports errors.

### Filesystem Safety

- Always use `\Drupal\Core\File\FileSystemInterface` for file operations.
- Write to `public://`, `private://`, or `temporary://` — never absolute paths.
- `.htaccess` protection is auto-generated for `private://` — don't remove.
- Create backups before destructive file operations.
- Validate uploaded file contents, not just extension.
