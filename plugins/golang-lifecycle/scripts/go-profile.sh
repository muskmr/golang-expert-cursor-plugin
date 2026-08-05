#!/usr/bin/env bash
# Collect CPU/memory profiles from go test benchmarks.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/scripts/lib.sh"

pkg="${1:-./...}"
bench="${2:-.}"
outdir="${3:-./profiles}"

require_cmd go
mkdir -p "$outdir"

echo "writing profiles under $outdir"
go test -run=^$ -bench="$bench" -benchmem \
  -cpuprofile="$outdir/cpu.out" \
  -memprofile="$outdir/mem.out" \
  "$pkg"

echo
echo "inspect with:"
echo "  go tool pprof -http=:0 $outdir/cpu.out"
echo "  go tool pprof -http=:0 $outdir/mem.out"
