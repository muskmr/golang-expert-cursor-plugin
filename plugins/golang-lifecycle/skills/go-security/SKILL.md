---
name: go-security
description: Harden Go projects - govulncheck, fuzzing, race detection, safe database/sql, FIPS 140-3 mode, threat model awareness and supply-chain hygiene. Use for security reviews, vulnerability response or hardening.
---

# Go security

Canonical sources: [Security Best Practices](https://go.dev/doc/security/best-practices),
[Go vulnerability management](https://go.dev/security/vuln),
[Go Fuzzing](https://go.dev/security/fuzz),
[FIPS 140-3](https://go.dev/doc/security/fips140),
[threat model](https://go.dev/doc/security/threat-model),
[SQL injection](https://go.dev/doc/database/sql-injection).

## Checklist

1. **Keep the toolchain and dependencies current.** Point releases fix security bugs.
2. **Scan with govulncheck** (call-stack aware):

```bash
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...
govulncheck -json ./... > vuln.json    # CI
# plugin helper (network install is opt-in):
#   ./scripts/go-vuln.sh
#   ./scripts/go-vuln.sh --install
```

3. **Triage** with `vulnerability-triage.mmd`:
   - Reachable (has call stack) → must fix
   - Informational (imported, not called) → watch
4. **Race detector** on concurrent code: `go test -race ./...`
5. **Fuzz parsers and decoders** that accept untrusted input.
6. **Never build SQL / shell / LDAP with `fmt.Sprintf`.** Use `database/sql`
   placeholders (`?` or `$1` per driver).
7. **Do not commit secrets.** Load with `os.Getenv` / a secret manager.
8. **Pin module versions** via `go.sum`; run `go mod verify`.
9. **Subscribe** to `golang-announce` for security releases.

## FIPS 140-3 (when required)

| Knob | Meaning |
| --- | --- |
| `GOFIPS140=latest` (build-time) | Bundle FIPS module; enable mode by default |
| `GODEBUG=fips140=on` | Enable at runtime |
| `GODEBUG=fips140=only` | Testing only — non-approved algs error/panic |
| `crypto/fips140.Enabled()` | Check at runtime |

## Threat-model reminders

Go's threat model assumes a trusted build environment and does **not** treat
malicious Go source as a security boundary for the author. Focus hardening on
**trust boundaries that accept untrusted input** (net/http handlers, decoders,
template execution, `os` / `filepath` with user paths — prefer `os.Root` since
1.24 for directory-scoped filesystem access).
