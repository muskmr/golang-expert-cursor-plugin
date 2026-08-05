#!/usr/bin/env bash
# Run govulncheck. Network install is opt-in for marketplace safety.
#
# Usage:
#   ./scripts/go-vuln.sh [module-root] [json-out-file]
#   ./scripts/go-vuln.sh --install [module-root] [json-out-file]
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/scripts/lib.sh"

do_install=0
args=()
for a in "$@"; do
  if [[ "$a" == "--install" ]]; then
    do_install=1
  else
    args+=("$a")
  fi
done

root="${args[0]:-}"
json_out="${args[1]:-}"
if [[ -z "$root" ]]; then
  root="$(find_workspace_go_root)" || {
    echo "no go.mod found" >&2
    exit 1
  }
fi
cd "$root"
require_cmd go

if ! command -v govulncheck >/dev/null 2>&1; then
  if [[ "$do_install" -ne 1 ]]; then
    cat >&2 <<EOF
govulncheck not found on PATH.
Install it yourself, or re-run with --install (downloads via go install):

  go install golang.org/x/vuln/cmd/govulncheck@latest
  # or
  $0 --install ${root}
EOF
    exit 127
  fi
  tmpgobin="$(mktemp -d)"
  trap 'rm -rf "$tmpgobin"' EXIT
  echo "installing govulncheck into $tmpgobin (opt-in --install)" >&2
  GOBIN="$tmpgobin" go install golang.org/x/vuln/cmd/govulncheck@latest
  export PATH="$tmpgobin:$PATH"
fi

if [[ -n "$json_out" ]]; then
  govulncheck -json ./... | tee "$json_out"
else
  govulncheck ./...
fi
