# Golang Lifecycle Toolkit

Universal Cursor plugin for Go (Golang) solution work across the full development
lifecycle: analyse, design, implement, test, secure, profile, upgrade and release.

Guidance is grounded in the canonical docs that power [go.dev](https://go.dev)
([golang/website](https://github.com/golang/website)) — Effective Go, module
layout, toolchain management, diagnostics, GC guide, PGO, govulncheck, fuzzing,
database/sql, slog, and the compatibility / release blogs.

## What you get

| Component | Contents |
| --- | --- |
| **Rules** | Core conventions, project layout, toolchain commands, Mermaid house style |
| **Skills** | 16 skills covering analysis → modernization, plus validated Mermaid templates |
| **Agents** | Architect, reviewer, security auditor, performance engineer |
| **Commands** | `/go-analyze`, `/go-design`, `/go-review`, `/go-test`, `/go-secure`, `/go-profile`, `/go-upgrade`, `/go-diagram` |
| **Hooks** | `gofmt` after Go edits, shell guard, session-end build audit |
| **Scripts** | `go-audit`, `go-deps`, `go-vuln`, `go-profile`, `go-vet-fmt`, `mermaid-lint` |
| **MCP** | Optional `gopls mcp` server (requires `gopls` ≥ 0.20 on `PATH`) |

## Mermaid templates

Twenty-four parser-validated templates live in
`skills/go-mermaid-diagrams/assets/templates/`, covering service architecture,
package/module graphs, request & cancellation sequences, worker pools, error
flow, ERDs, state machines, CI, releases, upgrades, vulnerability triage,
performance triage, PGO, test strategy, migration and observability.

Lint diagrams with:

```bash
node scripts/mermaid-lint.mjs path/to/doc.md
node scripts/mermaid-lint.mjs --deep path/to/doc.md   # if mmdc is installed
```

## Quick start

1. Install the plugin from the Cursor Marketplace (or symlink into
   `~/.cursor/plugins/local/golang-lifecycle`).
2. Open a Go module in Cursor.
3. Use a slash command (`/go-analyze`) or ask naturally — skills attach by description.
4. Optional: ensure `gopls` is on your `PATH` so the bundled MCP server starts
   (`go install golang.org/x/tools/gopls@latest`). Load model instructions with
   `gopls mcp -instructions` if you want gopls' own workflow text in context.

## Script entrypoints

Run from a Go module root (or pass the path):

```bash
./scripts/go-audit.sh
./scripts/go-deps.sh
./scripts/go-vuln.sh
./scripts/go-profile.sh ./internal/order BenchmarkSort
./scripts/go-vet-fmt.sh -w
```

## Design principles

- Prefer commands and layouts that exist on go.dev; call out folklore when it is
  not in the canonical docs.
- Default new code to `internal/`; treat major version bumps as a last resort.
- Measure before tuning; wrap errors only when they are part of the API.
- Diagrams start from templates so Mermaid syntax stays valid.
