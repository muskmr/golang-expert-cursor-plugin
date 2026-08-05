#!/usr/bin/env bash
# Show module graph, why selected modules exist, and available updates.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/scripts/lib.sh"

root="${1:-}"
if [[ -z "$root" ]]; then
  root="$(find_workspace_go_root)" || {
    echo "no go.mod found" >&2
    exit 1
  }
fi
cd "$root"
require_cmd go

echo "== go list -m all =="
go list -m all
echo
echo "== available updates =="
go list -m -u all
echo
echo "== module graph (first 200 edges) =="
go mod graph | head -n 200
echo
if [[ -n "${2:-}" ]]; then
  echo "== go mod why -m $2 =="
  go mod why -m "$2" || true
fi
