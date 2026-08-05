---
name: go-concurrency
description: Design and review Go concurrency - contexts, channels, worker pools, pipelines, race safety and graceful shutdown. Use when adding goroutines, fixing races, or designing parallel workflows.
---

# Go concurrency

Canonical sources: Effective Go concurrency sections,
[Share Memory By Communicating](https://go.dev/blog/codelab-share),
[Go Concurrency Patterns: Pipelines](https://go.dev/blog/pipelines),
[Go Concurrency Patterns: Context](https://go.dev/blog/context),
[race detector](https://go.dev/doc/articles/race_detector).

## Rules

1. **"Do not communicate by sharing memory; instead, share memory by communicating."**
2. Every goroutine has a defined exit path. If you cannot name it, it is a leak.
3. `context.Context` is the first parameter on blocking / I/O / outbound call paths.
   Derive with `WithCancel` / `WithTimeout` / `WithDeadline` and **always**
   `defer cancel()`. Never store a context in a struct field.
4. Bound parallelism. Prefer a fixed worker pool over `go` per item of unbounded input.
5. The goroutine that creates a channel is responsible for closing it, and it closes
   it exactly once. Receivers never close.
6. Maps are not safe for concurrent write. Guard with `sync.RWMutex` or redesign.
7. Run `go test -race` on every change that touches concurrency.
8. Since Go 1.22, loop variables are per-iteration; still capture explicitly when
   supporting older language versions (`tc := tc`).

## Patterns to draw

| Pattern | Template |
| --- | --- |
| Fan-out / fan-in pipeline | `goroutine-pipeline.mmd` |
| Fixed worker pool | `worker-pool.mmd` |
| Deadline / SIGTERM propagation | `context-cancellation.mmd` |
| Process shutdown | `graceful-shutdown.mmd` |

## Race detector

```bash
go test -race ./...
go build -race -o bin/svc ./cmd/api-server
GORACE="halt_on_error=1 log_path=/tmp/race.out" go test -race ./...
```

Overhead is roughly 2–20× CPU and 5–10× memory. Only finds races on executed paths.

## Leak triage (Go 1.26+)

Experimental `GOEXPERIMENT=goroutineleakprofile` exposes a `goroutineleak` pprof
profile and `/debug/pprof/goroutineleak` for permanently blocked goroutines.
