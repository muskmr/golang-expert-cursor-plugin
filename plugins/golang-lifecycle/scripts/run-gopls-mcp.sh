#!/usr/bin/env bash
# Locate gopls and exec: gopls mcp
# Cursor's GUI often has a minimal PATH that omits ~/go/bin, which causes
# `spawn gopls ENOENT`. This wrapper searches common install locations.
set -euo pipefail

log() { printf '[golang-lifecycle gopls-mcp] %s\n' "$*" >&2; }

find_gopls() {
  # Explicit override
  if [[ -n "${GOPLS_BIN:-}" && -x "${GOPLS_BIN}" ]]; then
    printf '%s\n' "${GOPLS_BIN}"
    return 0
  fi

  # PATH first (may already be fixed by mcp.json env)
  if command -v gopls >/dev/null 2>&1; then
    command -v gopls
    return 0
  fi

  local candidates=()
  local gobin gopath

  if command -v go >/dev/null 2>&1; then
    gobin="$(go env GOBIN 2>/dev/null || true)"
    gopath="$(go env GOPATH 2>/dev/null || true)"
    if [[ -n "$gobin" ]]; then
      candidates+=("${gobin}/gopls")
    fi
    if [[ -n "$gopath" ]]; then
      # GOPATH can be a list
      local IFS=':'
      # shellcheck disable=SC2206
      local paths=($gopath)
      for p in "${paths[@]}"; do
        candidates+=("${p}/bin/gopls")
      done
    fi
  fi

  candidates+=(
    "${HOME}/go/bin/gopls"
    "${HOME}/.local/bin/gopls"
    "/usr/local/go/bin/gopls"
    "/usr/local/bin/gopls"
    "/opt/homebrew/bin/gopls"
    "/opt/homebrew/opt/go/bin/gopls"
  )

  local c
  for c in "${candidates[@]}"; do
    if [[ -n "$c" && -x "$c" ]]; then
      printf '%s\n' "$c"
      return 0
    fi
  done

  return 1
}

install_hint() {
  cat >&2 <<'EOF'
gopls was not found. Cursor could not start the golang-lifecycle MCP server.

Install gopls (requires a Go toolchain), then reload Cursor:

  go install golang.org/x/tools/gopls@latest

Ensure the binary is on a path Cursor can see (GUI apps often miss shell PATH):

  # typical location:
  ~/go/bin/gopls

  # verify:
  ~/go/bin/gopls version
  ~/go/bin/gopls mcp -instructions >/dev/null && echo ok

Optional: set GOPLS_BIN to an absolute path before launching Cursor, or add
~/go/bin to your login PATH (macOS: ~/.zprofile) and restart Cursor fully.
EOF
}

main() {
  local bin
  if ! bin="$(find_gopls)"; then
    install_hint
    exit 127
  fi

  # Require a gopls new enough for `mcp` (v0.20+). Older builds error clearly.
  if ! "$bin" help mcp >/dev/null 2>&1; then
    log "found gopls at ${bin}, but it has no 'mcp' subcommand (need gopls >= 0.20)"
    log "upgrade: go install golang.org/x/tools/gopls@latest"
    exit 127
  fi

  log "using ${bin}"
  exec "$bin" mcp "$@"
}

main "$@"
