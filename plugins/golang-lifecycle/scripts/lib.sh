#!/usr/bin/env bash
# Shared helpers for golang-lifecycle scripts.
# shellcheck shell=bash

json_get() {
  # json_get <json> <key> — minimal extractor for flat string fields.
  local json="${1:-}"
  local key="${2:-}"
  if command -v node >/dev/null 2>&1; then
    node -e 'const fs=require("fs"); const j=JSON.parse(fs.readFileSync(0,"utf8")||"{}"); const v=j[process.argv[1]]; process.stdout.write(v==null?"":String(v));' "$key" <<<"$json" 2>/dev/null || true
    return 0
  fi
  # Fallback: naive sed for "key":"value"
  printf '%s' "$json" | sed -n "s/.*\"${key}\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" | head -n1
}

json_string() {
  local s="${1:-}"
  if command -v node >/dev/null 2>&1; then
    node -e 'process.stdout.write(JSON.stringify(process.argv[1]))' "$s"
    return 0
  fi
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  printf '"%s"' "$s"
}

find_go_mod() {
  local dir="${1:-.}"
  dir="$(cd "$dir" 2>/dev/null && pwd || echo "$dir")"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/go.mod" ]]; then
      printf '%s\n' "$dir/go.mod"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

find_workspace_go_root() {
  local start="${PWD:-.}"
  if [[ -n "${CURSOR_PROJECT_DIR:-}" && -d "${CURSOR_PROJECT_DIR}" ]]; then
    start="$CURSOR_PROJECT_DIR"
  fi
  local mod
  if mod="$(find_go_mod "$start")"; then
    dirname "$mod"
    return 0
  fi
  # Search a couple of levels for the first go.mod
  local found
  found="$(find "$start" -maxdepth 3 -type f -name go.mod 2>/dev/null | head -n1 || true)"
  if [[ -n "$found" ]]; then
    dirname "$found"
    return 0
  fi
  return 1
}

require_cmd() {
  local c="$1"
  if ! command -v "$c" >/dev/null 2>&1; then
    echo "missing required command: $c" >&2
    return 1
  fi
}
