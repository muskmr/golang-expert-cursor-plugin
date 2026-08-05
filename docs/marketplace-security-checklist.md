# Marketplace security & compliance checklist

Pre-submission checklist for
[Cursor Marketplace security](https://cursor.com/help/security-and-privacy/marketplace-security)
and the
[submission checklist](https://cursor.com/docs/reference/plugins.md#submission-checklist).

## Repository requirements

- [x] Public GitHub repository (open source — required)
- [x] MIT `LICENSE`
- [x] `SECURITY.md` with contact and trust boundaries
- [x] Author `name` + `email` in `plugin.json` and `marketplace.json`
- [x] `homepage` / `repository` URLs set
- [x] No secrets, tokens, or credentials in the tree
- [x] No shipped binaries
- [x] `node scripts/validate-template.mjs` passes

## Plugin content review notes

| Area | Status | Notes for reviewers |
| --- | --- | --- |
| Markdown skills/rules | Safe | Prompt guidance only; grounded in go.dev |
| Hooks | Shell, local only | `gofmt` after Go edits; deny/ask guard for destructive shell; session-end `go build` audit. No network in hooks. |
| `scripts/go-vuln.sh` | Opt-in network | Downloads `govulncheck` **only** with `--install`. Default path requires a preinstalled binary. |
| `mcp.json` → `gopls` | Optional MCP | Runs `gopls mcp` from user `PATH`. Honours Cursor MCP allow/block lists. Documented in README. |
| Logo | Relative path | `assets/logo.svg` (+ PNG fallbacks for local install) |

## GitHub settings the author should enable

`gh` in this environment is read-only for settings. In the GitHub UI for
`muskmr/golang-expert-cursor-plugin`:

1. **Settings → Code security** — enable Dependabot alerts (even for a docs-heavy
   repo) and secret scanning.
2. **Settings → General → Features** — keep Issues on for maintenance.
3. **Settings → Code security → Private vulnerability reporting** — enable so
   reporters can use GitHub's private channel in addition to email.
4. Add topics: `cursor`, `cursor-plugin`, `golang`, `go`, `marketplace`.
5. Set description / website to the README summary and repo URL.

## Local test before submit

```bash
./scripts/install-local.sh
# Cursor → Developer: Reload Window
# Confirm plugin appears under Plugins / Customize, logo visible, /go-analyze works
./scripts/uninstall-local.sh   # optional cleanup
```

## Submit

1. Merge this branch to the default branch.
2. Open https://cursor.com/marketplace/publish
3. Paste the public repo URL and note that local install + validate-template were run.
