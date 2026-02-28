#!/usr/bin/env bash
# Drupal Twig Template Validation Hook
# Triggered after Write/Edit/MultiEdit on Twig files.
# Reads tool_input JSON from stdin and outputs validation instructions.

set -euo pipefail

# Read the tool input from stdin
INPUT=$(cat)

# Extract the file path from the tool input JSON
FILE_PATH=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    path = data.get('file_path', data.get('filePath', data.get('path', '')))
    print(path)
except:
    print('')
" 2>/dev/null || echo "")

# Only validate Twig files
case "$FILE_PATH" in
  *.twig|*.html.twig)
    ;;
  *)
    exit 0
    ;;
esac

# Skip vendor files
case "$FILE_PATH" in
  */vendor/*|*/node_modules/*)
    exit 0
    ;;
esac

# Output validation instructions as a prompt
cat << 'PROMPT'
[Drupal Twig Validation] After editing this Twig template, silently verify the following. Only report genuine issues — if the code is correct, say nothing:

1. No business logic in templates — only presentation (no complex calculations, DB queries, service calls)
2. Variables are documented in the file header comment block
3. `{{ variable }}` is used (auto-escaped) — `{{ variable|raw }}` only for pre-sanitized HTML from Drupal render system
4. `attributes.addClass()` is used on the root element for proper attribute handling
5. BEM class naming: `.block__element--modifier`
6. Translation: `{{ 'String'|t }}` for translatable text, NOT raw strings
7. No inline styles (`style="..."`) — use CSS classes instead
8. Accessibility: interactive elements have `aria-label` or visible text, images have `alt` attributes
9. SDC includes use `{% include "module:component-name" %}` syntax with `only` keyword
10. No hardcoded URLs — use `{{ path('route.name') }}` or `{{ url('route.name') }}`

Format issues as: [Twig] template.html.twig:line — Issue description. Fix: specific suggestion.
PROMPT
