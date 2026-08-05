---
name: go-error-handling
description: Apply idiomatic Go error handling - wrapping with %w, errors.Is/As, sentinels, typed errors, panic/recover boundaries and logging. Use when designing error types or fixing error handling.
---

# Go error handling

Canonical sources: [Error handling and Go](https://go.dev/blog/error-handling-and-go),
[Errors are values](https://go.dev/blog/errors-are-values),
[Working with Errors in Go 1.13](https://go.dev/blog/go1.13-errors),
[Defer, Panic, and Recover](https://go.dev/blog/defer-panic-and-recover).

## Decision tree

Use the `error-flow.mmd` template. In short:

| Situation | Action |
| --- | --- |
| Caller can handle it completely | Handle and return `nil` (log once, at the boundary) |
| Cause is part of your API | `fmt.Errorf("op: %w", err)` so callers can `errors.Is` / `errors.As` |
| Cause is an implementation detail | `fmt.Errorf("op: %v", err)` — do **not** use `%w` |
| Callers branch on one condition | Export `var ErrNotFound = errors.New("pkg: not found")` and wrap it |
| Callers need structured detail | Export a typed error and match with `errors.As` |

## Hard rules

- Never discard an error with `_` unless a comment explains why.
- Never match errors by string.
- Prefer `errors.Is` / `errors.As` over `==` once wrapping is in play.
- Error strings identify their origin (`"image: unknown format"`).
- Return `error`, not a concrete `*MyError`, from exported APIs (FAQ).
- `panic` only for impossible states; `recover` only inside a deferred function;
  package boundaries return errors, never panics.
- At process boundaries (HTTP, CLI, workers) log the error **once** with
  `log/slog` and translate to the external status.

## Wrap example

```go
var ErrNotFound = errors.New("order: not found")

func (s *Store) Get(ctx context.Context, id string) (Order, error) {
        o, err := s.db.QueryOrder(ctx, id)
        if errors.Is(err, sql.ErrNoRows) {
                // Hide sql.ErrNoRows; expose our sentinel.
                return Order{}, fmt.Errorf("%w: %s", ErrNotFound, id)
        }
        if err != nil {
                // Keep driver detail out of the API contract.
                return Order{}, fmt.Errorf("order get: %v", err)
        }
        return o, nil
}
```
