---
name: go-data-access
description: Use database/sql idiomatically - opening handles, pool tuning, queries, transactions, context cancellation and SQL injection prevention. Use when writing or reviewing Go database code.
---

# Go data access

Canonical source: the [database/sql tour](https://go.dev/doc/database/)
(open handle, manage connections, querying, change data, prepared statements,
transactions, cancel operations, SQL injection).

## Open and verify

```go
import (
        "database/sql"
        _ "github.com/jackc/pgx/v5/stdlib"
)

db, err := sql.Open("pgx", dsnFromEnv())
if err != nil { return err }
if err := db.PingContext(ctx); err != nil { return err }
```

`Open` does not establish a connection — always `PingContext`.

## Pool knobs

```go
db.SetMaxOpenConns(n)
db.SetMaxIdleConns(n)          // default 2
db.SetConnMaxIdleTime(d)
db.SetConnMaxLifetime(d)
_ = db.Stats()
```

`SetMaxOpenConns` can deadlock callers if every connection waits on another.
Use `DB.Conn(ctx)` only when you need a dedicated connection; close it.

## Query patterns

| Need | API |
| --- | --- |
| One row | `QueryRowContext` + `Scan` (check `sql.ErrNoRows`) |
| Many rows | `QueryContext` → `for rows.Next()` → **`rows.Err()`** → `defer rows.Close()` |
| Exec | `ExecContext` |
| Tx | `BeginTx` → work on `tx` → `Commit` / `defer Rollback` |

Always take `context.Context`. Always close `Rows` / `Stmt`. Never call `DB`
methods from inside a transaction you started — use the `Tx`.

## SQL injection

```go
// Correct — placeholders (Postgres: $1, MySQL: ?)
rows, err := db.QueryContext(ctx, `SELECT id FROM orders WHERE id = $1`, id)

// Wrong
rows, err := db.QueryContext(ctx, fmt.Sprintf(`SELECT id FROM orders WHERE id = '%s'`, id))
```

## Mapping to diagrams

Use `domain-model-erd.mmd` for the schema and `request-lifecycle.mmd` for the
call path that hits storage.
