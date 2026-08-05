#!/usr/bin/env bash
# Install golang-lifecycle into ~/.cursor/plugins/local for local Cursor use.
# Prefers a real copy (not an external symlink) so Cursor always loads assets/logo.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_SRC="${ROOT}/plugins/golang-lifecycle"
PLUGIN_NAME="golang-lifecycle"
DEST_BASE="${CURSOR_PLUGINS_LOCAL:-${HOME}/.cursor/plugins/local}"
DEST="${DEST_BASE}/${PLUGIN_NAME}"
MODE="copy" # copy | link

usage() {
  cat <<EOF
Usage: $(basename "$0") [--link] [--dest DIR]

Install the Golang Lifecycle Toolkit plugin into Cursor's local plugins folder.

  --link      Symlink ${PLUGIN_SRC} into the local plugins dir (fast iteration).
              Falls back to copy if the environment rejects external symlinks.
  --dest DIR  Override install root (default: ~/.cursor/plugins/local)
  -h, --help  Show this help

After install: Cursor → Command Palette → "Developer: Reload Window"
Then open Plugins / Customize and confirm "Golang Lifecycle Toolkit" with its logo.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --link) MODE="link"; shift ;;
    --dest)
      DEST_BASE="$2"
      DEST="${DEST_BASE}/${PLUGIN_NAME}"
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ ! -f "${PLUGIN_SRC}/.cursor-plugin/plugin.json" ]]; then
  echo "error: plugin manifest missing at ${PLUGIN_SRC}/.cursor-plugin/plugin.json" >&2
  exit 1
fi
if [[ ! -f "${PLUGIN_SRC}/assets/logo.svg" ]]; then
  echo "error: logo missing at ${PLUGIN_SRC}/assets/logo.svg" >&2
  exit 1
fi
if [[ ! -f "${PLUGIN_SRC}/assets/logo.png" ]]; then
  echo "error: logo.png missing (needed for reliable local UI loading)" >&2
  exit 1
fi

mkdir -p "${DEST_BASE}"

# Remove previous install (symlink or directory).
if [[ -L "${DEST}" || -d "${DEST}" || -f "${DEST}" ]]; then
  rm -rf "${DEST}"
fi

install_copy() {
  mkdir -p "${DEST}"
  # Portable recursive copy without relying on GNU cp -a flags alone.
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete \
      --exclude '.git/' \
      --exclude 'node_modules/' \
      "${PLUGIN_SRC}/" "${DEST}/"
  else
    cp -R "${PLUGIN_SRC}/." "${DEST}/"
  fi
}

install_link() {
  ln -s "${PLUGIN_SRC}" "${DEST}"
}

if [[ "${MODE}" == "link" ]]; then
  if install_link 2>/dev/null && [[ -L "${DEST}" ]]; then
    echo "symlinked ${PLUGIN_SRC} -> ${DEST}"
  else
    echo "symlink failed or unsupported; falling back to copy" >&2
    rm -rf "${DEST}"
    install_copy
    echo "copied plugin to ${DEST}"
  fi
else
  install_copy
  echo "copied plugin to ${DEST}"
fi

# Ensure executables keep their bits after copy on odd umasks.
chmod -R a+rX "${DEST}" 2>/dev/null || true
find "${DEST}/scripts" -type f \( -name '*.sh' -o -name '*.mjs' \) -exec chmod +x {} \; 2>/dev/null || true

# Rewrite logo to an absolute file:// URL so Cursor's local plugin UI can load it
# even when relative paths are resolved as GitHub raw URLs (marketplace path).
# Never rewrite when DEST is a symlink into the git checkout — that would dirty the repo.
MANIFEST="${DEST}/.cursor-plugin/plugin.json"
if [[ -L "${DEST}" ]]; then
  echo "note: symlink install keeps relative logo (assets/logo.svg)."
  echo "      For a guaranteed local logo, re-run without --link (copy mode)."
elif [[ -f "${MANIFEST}" ]] && command -v node >/dev/null 2>&1; then
  GLC_MANIFEST="${MANIFEST}" \
  GLC_LOGO_PNG="${DEST}/assets/logo.png" \
  node --input-type=module <<'EOF'
import { readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { pathToFileURL } from "node:url";

const manifestPath = process.env.GLC_MANIFEST;
const png = path.resolve(process.env.GLC_LOGO_PNG);
const j = JSON.parse(readFileSync(manifestPath, "utf8"));
j.logo = pathToFileURL(png).href;
j.homepage = j.homepage || "https://github.com/muskmr/golang-expert-cursor-plugin";
j.repository = j.repository || "https://github.com/muskmr/golang-expert-cursor-plugin";
j.author = { name: "muskmr", email: "muskmr@gmail.com" };
writeFileSync(manifestPath, JSON.stringify(j, null, 2) + "\n");
console.log("logo ->", j.logo);
EOF
else
  echo "warning: node not found; left relative logo path (marketplace-style)" >&2
fi

# Sanity checks
test -f "${DEST}/.cursor-plugin/plugin.json"
test -f "${DEST}/assets/logo.svg"
test -f "${DEST}/assets/logo.png"
test -d "${DEST}/skills"
test -d "${DEST}/rules"

cat <<EOF

Installed: ${DEST}

Next steps:
  1. In Cursor, run:  Developer: Reload Window
  2. Enable "Include third-party Plugins, Skills, and other configs" if prompted
  3. Open Plugins / Customize — you should see "Golang Lifecycle Toolkit" with the GO logo
  4. Try slash command: /go-analyze
  5. Optional: install gopls for MCP  →  go install golang.org/x/tools/gopls@latest

Uninstall later with:  ${ROOT}/scripts/uninstall-local.sh
EOF
