#!/usr/bin/env bash
# Format edited Go files after an agent/tab write.
# Hook input (JSON on stdin) includes file_path; we only act on *.go files.
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${HOOK_DIR}/../lib.sh"

input="$(cat || true)"
file_path="$(json_get "$input" file_path)"

if [[ -z "$file_path" || "$file_path" != *.go ]]; then
  exit 0
fi

if [[ ! -f "$file_path" ]]; then
  exit 0
fi

if command -v gofmt >/dev/null 2>&1; then
  gofmt -w "$file_path" || true
else
  echo "[golang-lifecycle] gofmt not on PATH; skipped" >&2
fi

exit 0
