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
