# Golang Lifecycle Toolkit (Cursor plugin)

Marketplace-ready Cursor plugin that turns Cursor into a universal instrument for
**Go (Golang)** solution work — for solution developers, application developers
and the full development lifecycle (DLC).

Built from the [Cursor plugin template](https://github.com/cursor/plugin-template)
and grounded in the canonical content that powers [go.dev](https://go.dev)
([golang/website](https://github.com/golang/website)).

## Plugin

| Plugin | Path | Purpose |
| --- | --- | --- |
| **golang-lifecycle** | [`plugins/golang-lifecycle`](./plugins/golang-lifecycle) | Rules, skills, agents, commands, hooks, scripts, gopls MCP, Mermaid templates |

See [`plugins/golang-lifecycle/README.md`](./plugins/golang-lifecycle/README.md)
for usage, slash commands and script entrypoints.

## Lifecycle coverage

- **Analyse** — layout classification, build/vet/test health, dependency and vulnerability posture
- **Design** — canonical `cmd/` + `internal/` layouts, additive API evolution, Mermaid architecture
- **Build & modernize** — toolchain commands, `go fix` modernizers, slog/context/errors migrations
- **Test** — table-driven tests, fuzzing, synctest, race detector, benchmarks
- **Secure** — govulncheck triage, injection prevention, FIPS knobs, threat-model awareness
- **Profile & operate** — pprof, traces, GC/`GOMEMLIMIT`, PGO, slog + OTLP signals
- **Upgrade & release** — GODEBUG-aware toolchain bumps, semver / `/v2` module paths, CI gates

## Mermaid templates

`plugins/golang-lifecycle/skills/go-mermaid-diagrams/assets/templates/` ships
24 templates rendered successfully with `@mermaid-js/mermaid-cli`, plus
`scripts/mermaid-lint.mjs` to keep new diagrams canonical.

## Validate

```bash
node scripts/validate-template.mjs
node plugins/golang-lifecycle/scripts/mermaid-lint.mjs plugins/golang-lifecycle/skills/go-mermaid-diagrams/assets/templates
```

## Submission

- Plugin manifest: `plugins/golang-lifecycle/.cursor-plugin/plugin.json`
- Marketplace manifest: `.cursor-plugin/marketplace.json`
- Submit at [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish)
