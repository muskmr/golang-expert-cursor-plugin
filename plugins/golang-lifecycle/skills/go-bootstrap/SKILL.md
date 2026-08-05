---
name: go-bootstrap
description: Scaffold a new Go module, command, library or server using the layouts documented at go.dev/doc/modules/layout. Use when creating a new Go project or adding a binary/package to an existing module.
---

# Go bootstrap

Create Go projects the way [Organizing a Go module](https://go.dev/doc/modules/layout)
describes. Do not invent `pkg/`, `api/` or "standard project layout" directories unless
the user asks for them.

## Choose a skeleton

| Goal | Skeleton |
| --- | --- |
| Importable library | Root package + optional `internal/` |
| Single CLI | Root `main` **or** `cmd/<name>/main.go` |
| Multiple CLIs | `cmd/<a>`, `cmd/<b>`, shared `internal/` |
| Server / service | `cmd/<binary>/main.go` + **all logic in `internal/`** |
| Mixed lib + tools | Root packages + `cmd/` + `internal/` |

## Commands

```bash
mkdir -p example.com/service && cd example.com/service
go mod init example.com/service          # go line defaults to N-1 on Go 1.26+
# optional: pin an exact language version
go get go@1.25.0

mkdir -p cmd/api-server internal/api internal/platform
```

Minimal `cmd/api-server/main.go`:

```go
package main

import (
        "context"
        "log/slog"
        "os"
        "os/signal"

        "example.com/service/internal/api"
)

func main() {
        ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
        defer stop()

        log := slog.New(slog.NewJSONHandler(os.Stdout, nil))
        if err := api.Run(ctx, log); err != nil {
                log.Error("server exited", "err", err)
                os.Exit(1)
        }
}
```

## Checklist

- [ ] `module` path is a URL without scheme and matches where the code will live
- [ ] Packages that are not part of the public API sit under `internal/`
- [ ] Every exported identifier has a doc comment
- [ ] `go test ./...` passes (add at least one `_test.go`)
- [ ] `gofmt` is clean; prefer a `go.mod` `tool` directive for project tools (Go 1.24+)
- [ ] Draw the intended layout with `layered-packages.mmd` before coding if the
      design is non-trivial
