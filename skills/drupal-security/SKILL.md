---
description: Drupal security audit and hardening. Use when user says "security review", "security audit", "check for vulnerabilities", "harden", "OWASP", "XSS", "SQL injection", "CSRF", "access control", or asks about Drupal security best practices.
user_invocable: true
---

# Drupal Security Audit

## OWASP Top 10 Applied to Drupal

### 1. Injection (SQL, OS Command)
- **Always** use Database API with placeholders:
  ```php
  $query = $this->database->select('users', 'u');
  $query->condition('name', $name); // Parameterized
  ```
- **Never** concatenate user input into queries
- **Never** use `exec()`, `system()`, `passthru()`, `shell_exec()`, `proc_open()`, `popen()`
- Use `\Drupal\Component\Utility\Html::escape()` for output

### 2. Broken Authentication
- Use Drupal's authentication system, don't build custom
- Session configuration in `services.yml`, not custom code
- Password hashing via `password` service
- Multi-factor: use contrib (TFA module)

### 3. Sensitive Data Exposure
- API keys: State API (`\Drupal::state()`) or Key module — **NEVER in config**
- Config is exportable to YAML files committed to git
- Passwords: never log, never display, never store in plain text
- Use HTTPS everywhere (enforce via `.htaccess` or web server config)

### 4. XML External Entities (XXE)
- Drupal core handles XML parsing safely
- If custom XML parsing: `libxml_disable_entity_loader(true)` (PHP < 8.0)
- Use `SimpleXMLElement` with `LIBXML_NOENT` flag disabled

### 5. Broken Access Control
- Every route MUST have access control:
  ```yaml
  requirements:
    _permission: 'administer content'
  ```
- Entity access: implement `EntityAccessControlHandler`
- Check access programmatically: `$entity->access('update', $account)`
- Menu links respect access automatically
- Custom access checkers: `_custom_access` in routing

### 6. Security Misconfiguration
- Remove `CHANGELOG.txt`, `README.txt` in production
- Disable `update` module in production
- `settings.php`: `$settings['trusted_host_patterns']`
- File permissions: directories 755, files 644
- Disable PHP execution in files directory

### 7. Cross-Site Scripting (XSS)
- Twig auto-escapes by default — this is your first defense
- `{{ variable }}` — auto-escaped
- `{{ variable|raw }}` — **DANGEROUS**, only for pre-sanitized HTML
- `#markup` auto-filters with `Xss::filterAdmin()`
- User input in `t()`: use `@variable` (escaped), `%variable` (emphasized + escaped)
- **Never** use `:variable` with user input in `t()` (no escaping)
- `Xss::filter($html, $allowed_tags)` for user HTML content
- `Html::escape($text)` for plain text output
- `UrlHelper::filterBadProtocol($url)` for URLs

### 8. Insecure Deserialization
- Drupal core handles form serialization safely
- Never `unserialize()` user input
- Use `json_decode()` instead of `unserialize()` for data exchange

### 9. Using Components with Known Vulnerabilities
- Keep Drupal core updated (`composer update drupal/core-*`)
- Monitor security advisories: `drush pm:security`
- Use `drupal-composer/drupal-security-advisories` in composer
- Audit contrib modules before use

### 10. Insufficient Logging
- Log security events: `$this->logger->warning('Access denied for @user', [...])`
- Use Drupal's `watchdog` (logger service)
- Monitor: failed logins, permission denials, suspicious patterns
- Never log sensitive data (passwords, tokens, PII)

## CSRF Protection

```yaml
# In routing.yml for state-changing routes:
my_module.action:
  path: '/my-module/action'
  defaults:
    _controller: '\Drupal\my_module\Controller\MyController::action'
  requirements:
    _permission: 'use my module'
    _csrf_token: 'TRUE'
  methods: [POST]
```

For AJAX routes, use `CsrfTokenGenerator`:
```php
$token = $this->csrfToken->get('my_module_action');
// Validate in controller:
if (!$this->csrfToken->validate($request->headers->get('X-CSRF-Token'), 'my_module_action')) {
  throw new AccessDeniedHttpException();
}
```

## File Upload Security

```php
$validators = [
  'FileExtension' => ['extensions' => 'jpg jpeg png gif'],
  'FileSizeLimit' => ['fileLimit' => 10 * 1024 * 1024], // 10MB
];
// Use managed file element:
$form['file'] = [
  '#type' => 'managed_file',
  '#upload_validators' => $validators,
  '#upload_location' => 'private://uploads/',
];
```

## Security Review Checklist

1. All routes have access requirements
2. No `\Drupal::service()` in classes (injection prevents testing gaps)
3. All user input sanitized before output
4. No secrets in config (exportable)
5. Database queries use placeholders
6. File uploads validated
7. CSRF tokens on POST/PUT/DELETE routes
8. External API responses validated
9. Error messages don't expose internal details to users
10. Logging captures security events without sensitive data
