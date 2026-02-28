#!/usr/bin/env bash
# Drupal Code Validation Hook
# Triggered after Write/Edit/MultiEdit on PHP files.
# Reads tool_input JSON from stdin and outputs validation instructions.

set -euo pipefail

# Read the tool input from stdin
INPUT=$(cat)

# Extract the file path from the tool input JSON
FILE_PATH=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    # Handle different tool input formats
    path = data.get('file_path', data.get('filePath', data.get('path', '')))
    print(path)
except:
    print('')
" 2>/dev/null || echo "")

# Only validate PHP-related files
case "$FILE_PATH" in
  *.php|*.module|*.install|*.theme)
    ;;
  *)
    # Not a PHP file, skip validation
    exit 0
    ;;
esac

# Skip test files
case "$FILE_PATH" in
  */tests/*|*/test/*)
    exit 0
    ;;
esac

# Skip vendor files
case "$FILE_PATH" in
  */vendor/*)
    exit 0
    ;;
esac

# Output validation instructions as a prompt
cat << 'PROMPT'
[Drupal Validation] After editing this PHP file, silently verify the following. Only report genuine issues — if the code is correct, say nothing:

1. `declare(strict_types=1)` is present at top of file
2. No `\Drupal::service()` inside classes under `src/` (only allowed in .module, .install, .theme files)
3. If extending FormBase or any form class, service properties are `protected` (not `private` or `readonly`)
4. All methods have return type declarations
5. User-facing strings use `$this->t()` or `t()`, not raw strings
6. No `eval()`, `exec()`, `system()`, `passthru()`, or `shell_exec()`
7. No raw SQL string concatenation

Format issues as: [Drupal] file.php:line — Issue description. Fix: specific suggestion.
PROMPT
