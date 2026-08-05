#!/usr/bin/env bash
# Guard dangerous shell commands in Go workspaces.
# Reads beforeShellExecution JSON from stdin; writes permission JSON to stdout.
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${HOOK_DIR}/../lib.sh"

input="$(cat || true)"
command="$(json_get "$input" command)"

if [[ -z "$command" ]]; then
  echo '{"permission":"allow"}'
  exit 0
fi

deny_patterns=(
  '(^|[[:space:]])rm[[:space:]]+-[a-zA-Z]*f'
  'git[[:space:]]+push[[:space:]]+[^|]*--force'
  'git[[:space:]]+reset[[:space:]]+--hard'
  'curl[[:space:]]+[^|]*\|[[:space:]]*(ba)?sh'
  'wget[[:space:]]+[^|]*\|[[:space:]]*(ba)?sh'
  'GOFLAGS=.*-toolexec'
)

for pat in "${deny_patterns[@]}"; do
  if [[ "$command" =~ $pat ]]; then
    agent_message="Blocked by golang-lifecycle shell guard: pattern '${pat}' matched. Re-run a safer equivalent or ask the user."
    user_message="Blocked potentially destructive command: ${command}"
    printf '{"permission":"deny","agent_message":%s,"user_message":%s}\n' \
      "$(json_string "$agent_message")" \
      "$(json_string "$user_message")"
    exit 0
  fi
done

# Ask before modules that rewrite go.mod broadly without an explicit version.
if [[ "$command" =~ go[[:space:]]+get[[:space:]]+-u([[:space:]]|$) ]] || [[ "$command" =~ go[[:space:]]+get[[:space:]]+\./\.\.\. ]]; then
  printf '{"permission":"ask","user_message":%s,"agent_message":%s}\n' \
    "$(json_string "Confirm broad dependency upgrade: ${command}")" \
    "$(json_string "Broad go get upgrades can introduce breaking or malicious changes. Prefer pinning versions after reading release notes.")"
  exit 0
fi

echo '{"permission":"allow"}'
