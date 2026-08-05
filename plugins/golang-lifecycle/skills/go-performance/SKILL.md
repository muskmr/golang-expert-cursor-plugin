---
name: go-performance
description: Profile and tune Go programs using pprof, execution traces, GC knobs, escape analysis and PGO. Use when investigating latency, CPU, memory or throughput problems.
---

# Go performance

Follow the order in the [GC guide](https://go.dev/doc/gc-guide) and
[diagnostics](https://go.dev/doc/diagnostics) docs — summarised by
`performance-triage.mmd`. **Do not turn knobs before a profile names the problem.**

## Collect

```bash
# tests
go test -run=^$ -bench=. -benchmem ./...
go test -run=^$ -bench=BenchmarkX -cpuprofile=cpu.out -memprofile=mem.out ./pkg

# running service (import _ "net/http/pprof" on an internal port)
curl -o cpu.out   'http://127.0.0.1:6060/debug/pprof/profile?seconds=30'
curl -o heap.out  'http://127.0.0.1:6060/debug/pprof/heap'
curl -o goroutine.out 'http://127.0.0.1:6060/debug/pprof/goroutine'

go tool pprof -http=: cpu.out
go tool trace trace.out
```

Enable block/mutex profiles in process with `runtime.SetBlockProfileRate` /
`runtime.SetMutexProfileFraction` before collecting them.

## Interpret (CPU profile first)

| Dominant frame | Next step |
| --- | --- |
| `runtime.gcBgMarkWorker` | Allocation / GC cost — take a heap profile |
| `runtime.mallocgc` ≳ 15% | Allocation heavy — heap profile + escape analysis |
| `runtime.gcAssistAlloc` ≳ 5% | Allocation outruns GC |
| Your code | Fix the algorithm; then consider PGO |
| Unclear / latency spikes | Execution trace, then `GODEBUG=gctrace=1` |

```bash
go build -gcflags=-m=3 ./...          # escape analysis
go tool pprof -sample_index=alloc_space heap.out
```

## Knobs (only after the profile)

| Setting | Guidance |
| --- | --- |
| `GOGC` | Doubling ≈ half GC CPU, double heap overhead |
| `GOMEMLIMIT` | Soft limit; leave 5–10% headroom under the container limit |
| `GOMAXPROCS` | Go 1.25+ defaults to cgroup CPU limit and updates live |
| PGO | Place production CPU profile as `default.pgo` beside `main` |

Death-spiral warning: a too-low `GOMEMLIMIT` with `GOGC=off` can thrash. Prefer
OOM over permanent GC thrashing; the runtime already softens the limit.

## PGO loop

See `pgo-workflow.mmd`. Expect roughly 2–14% on representative workloads
(Go 1.22+ measurements). Refresh profiles after large refactors; do not feed
microbenchmarks into PGO.
