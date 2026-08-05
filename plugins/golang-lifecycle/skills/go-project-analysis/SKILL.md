---
name: go-project-analysis
description: Analyse an existing Go repository - layout, modules, packages, build health, tests, vulnerabilities and technical debt. Use when onboarding to a Go codebase, auditing it, or producing an architecture summary.
---

# Go project analysis

Produce a structured readout of a Go repository grounded in the canonical layout
and tooling from [go.dev](https://go.dev/doc/).

## Steps

1. **Locate the module roots.** Find every `go.mod` (and `go.work` if present).
   Record the `module`, `go` and optional `toolchain` / `tool` lines.
2. **Classify the layout** against [Organizing a Go module](https://go.dev/doc/modules/layout):
   basic package, basic command, package+`internal/`, multiple packages,
   `cmd/`+`internal/` server, or mixed. Call out directories that are *not* in that
   guide (`pkg/`, `api/`, …) as project conventions, not Go conventions.
3. **Map packages.** Run:

```bash
go list -f '{{.ImportPath}} {{.Name}} {{.Dir}}' ./...
go list -deps -f '{{.ImportPath}}' ./... | sort -u
```

4. **Build and vet health.**

```bash
go build ./...
go vet ./...
gofmt -l .
go test ./... -count=1
```

5. **Dependency and vulnerability posture.**

```bash
go list -m -u all
go mod graph
govulncheck ./...
```

6. **Concurrency and race risk.** Look for goroutines, shared maps, and missing
   contexts. Recommend `go test -race ./...` for any concurrent package.
7. **Diagram the shape.** Use `go-mermaid-diagrams` templates:
   - `layered-packages.mmd` for directory layout
   - `package-dependency-graph.mmd` for import cycles / upward deps
   - `module-dependency-graph.mmd` for MVS outcomes
   - `service-architecture.mmd` when there is a running service

## Report skeleton

```markdown
# <module> analysis
- Layout: <canonical type>
- Go version: <go line> (toolchain: <...>)
- Binaries: <cmd/...>
- Exported packages: <...>
- Internal packages: <...>
- Build: pass/fail
- Vet / fmt / tests: ...
- Vulnerabilities: reachable N / informational M
- Findings: ordered by impact
- Recommended next skills: go-upgrade / go-security / ...
```

## Tools in this plugin

- `scripts/go-audit.sh` — one-shot health check
- `scripts/go-deps.sh` — module graph and updateable deps
- `scripts/go-vuln.sh` — govulncheck wrapper
