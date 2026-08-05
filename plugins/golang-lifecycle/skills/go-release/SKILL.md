---
name: go-release
description: Publish Go modules and ship Go binaries - tagging, semver, v2+ module paths, build metadata, CI gates and graceful production rollout. Use when releasing a library or deploying a service.
---

# Go release

Canonical sources: [Module release workflow](https://go.dev/doc/modules/release-workflow),
[Publishing a module](https://go.dev/doc/modules/publishing),
[Developing a major version update](https://go.dev/doc/modules/major-version),
[supply-chain blog](https://go.dev/blog/supply-chain).

## Library / module release

1. `go test ./... -race` and `govulncheck ./...` are green.
2. `go mod tidy`; commit `go.mod` / `go.sum`.
3. Tag an annotated semantic version and push the tag:

```bash
git tag -a v1.4.2 -m "v1.4.2"
git push origin v1.4.2
```

4. Proxies pick it up; docs appear on pkg.go.dev after the first fetch.
5. For a breaking change that cannot be additive: publish as
   `module example.com/mod/v2` with tag `v2.0.0` (see `release-branching.mmd`).

Version meaning: patch = no API change; minor = backward-compatible API additions;
major = incompatible + new module path for `v2+`.

## Binary / service release

```bash
go build -trimpath -ldflags="-s -w" -o bin/api ./cmd/api-server
# Go 1.24+ stamps VCS revision automatically; disable with -buildvcs=false
go version -m -json ./bin/api
```

CI gates (see `ci-pipeline.mmd`):

1. `gofmt -l .`
2. `go mod tidy` + clean diff
3. `go build ./...`
4. `go vet ./...`
5. `go test ./... -count=1`
6. `go test -race ./...`
7. `govulncheck ./...`
8. Optional: fuzz (nightly), benchstat vs base, PGO rebuild with `default.pgo`

## Production rollout

- Document `GOMEMLIMIT` (5–10% under the container memory limit) and rely on
  Go 1.25+ container-aware `GOMAXPROCS`.
- Drain with the `graceful-shutdown.mmd` sequence.
- Keep `/debug/pprof` internal; collect a CPU profile for the next PGO build.
