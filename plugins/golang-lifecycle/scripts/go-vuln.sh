#!/usr/bin/env bash
# Run govulncheck, installing it on demand into a temp GOBIN if needed.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/scripts/lib.sh"

root="${1:-}"
json_out="${2:-}"
if [[ -z "$root" ]]; then
  root="$(find_workspace_go_root)" || {
    echo "no go.mod found" >&2
    exit 1
  }
fi
cd "$root"
require_cmd go

if ! command -v govulncheck >/dev/null 2>&1; then
  tmpgobin="$(mktemp -d)"
  trap 'rm -rf "$tmpgobin"' EXIT
  echo "installing govulncheck into $tmpgobin" >&2
  GOBIN="$tmpgobin" go install golang.org/x/vuln/cmd/govulncheck@latest
  export PATH="$tmpgobin:$PATH"
fi

if [[ -n "$json_out" ]]; then
  govulncheck -json ./... | tee "$json_out"
else
  govulncheck ./...
fi
