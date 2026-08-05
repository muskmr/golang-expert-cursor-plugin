---
name: go-modernization
description: Modernize Go codebases to current idioms with go fix, migrate off deprecated APIs, adopt slog, contexts, errors.Is/As, loops and tooling. Use when refreshing an older Go project.
---

# Go modernization

Use mechanical tools first, then finish the semantic migrations by hand.
Grounded in [Go 1.26 `go fix` modernizers](https://go.dev/doc/go1.26#go-command),
the slog / errors / loops release notes, and Effective Go.

## Mechanical pass

```bash
# Go 1.26+
go fix ./...

# Older toolchains
go run golang.org/x/tools/gopls/internal/analysis/modernize/cmd/modernize@latest ./...

gofmt -w .
go vet ./...
go test ./... -count=1
```

Review every hunk. Modernizers should not change behaviour; if they do, file an
issue and revert that hunk.

## Semantic migrations (checklist)

| From | To |
| --- | --- |
| `log.Printf` / ad-hoc logging | `log/slog` with a single handler at main |
| `err == ErrX` on wrapped errors | `errors.Is` / `errors.As` |
| `fmt.Errorf("...: %v", err)` when exposing cause | `%w` |
| `ioutil` | `io` / `os` |
| `interface{}` | `any` |
| `for i := 0; i < b.N; i++` | `for b.Loop()` (Go 1.24+) |
| `tools.go` blank imports | `go get -tool` / `tool` directives (Go 1.24+) |
| `runtime.SetFinalizer` | `runtime.AddCleanup` (Go 1.24+) |
| Unscoped filesystem access of user paths | `os.Root` (Go 1.24+) |
| Ad-hoc done channels in new code | `context.Context` |
| String-built SQL | `database/sql` placeholders |

## Language version

Bump with `go get go@1.N.P` after the suite is green on that toolchain
(`go-upgrade` skill). GODEBUG defaults follow the `go` line — treat the bump as
a behaviour change.

## Diagrams

Track progress with `toolchain-upgrade-flow.mmd` and show the target package
shape with `layered-packages.mmd`.
