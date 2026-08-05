# Golang Lifecycle Toolkit

Universal Cursor plugin for Go (Golang) solution work across the full development
lifecycle: analyse, design, implement, test, secure, profile, upgrade and release.

**Author:** muskmr \<muskmr@gmail.com\>  
**Repo:** https://github.com/muskmr/golang-expert-cursor-plugin

Guidance is grounded in the canonical docs that power [go.dev](https://go.dev)
([golang/website](https://github.com/golang/website)).

## Install

### Local (any machine)

From the repository root:

```bash
./scripts/install-local.sh          # macOS / Linux
# or
powershell -File .\scripts\install-local.ps1
```

Then **Developer: Reload Window** in Cursor. Full guide:
[docs/install-local.md](../../docs/install-local.md).

### Marketplace

Once listed, install from the Cursor Marketplace UI. Source remains this public
repository (open source, required by Cursor).

## What you get

| Component | Contents |
| --- | --- |
| **Rules** | Core conventions, project layout, toolchain commands, Mermaid house style |
| **Skills** | 16 skills covering analysis → modernization, plus validated Mermaid templates |
| **Agents** | Architect, reviewer, security auditor, performance engineer |
| **Commands** | `/go-analyze`, `/go-design`, `/go-review`, `/go-test`, `/go-secure`, `/go-profile`, `/go-upgrade`, `/go-diagram` |
| **Hooks** | `gofmt` after Go edits, shell guard, session-end build audit (local shell only; no downloads) |
| **Scripts** | `go-audit`, `go-deps`, `go-vuln`, `go-profile`, `go-vet-fmt`, `mermaid-lint` |
| **MCP** | Optional `gopls mcp` (requires `gopls` ≥ 0.20 on `PATH`) |

## Mermaid templates

Twenty-four parser-validated templates live in
`skills/go-mermaid-diagrams/assets/templates/`.

```bash
node scripts/mermaid-lint.mjs path/to/doc.md
```

## Security

See [SECURITY.md](../../SECURITY.md) and
[docs/marketplace-security-checklist.md](../../docs/marketplace-security-checklist.md).

- No secrets or binaries in the plugin
- Hooks do not download code
- `go-vuln.sh --install` is the only opt-in network helper
- MCP is limited by Cursor's allow/block lists

## Script entrypoints

Run from a Go module root (or pass the path):

```bash
./scripts/go-audit.sh
./scripts/go-deps.sh
./scripts/go-vuln.sh              # requires govulncheck on PATH
./scripts/go-vuln.sh --install    # opt-in download via go install
./scripts/go-profile.sh ./internal/order BenchmarkSort
./scripts/go-vet-fmt.sh -w
```
