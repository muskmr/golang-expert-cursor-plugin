# Golang Lifecycle Toolkit (Cursor plugin)

Marketplace-ready Cursor plugin for **Go (Golang)** solution work across the full
development lifecycle (DLC).

**Author:** [muskmr](https://github.com/muskmr) \<muskmr@gmail.com\>  
Built from the [Cursor plugin template](https://github.com/cursor/plugin-template)
and grounded in [go.dev](https://go.dev) / [golang/website](https://github.com/golang/website).

## Plugin

| Plugin | Path | Purpose |
| --- | --- | --- |
| **golang-lifecycle** | [`plugins/golang-lifecycle`](./plugins/golang-lifecycle) | Rules, skills, agents, commands, hooks, scripts, gopls MCP, Mermaid templates |

## Install locally (before Marketplace)

```bash
./scripts/install-local.sh
# Windows: powershell -File .\scripts\install-local.ps1
```

Then in Cursor: **Developer: Reload Window**.  
Guide: [`docs/install-local.md`](./docs/install-local.md)  
Uninstall: `./scripts/uninstall-local.sh`

The installer copies the plugin into `~/.cursor/plugins/local/golang-lifecycle`
and rewrites the logo to a `file://` URL so the icon loads in the local UI.

## Lifecycle coverage

- **Analyse** — layout, build/vet/test health, deps, vulnerabilities
- **Design** — canonical layouts, additive APIs, Mermaid architecture
- **Build & modernize** — toolchain, `go fix`, slog/context/errors
- **Test** — tables, fuzz, synctest, race, benchmarks
- **Secure** — govulncheck, injection, FIPS, threat model
- **Profile & operate** — pprof, traces, GC/`GOMEMLIMIT`, PGO, slog
- **Upgrade & release** — GODEBUG-aware bumps, semver / `/v2`, CI gates

## Security & marketplace readiness

- [`SECURITY.md`](./SECURITY.md) — reporting and trust boundaries
- [`docs/marketplace-security-checklist.md`](./docs/marketplace-security-checklist.md)
- Public MIT repo, no binaries, no secrets, hooks without network downloads

```bash
node scripts/validate-template.mjs
```

## Submit to Marketplace

1. Merge to the default branch
2. Enable GitHub private vulnerability reporting + secret scanning (see checklist)
3. Submit at [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish)
