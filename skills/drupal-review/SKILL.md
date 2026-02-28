---
description: Review Drupal code for quality, security, performance, and adherence to standards. Use when user says "review this code", "check this module", "audit", "code quality", "is this correct", or asks to validate Drupal code.
user_invocable: true
---

# Drupal Code Review

## Review Checklist

When reviewing Drupal code, check all of the following categories:

### 1. Architecture & Patterns
- [ ] Services injected via constructor (never `\Drupal::service()` in classes)
- [ ] Correct base class used (FormBase vs ConfigFormBase vs EntityForm)
- [ ] Plugin types use PHP Attributes (not Annotations)
- [ ] Config entities have proper handlers, links, and config_export
- [ ] Entity type IDs ≤32 characters
- [ ] No `status` field name (conflicts with ConfigEntityBase)
- [ ] No business logic in preprocess functions or templates

### 2. PHP Quality
- [ ] `declare(strict_types=1)` present
- [ ] All methods have return type declarations
- [ ] Typed properties with proper nullability
- [ ] No unused imports, variables, or dead code
- [ ] Match expressions preferred over switch (PHP 8.1+)
- [ ] Constructor property promotion used where appropriate
- [ ] Enums for fixed value sets

### 3. Security (OWASP + Drupal-specific)
- [ ] User input sanitized (`@variable` in `t()`, not string concatenation)
- [ ] No raw SQL — always Database API with placeholders
- [ ] CSRF protection on custom routes (`_csrf_token: 'TRUE'`)
- [ ] Access checks on all routes (`_permission`, `_role`, or `_custom_access`)
- [ ] File upload validation (extension, MIME, size)
- [ ] API keys not in exportable config (use State API or Key module)
- [ ] External API responses validated before use
- [ ] No `eval()`, `exec()`, `system()`, or `passthru()`
- [ ] Check for XSS: `Xss::filter()` on user HTML, `Html::escape()` on text
- [ ] No `#markup` with unsanitized user data

### 4. Form Safety
- [ ] Form properties `protected` (not `private`/`readonly`) if form has AJAX
- [ ] `#limit_validation_errors` on AJAX-only buttons
- [ ] CSRF token on standalone AJAX routes
- [ ] Config form calls `parent::__construct()` with config factory

### 5. Performance
- [ ] Cache metadata: tags, contexts, max-age on render arrays
- [ ] No `loadMultiple()` when entity query suffices
- [ ] No N+1 queries in loops
- [ ] Static caching for repeated lookups within a request
- [ ] Lazy service injection for heavy services

### 6. Accessibility
- [ ] `aria-label` on icon-only buttons
- [ ] `role` attributes on custom interactive elements
- [ ] Focus management after AJAX updates
- [ ] Color not used as sole indicator (use icons/text too)
- [ ] Form elements have labels (not just placeholders)

### 7. Testing
- [ ] Unit tests for services with business logic
- [ ] Kernel tests for entity operations and config
- [ ] Functional tests for forms and page rendering
- [ ] `@group modulename` on all test classes
- [ ] Mock external services, don't call real APIs in tests

### 8. CSS/JS
- [ ] No hardcoded colors, spacing, or fonts — custom properties only
- [ ] BEM naming convention
- [ ] `Drupal.behaviors` + `once()` pattern
- [ ] No jQuery (vanilla JS only)
- [ ] Libraries declared with proper dependencies
- [ ] No inline styles or scripts

## Severity Levels

- **Critical**: Security vulnerabilities, data loss risks, broken functionality
- **Important**: Pattern violations, performance issues, accessibility gaps
- **Minor**: Naming inconsistencies, missing docs, style issues

## Review Output Format

```
## [Severity] File:line — Issue Title

**Problem**: What's wrong and why it matters.
**Fix**: Specific code change needed.
```

## Common Anti-Patterns to Flag

1. `\Drupal::service()` in a class → inject via constructor
2. `drupal_set_message()` → `$this->messenger()->addStatus()`
3. `db_query()` → `\Drupal::database()->query()`
4. `l()` / `url()` → `Url::fromRoute()` / `Link::createFromRoute()`
5. `format_date()` → `$this->dateFormatter->format()`
6. Raw `$_GET`/`$_POST` → `$request->query->get()` / `$request->request->get()`
7. `file_get_contents()` for HTTP → `httpClient->request()`
8. `json_encode/decode` without error handling → consider `Json::encode/decode()`
