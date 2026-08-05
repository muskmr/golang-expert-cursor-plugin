---
name: go-profile
description: Profile a Go package or service and recommend fixes using the canonical diagnostics order.
---

# Profile Go performance

Use the `go-performance` skill and `performance-triage.mmd`.

1. Establish a reproducible benchmark or pprof capture.
2. Start with CPU profiles; only then heap / block / trace.
3. Propose code fixes before GC knobs; consider PGO for production steady-state.
4. Verify with `benchstat` before/after.
