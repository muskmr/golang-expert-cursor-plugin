#!/usr/bin/env bash
# Remove the locally installed golang-lifecycle Cursor plugin.
set -euo pipefail

PLUGIN_NAME="golang-lifecycle"
DEST_BASE="${CURSOR_PLUGINS_LOCAL:-${HOME}/.cursor/plugins/local}"
DEST="${DEST_BASE}/${PLUGIN_NAME}"

if [[ -L "${DEST}" || -d "${DEST}" || -e "${DEST}" ]]; then
  rm -rf "${DEST}"
  echo "removed ${DEST}"
else
  echo "nothing to remove at ${DEST}"
fi

echo "Reload Cursor (Developer: Reload Window) to drop the plugin from the UI."
