---
name: go-code-review
description: Review Go changes for correctness, idioms, API compatibility, concurrency safety, errors and tests. Use when reviewing a PR, diff or refactor in a Go repository.
---

# Go code review

Review against Effective Go, the Go Doc Comments guide, the race detector docs,
and the module compatibility post. Prefer concrete findings with file:line and a
suggested fix.

## Priority order

1. **Correctness and data races** — wrong results, panics, races, leaked goroutines,
   cancelled contexts ignored, `rows` / `Body` not closed.
2. **API / compatibility breaks** — signature changes, removed exports, interface
   growth, non-comparable field added to a comparable struct, error types newly
   wrapped into the public contract.
3. **Error handling** — discarded errors, string-matched errors, `%w` exposing
   implementation details, missing origin prefixes, panics across package boundaries.
4. **Concurrency** — unbounded `go` per request, missing `WaitGroup`/`errgroup`,
   shared maps without sync, contexts stored in structs.
5. **Idioms and style** — `gofmt`, naming, doc comments, package focus, unnecessary
   generics or interfaces.
6. **Tests** — missing table cases, no `-race` coverage for concurrent code, no
   fuzz target for parsers, examples that do not compile.
7. **Security / supply chain** — injection via string-built SQL, unsafe, fixed
   versions of vulnerable deps, secrets in source.

## Commands to run before commenting

```bash
gofmt -l .
go vet ./...
go test ./... -count=1
go test -race ./...          # if concurrency touched
govulncheck ./...            # if go.mod or go.sum touched
```

## Comment style

- Lead with the defect and the impact, then the fix.
- Quote the canonical rule when it settles an argument (with the go.dev URL).
- Do not nitpick formatting that `gofmt` owns.
- Separate "must fix" from "consider".

## Related skills

`go-error-handling`, `go-concurrency`, `go-security`, `go-testing`, `go-modules`.
