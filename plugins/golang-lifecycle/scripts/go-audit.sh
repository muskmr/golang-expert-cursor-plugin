#!/usr/bin/env bash
# One-shot health check for a Go module.
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
require_cmd gofmt

echo "== module =="
go list -m
echo
echo "== go version =="
go version
echo
echo "== gofmt =="
dirty="$(gofmt -l . || true)"
if [[ -n "$dirty" ]]; then
  echo "$dirty"
  fmt_status=1
else
  echo "clean"
  fmt_status=0
fi
echo
echo "== go vet =="
vet_status=0
go vet ./... || vet_status=$?
echo
echo "== go build =="
build_status=0
go build ./... || build_status=$?
echo
echo "== go test =="
test_status=0
go test ./... -count=1 || test_status=$?
echo
echo "== summary =="
echo "gofmt=$fmt_status vet=$vet_status build=$build_status test=$test_status"
exit $(( fmt_status || vet_status || build_status || test_status ))
