#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUNNER="$ROOT/tools/run_tests/run_asm_test.sh"

printf '%s\n' 'Prometheus CPU assembly validation'
rm -f "$ROOT/results/benchmark_results.tsv"
for test in \
  "add_sub.s:25" \
  "logic.s:30" \
  "memory.s:130" \
  "branch_loop.s:6" \
  "fibonacci.s:34" \
  "upper_immediate.s:4111"
do
  IFS=: read -r source expected <<< "$test"
  "$RUNNER" "programs/asm/$source" "$expected"
done

printf '%s\n' 'Validation script completed'
