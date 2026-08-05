---
name: go-upgrade
description: Plan and execute Go toolchain and dependency upgrades safely, including GODEBUG compatibility, release-note review, race tests and govulncheck. Use when bumping the Go version or upgrading modules.
---

# Go upgrade

Follow the flow in `toolchain-upgrade-flow.mmd`. Ground truth:
[toolchain management](https://go.dev/doc/toolchain),
[GODEBUG / compatibility](https://go.dev/blog/compat),
[release notes](https://go.dev/doc/#release-notes),
[security best practices](https://go.dev/doc/security/best-practices).

## Toolchain upgrade

1. **Read every release note** from `current+1` through the target
   (`go1.24`, `go1.25`, `go1.26`, … on go.dev).
2. **Install the target toolchain without bumping `go.mod` yet.**
   With `GOTOOLCHAIN=auto`, `go get go@1.M.P` both downloads and records; to test
   first, run commands under `GOTOOLCHAIN=go1.M.P`.
3. **Build and test on the new toolchain with the old `go` line.**

```bash
GOTOOLCHAIN=go1.26.5 go build ./...
GOTOOLCHAIN=go1.26.5 go test ./... -count=1
GOTOOLCHAIN=go1.26.5 go test -race ./...
```

4. **Bump the language version** only after that is green:

```bash
go get go@1.26.5
```

5. **Review GODEBUG changes** whose default flips at the new language version
   ([history](https://go.dev/doc/godebug)). Opt out of a single behaviour with
   `//go:debug name=value` in package `main` if needed, then schedule removal.
6. **Modernize** with `go fix ./...` (Go 1.26+) and re-test.
7. **Re-scan** with `govulncheck ./...` and re-run benchmarks (`benchstat`).
8. Update CI `go-version`, container base images, and any `toolchain` line.

## Dependency upgrade

```bash
go list -m -u all
go get example.com/mod@vX.Y.Z     # one module at a time for risky upgrades
go get -u ./...                   # broad upgrade — review the full diff
go mod tidy
go test ./... -count=1
govulncheck ./...
```

Update carefully: new versions can introduce bugs or malicious code
([security best practices](https://go.dev/doc/security/best-practices)).
Prefer reviewing release notes and diffs for major/minor bumps.

## Recent changes worth planning for

| Version | Notable items |
| --- | --- |
| 1.24 | `tool` directives; `testing.B.Loop`; `os.Root`; FIPS 140-3 knobs; `runtime.AddCleanup` |
| 1.25 | container-aware `GOMAXPROCS`; `testing/synctest` GA; experimental `encoding/json/v2`; trace flight recorder |
| 1.26 | `go fix` modernizers; Green Tea GC default; experimental goroutine leak profile; `new(expr)` |
| 1.27 (draft) | generic methods; keep watching tip.golang.org |
