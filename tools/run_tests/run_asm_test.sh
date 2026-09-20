#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SOURCE="${1:-}"
EXPECTED="${2:-}"

if [[ -z "$SOURCE" || -z "$EXPECTED" || ! -f "$ROOT/$SOURCE" ]]; then
  printf 'usage: %s <assembly-file> <expected-mem0>\n' "$0" >&2
  exit 2
fi

command -v riscv64-elf-as >/dev/null
command -v riscv64-elf-ld >/dev/null
command -v riscv64-elf-objcopy >/dev/null
command -v python3 >/dev/null

SOURCE_PATH="$ROOT/$SOURCE"
NAME="$(basename "$SOURCE" .s)"
BUILD="$ROOT/build/assembly/$NAME"
mkdir -p "$BUILD"

riscv64-elf-as -march=rv32i -mabi=ilp32 \
  -o "$BUILD/$NAME.o" "$SOURCE_PATH"
riscv64-elf-ld -m elf32lriscv \
  -T "$ROOT/programs/linker/linker.ld" \
  -o "$BUILD/$NAME.elf" "$BUILD/$NAME.o"
riscv64-elf-objcopy -O binary -j .text \
  "$BUILD/$NAME.elf" "$BUILD/$NAME.bin"

python3 - "$BUILD/$NAME.bin" "$BUILD/$NAME.hex" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1]).read_bytes()
if len(source) % 4:
    raise SystemExit("text image size is not a multiple of four bytes")

with Path(sys.argv[2]).open("w") as output:
    for offset in range(0, len(source), 4):
        word = int.from_bytes(source[offset:offset + 4], "little")
        output.write(f"{word:08x}\n")
PY

WORDS="$(wc -l <"$BUILD/$NAME.hex")"

iverilog -Wall -s cpu_image_tb -o "$BUILD/$NAME.out" \
  "$ROOT/rtl/CPU/rtl/cpu.v" \
  "$ROOT/rtl/CPU/tb/cpu_image_tb.v" \
  "$ROOT/rtl/FETCH/rtl/instruction_fetch.v" \
  "$ROOT/rtl/PC/rtl/pc.v" \
  "$ROOT/rtl/INSTRUCTION_MEMORY/rtl/instruction_memory.v" \
  "$ROOT/rtl/IMMEDIATE_GENERATOR/rtl/immediate_generator.v" \
  "$ROOT/rtl/CONTROL_UNIT/rtl/control_unit.v" \
  "$ROOT/rtl/REG_FILE/rtl/reg_file.v" \
  "$ROOT/rtl/MEMORY/rtl/memory.v" \
  "$ROOT/rtl/ALU/rtl/ALU.v" \
  "$ROOT/rtl/ALU/rtl/adder.v" \
  "$ROOT/rtl/ALU/rtl/bitwiseops.v" \
  "$ROOT/rtl/ALU/rtl/shifter.v"

OUTPUT="$(vvp "$BUILD/$NAME.out" \
  "+IMAGE=$BUILD/$NAME.hex" \
  "+EXPECTED=$EXPECTED" \
  "+WORDS=$WORDS")"

printf '%s\n' "$OUTPUT"

CYCLES="$(printf '%s\n' "$OUTPUT" |
  sed -n 's/.*Completion marker after \([0-9][0-9]*\) cycles.*/\1/p')"
BENCHMARK="$(printf '%s\n' "$OUTPUT" |
  sed -n 's/^BENCHMARK_RESULT //p')"
REPORT="$ROOT/results/benchmark_results.tsv"
mkdir -p "$ROOT/results"

if [[ ! -f "$REPORT" ]]; then
  printf 'program\tcycles\tinstructions\tcpi\tloads\tstores\tbranches\ttaken_branches\tjumps\talu\tresult\n' >"$REPORT"
fi

if [[ "${SKIP_REPORT:-0}" == "1" ]]; then
  exit 0
fi

if [[ -z "$BENCHMARK" ]]; then
  printf 'benchmark result was not emitted\n' >&2
  exit 1
fi

metric() {
  printf '%s\n' "$BENCHMARK" |
    tr ' ' '\n' |
    sed -n "s/^$1=//p"
}

printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  "$NAME" \
  "$(metric cycles)" \
  "$(metric instructions)" \
  "$(metric cpi)" \
  "$(metric loads)" \
  "$(metric stores)" \
  "$(metric branches)" \
  "$(metric taken_branches)" \
  "$(metric jumps)" \
  "$(metric alu)" \
  "$(metric result)" >>"$REPORT"
