---
name: go-solution-design
description: Design Go services, libraries and package boundaries with backward-compatible APIs. Use when planning architecture, splitting packages, defining interfaces, or evolving a public API.
---

# Go solution design

Design for the layouts and compatibility rules the Go team documents:
[module layout](https://go.dev/doc/modules/layout),
[Keeping Your Modules Compatible](https://go.dev/blog/module-compatibility),
[When To Use Generics](https://go.dev/blog/when-generics).

## Package boundaries

1. Keep each package focused. Avoid `util`, `common`, `misc`, `helpers`, `types`, `api`.
2. Default new code to `internal/`. Export only what external callers need and you
   will support forever.
3. Dependencies point **downward** (`cmd` → adapters → domain → storage). Cycles
   and upward imports are defects — draw them with `package-dependency-graph.mmd`.
4. Declare interfaces in the **consuming** package, sized to the methods actually
   called. Prefer returning concrete types from constructors so methods can be
   added later without breaking implementers.
5. Accept interfaces / depend on small interfaces; do **not** treat
   "accept interfaces, return structs" as a law — Effective Go sometimes returns
   interfaces from constructors (`hash.Hash`). Match the call site.

## Extensible APIs ("add, don't change or remove")

| Change you want | Compatible move |
| --- | --- |
| Extra function argument | New function (`QueryContext` next to `Query`) or an options struct |
| Extra interface method | New interface + type assert; or unexported method if users must not implement |
| Extra struct field | Add a field whose **zero value preserves old behaviour** |
| Behaviour change | Opt-in method (`DisallowUnknownFields`) |
| Truly breaking change | New major version and module path (`/v2`) |

There is **no** backward-compatible change to a function signature — adding a
variadic parameter still breaks function-valued assignments.

## Concurrency and context in the design

- `context.Context` is the first parameter on any call path that blocks or crosses
  a process boundary. Never store it in a struct.
- Bound goroutine lifetime at design time: every spawned goroutine needs an exit
  (cancel, channel close, `WaitGroup`). Document it with `goroutine-pipeline.mmd`
  or `worker-pool.mmd`.
- Prefer channels for ownership transfer; prefer `sync` for protecting state.

## Generics

Write the concrete code first. Add type parameters only when you are about to
copy the same code for different types. If all you need is to call a method, use
an interface, not a type parameter.

## Deliverables

- Chosen layout + rationale
- Package diagram (`layered-packages.mmd` / `service-architecture.mmd`)
- Public API sketch with compatibility story (`api-evolution.mmd`)
- Failure and cancellation story (`error-flow.mmd`, `context-cancellation.mmd`)
- Test strategy outline (`test-strategy.mmd`)
