---
name: go-modules
description: Manage Go modules and dependencies - go.mod, MVS, tool directives, workspaces, private modules, tidy and versioning. Use when editing go.mod, adding/removing dependencies, or publishing a module.
---

# Go modules

Canonical sources: [Managing dependencies](https://go.dev/doc/modules/managing-dependencies),
[go.mod reference](https://go.dev/ref/mod),
[Module version numbering](https://go.dev/doc/modules/version-numbers),
[Toolchain management](https://go.dev/doc/toolchain).

## Everyday commands

```bash
go get example.com/mod@v1.2.3
go get example.com/mod@none          # remove
go get -u ./...                      # upgrade (review the diff)
go list -m -u all                    # available updates
go mod tidy
go mod verify
go mod graph
go mod why -m example.com/mod
```

## Tool dependencies (Go 1.24+)

```bash
go get -tool golang.org/x/tools/cmd/stringer
go tool stringer
go get tool                          # upgrade every tool
go install tool                      # install every tool to GOBIN
```

`tool` directives replace the old `tools.go` blank-import pattern.

## Versioning contract

- `v0.x.x` — unstable
- Patch / minor — backward compatible
- Major `v2+` — **new module path** (`module example.com/mod/v2`) and new import path
- Never hand-write pseudo-versions; let the `go` command generate them
- Prefer additive API changes over a major bump (`go-solution-design`, `api-evolution.mmd`)

## `go` and `toolchain` lines

- `go` line = minimum language version **and** GODEBUG compatibility defaults
- Change it with `go get go@1.N.P`, not by hand-editing
- `GOTOOLCHAIN=auto` (default) downloads a newer toolchain when required;
  `GOTOOLCHAIN=local` pins to the installed one
- Debug with `GODEBUG=toolchaintrace=1`

## Private modules

```bash
go env -w GOPRIVATE=github.com/myorg/*
# optionally GONOPROXY / GONOSUMDB if they should differ
```

## Workspaces

```bash
go work init ./services/api ./libs/money
go work use ./services/worker
```

Use workspaces for multi-module local development; do not commit `go.work` unless
the repository intentionally shares one.
