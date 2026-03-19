#!/usr/bin/env bash
set -euo pipefail

# Rough Diem estimate by mode and source count.
mode="${1:-routine}"
sources="${2:-2}"

case "$mode" in
  routine) base=0.08 ;;
  burn) base=0.60 ;;
  *) echo "Unknown mode: $mode" >&2; exit 2 ;;
esac

# Add small increment per source beyond 1
extra=$(awk -v s="$sources" 'BEGIN { v=(s>1)?(s-1)*0.03:0; printf "%.4f", v }')
awk -v b="$base" -v e="$extra" 'BEGIN { printf "%.4f\n", b+e }'
