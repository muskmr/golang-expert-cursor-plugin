---
name: go-observability
description: Instrument Go services with log/slog, OpenTelemetry-style traces/metrics, pprof endpoints and runtime diagnostics. Use when adding logging, metrics, tracing or production debugging hooks.
---

# Go observability

Canonical sources: [log/slog blog](https://go.dev/blog/slog),
[diagnostics](https://go.dev/doc/diagnostics),
[runtime/trace flight recorder (Go 1.25)](https://go.dev/doc/go1.25#trace),
plus the `observability-signals.mmd` template.

## Structured logging (`log/slog`)

```go
log := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))
log = log.With("service", "api-server", "env", env)
log.Info("request finished", "method", r.Method, "path", r.URL.Path, "status", status, "duration", d)
```

- Use key-value pairs; keep keys stable and low-cardinality for labels.
- Prefer `LogAttrs` / pre-allocated `slog.Attr` on hot paths.
- Log errors **once**, at the process boundary, with enough context to act.

## Metrics and traces

- Emit RED/USE metrics (rate, errors, duration; utilisation, saturation, errors)
  around every external boundary (HTTP, SQL, RPC, queue).
- Propagate `context.Context` so traces and cancellation travel together.
- Export via OTLP to a collector; keep instrumentation in `internal/platform`.

## Runtime diagnostics in production

| Signal | How |
| --- | --- |
| CPU / heap / goroutine profiles | `net/http/pprof` on an **internal** port only |
| Execution trace (short window) | `runtime/trace.FlightRecorder` (Go 1.25+) |
| GC / scheduler | `GODEBUG=gctrace=1`, `schedtrace=1000` (staging) |
| Memory stats | `runtime.ReadMemStats`, `runtime/metrics` |

Never expose `/debug/pprof` on the public listener. Document the port in
`deployment-topology.mmd`.

## Correlation

Put `trace_id` / `request_id` into slog attributes and response headers so logs,
traces and profiles join during an incident.
