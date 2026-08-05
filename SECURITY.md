# Security Policy

## Supported versions

| Version | Supported |
| --- | --- |
| 1.x | Yes |

## What this plugin is

`golang-lifecycle` is a Cursor plugin made mostly of Markdown (rules, skills, agents,
commands), Mermaid templates, and small shell/Node helper scripts. It ships **no
binaries** and does not embed secrets.

## Trust boundaries

| Component | What it can do | Risk notes |
| --- | --- | --- |
| Rules / skills / agents / commands | Inject prompt context into the Cursor agent | Review text before use; treat as untrusted third-party instructions |
| Hooks (`hooks/hooks.json`) | Run local shell scripts on edit / before shell / session end | Scripts are under `scripts/hooks/`; they do not download code |
| Helper scripts (`scripts/go-*.sh`) | Invoke local `go`, `gofmt`, optional `govulncheck` | `go-vuln.sh --install` may download `govulncheck` via `go install` — opt-in only |
| MCP (`mcp.json`) | Launch `gopls mcp` if `gopls` is on `PATH` | Subject to Cursor MCP allow/block lists; gopls may fetch modules from `proxy.golang.org` when analyzing code |

## Reporting a vulnerability

Please report security issues privately:

- Email: **muskmr@gmail.com**
- Also notify Cursor for marketplace impact: **security-reports@cursor.com**

Include the plugin version, a description of the issue, and steps to reproduce.
You should receive an acknowledgement within a few days.

Do **not** open a public GitHub issue for undisclosed vulnerabilities.

## Author commitment

As marketplace author I will investigate reports, publish fixes, and coordinate
with Cursor if a listed release needs to be pulled while a fix lands.
