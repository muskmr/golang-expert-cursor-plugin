---
name: go-test
description: Design or extend table-driven tests, fuzz targets and benchmarks for the focused Go packages.
---

# Improve Go tests

Use the `go-testing` skill.

1. Identify packages with weak or missing coverage.
2. Add table-driven tests and subtests; add fuzz targets for parsers.
3. For concurrent code, add race-safe tests and consider `testing/synctest`.
4. Run `go test ./... -count=1` and `go test -race` where relevant.
5. Summarise coverage gaps with the `test-strategy.mmd` diagram if useful.
