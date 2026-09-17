#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="${1:-}"
EXPECTED="${2:-12}"
CYCLES="${3:-20}"

if [[ -z "$SOURCE" || ! -f "$ROOT/$SOURCE" ]]; then
  printf 'usage: %s <assembly-file> [expected-mem0] [cycles]\n' "$0" >&2
  exit 2
fi

command -v riscv64-elf-as >/dev/null
command -v riscv64-elf-ld >/dev/null
command -v riscv64-elf-objcopy >/dev/null
command -v python3 >/dev/null

SOURCE_PATH="$ROOT/$SOURCE"
NAME="$(basename "$SOURCE" .s)"
BUILD="$ROOT/integrated_tests/build/$NAME"
mkdir -p "$BUILD"

riscv64-elf-as -march=rv32i -mabi=ilp32 \
  -o "$BUILD/$NAME.o" "$SOURCE_PATH"
riscv64-elf-ld -m elf32lriscv \
  -T "$ROOT/integrated_tests/linker.ld" \
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

iverilog -Wall -s cpu_image_tb -o "$BUILD/$NAME.out" \
  "$ROOT/CPU/rtl/cpu.v" \
  "$ROOT/CPU/tb/cpu_image_tb.v" \
  "$ROOT/FETCH/rtl/instruction_fetch.v" \
  "$ROOT/PC/rtl/pc.v" \
  "$ROOT/INSTRUCTION_MEMORY/rtl/instruction_memory.v" \
  "$ROOT/IMMEDIATE_GENERATOR/rtl/immediate_generator.v" \
  "$ROOT/CONTROL_UNIT/rtl/control_unit.v" \
  "$ROOT/REG_FILE/rtl/reg_file.v" \
  "$ROOT/MEMORY/rtl/memory.v" \
  "$ROOT/ALU/rtl/ALU.v" \
  "$ROOT/ALU/rtl/adder.v" \
  "$ROOT/ALU/rtl/bitwiseops.v" \
  "$ROOT/ALU/rtl/shifter.v"

vvp "$BUILD/$NAME.out" \
  "+IMAGE=$BUILD/$NAME.hex" \
  "+EXPECTED=$EXPECTED" \
  "+CYCLES=$CYCLES"
