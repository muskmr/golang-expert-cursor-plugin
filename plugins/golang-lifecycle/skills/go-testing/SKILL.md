---
name: go-testing
description: Design and implement Go tests - table-driven tests, subtests, fuzzing, benchmarks, synctest, race detection and coverage. Use when writing or improving tests in a Go project.
---

# Go testing

Canonical references: [code.html testing section](https://go.dev/doc/code),
[Using Subtests and Sub-benchmarks](https://go.dev/blog/subtests),
[Go Fuzzing](https://go.dev/security/fuzz),
[testing/synctest](https://pkg.go.dev/testing/synctest),
[race detector](https://go.dev/doc/articles/race_detector).

## Table-driven unit tests

```go
func TestAbs(t *testing.T) {
        tests := []struct {
                name string
                in   int
                want int
        }{
                {name: "positive", in: 2, want: 2},
                {name: "negative", in: -2, want: 2},
                {name: "zero", in: 0, want: 0},
        }
        for _, tt := range tests {
                t.Run(tt.name, func(t *testing.T) {
                        t.Parallel()
                        if got := Abs(tt.in); got != tt.want {
                                t.Fatalf("Abs(%d) = %d, want %d", tt.in, got, tt.want)
                        }
                })
        }
}
```

- Use `t.Helper()` in assertion helpers so failures point at the caller.
- Use `t.Cleanup` for teardown; prefer it over bare `defer` when the cleanup
  must run even if the test calls `t.Fatal`.
- Name subtests so `go test -run TestAbs/negative` selects one case.

## Fuzzing

```go
func FuzzParse(f *testing.F) {
        f.Add("ok")
        f.Fuzz(func(t *testing.T, in string) {
                _, err := Parse(in)
                if err != nil {
                        return // expected for many inputs; assert invariants instead
                }
        })
}
```

```bash
go test                          # seed corpus only
go test -fuzz=FuzzParse -fuzztime=30s
go test -run=FuzzParse/<hash>    # re-run a failing input from testdata/fuzz/
```

Failing inputs land in `testdata/fuzz/FuzzParse/` and must be committed.

## Benchmarks

Prefer `b.Loop()` (Go 1.24+) over `for i := 0; i < b.N; i++`:

```go
func BenchmarkSum(b *testing.B) {
        data := setup()
        b.ReportAllocs()
        for b.Loop() {
                Sum(data)
        }
}
```

Compare with `benchstat old.txt new.txt`. Microbenchmarks are poor PGO profiles.

## Concurrency tests

- Always run concurrent packages with `go test -race`.
- For time-dependent goroutine logic use `testing/synctest` (GA since Go 1.25):
  `synctest.Test` runs inside a bubble with a fake clock; `synctest.Wait` waits
  until every goroutine in the bubble is blocked.

## Coverage and strategy

```bash
go test -coverprofile=cover.out ./...
go tool cover -func=cover.out
go tool cover -html=cover.out
```

Use the `test-strategy.mmd` template to show which layer each test kind covers.
