#!/usr/bin/env bash
# Session-end audit: record whether the workspace still builds and is formatted.
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${HOOK_DIR}/../lib.sh"

root="$(find_workspace_go_root || true)"
if [[ -z "$root" ]]; then
  echo "[golang-lifecycle] no go.mod in workspace; audit skipped"
  exit 0
fi

echo "[golang-lifecycle] session audit in ${root}"
cd "$root"

if command -v gofmt >/dev/null 2>&1; then
  dirty="$(gofmt -l . 2>/dev/null || true)"
  if [[ -n "$dirty" ]]; then
    echo "[golang-lifecycle] gofmt dirty files:"
    echo "$dirty"
  else
    echo "[golang-lifecycle] gofmt clean"
  fi
fi

if command -v go >/dev/null 2>&1; then
  if go build ./... >/tmp/golang-lifecycle-audit-build.log 2>&1; then
    echo "[golang-lifecycle] go build ./... ok"
  else
    echo "[golang-lifecycle] go build ./... failed (see /tmp/golang-lifecycle-audit-build.log)"
  fi
fi

exit 0
