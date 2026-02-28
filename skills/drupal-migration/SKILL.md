---
description: Drupal migration development. Use when user says "migrate", "migration", "D7 to D11", "D7 to D10", "Drupal 7 upgrade", "migrate content", "migrate users", "source plugin", "process plugin", "destination plugin", "migrate API", "migration YAML", "ETL", or needs to move data between Drupal versions or from external sources.
user_invocable: true
---

# Drupal Migration Development

## Overview

Drupal's Migrate API is a powerful ETL (Extract, Transform, Load) framework for moving data into Drupal from any source — older Drupal versions, external databases, CSV files, JSON APIs, XML feeds, etc.

## Key Modules

```yaml
# Core modules (always available)
- migrate           # Base migrate framework
- migrate_drupal    # D6/D7 → D10/D11 source plugins
- migrate_drupal_ui # UI for D6/D7 upgrades

# Contrib (install as needed)
- migrate_plus      # Extra source/process plugins, migration groups
- migrate_tools     # Drush commands (migrate:import, migrate:rollback, etc.)
- migrate_file      # File migration helpers
- migrate_source_csv # CSV source plugin
```

## Migration YAML Structure

```yaml
# config/install/migrate_plus.migration.my_migration.yml
id: my_migration
label: 'My Content Migration'
migration_group: my_group
migration_tags:
  - content

source:
  plugin: my_source_plugin
  # Source-specific config here

process:
  # Field mappings: destination_field: source_field
  title: title
  body/value: body
  body/format:
    plugin: default_value
    default_value: full_html
  field_tags:
    plugin: migration_lookup
    migration: my_tags_migration
    source: tag_ids
  uid:
    plugin: migration_lookup
    migration: my_users_migration
    source: author_id

destination:
  plugin: 'entity:node'
  default_bundle: article

migration_dependencies:
  required:
    - my_users_migration
    - my_tags_migration
```

## Source Plugins

### Database Source (D7)
```yaml
source:
  plugin: d7_node
  node_type: article
```

### SQL Source (external DB)
```yaml
source:
  plugin: url
  data_fetcher_plugin: http
  data_parser_plugin: json
  urls:
    - 'https://api.example.com/articles'
  item_selector: /data
  fields:
    - name: id
      label: 'Article ID'
      selector: /id
    - name: title
      label: 'Title'
      selector: /title
  ids:
    id:
      type: integer
```

### CSV Source
```yaml
source:
  plugin: csv
  path: /path/to/data.csv
  delimiter: ','
  enclosure: '"'
  header_offset: 0
  ids:
    - id
  fields:
    - name: id
      label: 'ID'
    - name: title
      label: 'Title'
```

### Custom Source Plugin
```php
<?php
declare(strict_types=1);
namespace Drupal\my_module\Plugin\migrate\source;

use Drupal\migrate\Plugin\migrate\source\SqlBase;
use Drupal\migrate\Row;

#[\Drupal\migrate\Attribute\MigrateSource(
  id: 'my_custom_source',
  source_module: 'my_module',
)]
class MyCustomSource extends SqlBase {

  public function query(): \Drupal\Core\Database\Query\SelectInterface {
    return $this->select('old_table', 't')
      ->fields('t', ['id', 'title', 'body', 'created']);
  }

  public function fields(): array {
    return [
      'id' => $this->t('Unique ID'),
      'title' => $this->t('Title'),
      'body' => $this->t('Body text'),
      'created' => $this->t('Created timestamp'),
    ];
  }

  public function getIds(): array {
    return [
      'id' => ['type' => 'integer'],
    ];
  }

  public function prepareRow(Row $row): bool {
    // Transform data before process plugins run.
    $created = $row->getSourceProperty('created');
    $row->setSourceProperty('created_date', date('Y-m-d', (int) $created));
    return parent::prepareRow($row);
  }

}
```

## Process Plugins

### Common Built-in Plugins

```yaml
process:
  # Direct copy
  title: source_title

  # Default value
  status:
    plugin: default_value
    default_value: 1

  # Static map (value translation)
  field_status:
    plugin: static_map
    source: old_status
    map:
      published: 1
      draft: 0

  # Migration lookup (entity references)
  uid:
    plugin: migration_lookup
    migration: users
    source: author_id

  # Concatenate
  full_name:
    plugin: concat
    source:
      - first_name
      - last_name
    delimiter: ' '

  # Substring
  summary:
    plugin: substr
    source: body
    start: 0
    length: 200

  # Callback (PHP function)
  mail:
    plugin: callback
    callable: mb_strtolower
    source: email

  # Multiple plugins chained
  body/value:
    - plugin: callback
      callable: strip_tags
      source: html_body
    - plugin: str_replace
      search: "\r\n"
      replace: "\n"

  # File import
  field_image/target_id:
    plugin: file_import
    source: image_url
    destination: 'public://images/'
    id_only: true

  # Format date
  created:
    plugin: format_date
    source: created_date
    from_format: 'Y-m-d H:i:s'
    to_format: 'U'

  # Get (extract array element)
  first_tag:
    plugin: get
    source: tags/0

  # Flatten (multi-value)
  field_tags:
    plugin: flatten
    source: nested_tags

  # Skip on empty
  field_optional:
    plugin: skip_on_empty
    method: process
    source: optional_value

  # Entity generate (create term if not exists)
  field_category:
    plugin: entity_generate
    source: category_name
    value_key: name
    bundle_key: vid
    bundle: categories
    entity_type: taxonomy_term
```

### Custom Process Plugin

```php
<?php
declare(strict_types=1);
namespace Drupal\my_module\Plugin\migrate\process;

use Drupal\migrate\MigrateExecutableInterface;
use Drupal\migrate\ProcessPluginBase;
use Drupal\migrate\Row;

#[\Drupal\migrate\Attribute\MigrateProcess(
  id: 'my_custom_process',
)]
class MyCustomProcess extends ProcessPluginBase {

  public function transform(mixed $value, MigrateExecutableInterface $migrate_executable, Row $row, string $destination_property): mixed {
    if (empty($value)) {
      return NULL;
    }
    // Custom transformation logic.
    return strtolower(trim((string) $value));
  }

}
```

## Drush Commands (migrate_tools)

```bash
# List all migrations
drush migrate:status

# Run a migration
drush migrate:import my_migration

# Run with limit
drush migrate:import my_migration --limit=100

# Run with update (re-process existing)
drush migrate:import my_migration --update

# Rollback
drush migrate:rollback my_migration

# Reset stuck migration
drush migrate:reset-status my_migration

# Run all in a group
drush migrate:import --group=my_group

# Run with dependencies
drush migrate:import my_migration --execute-dependencies
```

## D7 → D11 Migration Checklist

1. **Audit D7 site**: content types, fields, users, taxonomies, files, menus
2. **Install core migrate modules**: `migrate`, `migrate_drupal`, `migrate_drupal_ui`
3. **Install contrib**: `migrate_plus`, `migrate_tools`, `migrate_file`
4. **Configure D7 database** in `settings.php`:
   ```php
   $databases['migrate']['default'] = [
     'driver' => 'mysql',
     'database' => 'drupal7_db',
     'username' => 'root',
     'password' => 'password',
     'host' => 'localhost',
   ];
   ```
5. **Run audit**: `drush migrate:upgrade --legacy-db-key=migrate --configure-only`
6. **Review generated migrations**: `drush migrate:status`
7. **Customize YAMLs** for field mapping adjustments
8. **Run in order**: config → users → taxonomy → files → nodes → menus
9. **Verify**: Check content, references, files, URLs
10. **Cleanup**: Remove migrate modules from production

## Best Practices

- **Always run migrations in the correct dependency order** — users before nodes, terms before nodes
- **Use `--limit` for testing** — don't import 100k records on first try
- **Rollback before re-running** — or use `--update` flag
- **Custom source plugins for complex transforms** — `prepareRow()` is your friend
- **Log everything** — use `$this->messenger()` in source plugins for debugging
- **Idempotent**: Migrations track what's been imported via map tables — re-running is safe
- **Test on a copy** — never run migrations directly on production
- **Handle files separately** — file migrations are slow, run them in batches
