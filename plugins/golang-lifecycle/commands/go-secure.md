---
name: go-secure
description: Run a Go security pass - govulncheck triage, injection review, race and fuzz guidance.
---

# Secure this Go project

Use the `go-security` skill and `go-security-auditor` mindset.

1. Run `scripts/go-vuln.sh` / `govulncheck ./...` and triage with
   `vulnerability-triage.mmd`.
2. Review handlers and data access for injection and path traversal.
3. Ensure concurrent packages have `-race` coverage and parsers have fuzz targets.
4. Produce a severity-ordered remediation list.
