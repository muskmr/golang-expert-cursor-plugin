#!/usr/bin/env bash
# Apply gofmt + go vet across the module (manual or CI-friendly).
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/scripts/lib.sh"

root="${1:-}"
write=0
if [[ "${1:-}" == "-w" ]]; then
  write=1
  shift
  root="${1:-}"
fi
if [[ -z "$root" ]]; then
  root="$(find_workspace_go_root)" || {
    echo "no go.mod found" >&2
    exit 1
  }
fi
cd "$root"
require_cmd go
require_cmd gofmt

if [[ "$write" -eq 1 ]]; then
  gofmt -w .
else
  dirty="$(gofmt -l . || true)"
  if [[ -n "$dirty" ]]; then
    echo "$dirty"
    echo "re-run with -w to write" >&2
    exit 1
  fi
fi

go vet ./...
