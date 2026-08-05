---
name: go-mermaid-diagrams
description: Produce correct Mermaid diagrams for Go systems using validated templates. Use when drawing architecture, package layouts, request flows, concurrency, state machines, ERDs, CI/CD, upgrades, vulnerability triage, performance triage, or API evolution diagrams.
---

# Go Mermaid diagrams

Start from a checked template. Every file under `assets/templates/` has been rendered
successfully with `@mermaid-js/mermaid-cli`, so copying one is the cheapest way to avoid
a diagram that shows up as an error box.

## Workflow

1. Pick the diagram that matches the job from the table below.
2. Copy the template into the Markdown doc as a ```` ```mermaid ```` fence (or keep it as `.mmd`).
3. Replace the placeholder names with the real packages, types, binaries and services.
4. Keep the structural rules listed in the `go-diagram-conventions` rule.
5. Lint with:

```bash
node scripts/mermaid-lint.mjs path/to/doc.md
```

Add `--deep` when `@mermaid-js/mermaid-cli` is installed to run the real Mermaid parser.

## Template catalogue

| Template | Diagram type | Use when |
| --- | --- | --- |
| `service-architecture.mmd` | flowchart TD | One Go service in its runtime context |
| `layered-packages.mmd` | flowchart TD | `cmd/` + `internal/` dependency direction |
| `package-dependency-graph.mmd` | flowchart LR | Import graph / cycle findings |
| `module-dependency-graph.mmd` | flowchart LR | `go mod graph` and MVS outcomes |
| `request-lifecycle.mmd` | sequenceDiagram | One HTTP request including timeout paths |
| `goroutine-pipeline.mmd` | flowchart LR | Fan-out / fan-in channel pipelines |
| `worker-pool.mmd` | sequenceDiagram | Bounded worker pools and shutdown |
| `context-cancellation.mmd` | sequenceDiagram | Deadline and SIGTERM propagation |
| `error-flow.mmd` | flowchart TD | Wrap vs hide vs sentinel decisions |
| `interfaces-and-types.mmd` | classDiagram | Interfaces, implementations, dependencies |
| `domain-model-erd.mmd` | erDiagram | Relational model behind Go structs |
| `state-machine.mmd` | stateDiagram-v2 | Entity / job / connection lifecycles |
| `graceful-shutdown.mmd` | sequenceDiagram | Server shutdown of every long-lived resource |
| `deployment-topology.mmd` | flowchart TD | Where binaries run, with `GOMEMLIMIT` |
| `ci-pipeline.mmd` | flowchart LR | Canonical CI gates and commands |
| `release-branching.mmd` | gitGraph | Module tags including a `/v2` major bump |
| `toolchain-upgrade-flow.mmd` | flowchart TD | Go toolchain upgrade with GODEBUG |
| `vulnerability-triage.mmd` | flowchart TD | Triaging `govulncheck` findings |
| `performance-triage.mmd` | flowchart TD | Choosing the right diagnostic tool |
| `pgo-workflow.mmd` | flowchart LR | Profile-guided optimization loop |
| `test-strategy.mmd` | flowchart TD | Which test kind covers which boundary |
| `migration-strangler.mmd` | flowchart TD | Incremental rewrite of a legacy system |
| `observability-signals.mmd` | flowchart LR | Logs, metrics, traces, profiles |
| `api-evolution.mmd` | flowchart TD | Backward-compatible API extension choices |

Templates live at `assets/templates/<name>.mmd`. Detailed anti-patterns and quoting rules
are in `references/mermaid-gotchas.md`.

## Non-negotiables (summary)

- First line declares the diagram type (`flowchart TD`, `sequenceDiagram`, `stateDiagram-v2`, …).
- Use `stateDiagram-v2`, never `stateDiagram`. Prefer `flowchart` over `graph`.
- Quote labels that contain parentheses, commas, colons, slashes or spaces.
- Never use reserved words as node IDs (`end`, `graph`, `subgraph`, `class`, `style`, …).
- Match arrow syntax to the diagram type.
- Close every `subgraph` / `alt` / `opt` / `loop` / `par` / composite `state` with its own `end`.
- One diagram per fence; always tag the fence `mermaid`.

## Grounding

Diagram content for Go systems should name real identifiers from the repository
(`cmd/api-server`, `internal/order`, `context.WithTimeout`, `database/sql`) so the
diagram stays diffable against the code. Prefer the layouts documented at
[go.dev/doc/modules/layout](https://go.dev/doc/modules/layout).
