---
name: go-review
description: Review the current Go change set for correctness, races, errors, API breaks and tests.
---

# Review Go changes

Use the `go-code-review` skill (and the `go-reviewer` agent mindset).

1. Inspect the diff (`git diff`, PR commits).
2. Run `gofmt -l .`, `go vet ./...`, relevant tests, and `-race` / `govulncheck`
   when concurrency or dependencies changed.
3. Report findings ordered by severity with file references and fixes.
4. Separate must-fix from nice-to-have.
