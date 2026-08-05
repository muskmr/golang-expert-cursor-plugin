---
name: go-upgrade
description: Plan and execute a Go toolchain or dependency upgrade with release-note and GODEBUG review.
---

# Upgrade Go

Use the `go-upgrade` and `go-modules` skills. Follow `toolchain-upgrade-flow.mmd`.

1. Determine current `go` / `toolchain` lines and the target version.
2. Read release notes for every intermediate version.
3. Prove the suite green on the new toolchain before bumping the `go` line.
4. Review GODEBUG default changes; pin with `//go:debug` only when required.
5. Run modernizers, `govulncheck`, and benchmarks; update CI images.
