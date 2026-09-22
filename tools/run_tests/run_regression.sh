#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_DIR="$ROOT/build/regression"
mkdir -p "$BUILD_DIR"

passed=0
failed=0

run_test() {
  local name="$1"
  local top="$2"
  shift 2
  local output="$BUILD_DIR/${top}.out"
  local log="$BUILD_DIR/${top}.log"

  printf '[ RUN  ] %-24s' "$name"
  if iverilog -Wall -s "$top" -o "$output" "$@" >"$log" 2>&1 &&
    vvp "$output" >>"$log" 2>&1 &&
    ! grep -Eq '(\[FAIL\]|FAIL|ERROR|error:)' "$log"; then
    printf '\r[ PASS ] %s\n' "$name"
    passed=$((passed + 1))
  else
    printf '\r[ FAIL ] %s\n' "$name"
    sed -n '/\[FAIL\]\|FAIL\|ERROR\|error:/p' "$log" | head -n 8
    failed=$((failed + 1))
  fi
}

cd "$ROOT"
mkdir -p "$ROOT/build/regression"
SKIP_REPORT=1 "$ROOT/tools/run_tests/run_asm_test.sh" programs/asm/test_1.s 12 >/dev/null
printf '%s\n' '========================================'
printf '%s\n' ' Prometheus CPU module and CPU regression'
printf '%s\n' '========================================'

run_test "Adder" adder_tb \
  rtl/ALU/rtl/adder.v rtl/ALU/tb/adder_tb.v
run_test "Bitwise operations" bitwiseops_tb \
  rtl/ALU/rtl/bitwiseops.v rtl/ALU/tb/bitwiseops_tb.v
run_test "Shifter" shifter_tb \
  rtl/ALU/rtl/shifter.v rtl/ALU/tb/shifter_tb.v
run_test "ALU wrapper" alu_tb \
  rtl/ALU/rtl/ALU.v rtl/ALU/rtl/adder.v rtl/ALU/rtl/bitwiseops.v rtl/ALU/rtl/shifter.v rtl/ALU/tb/ALU_tb.v
run_test "Register file" reg_file_tb \
  rtl/REG_FILE/rtl/reg_file.v rtl/REG_FILE/tb/reg_file_tb.v
run_test "Immediate generator" immediate_generator_tb \
  rtl/IMMEDIATE_GENERATOR/rtl/immediate_generator.v rtl/IMMEDIATE_GENERATOR/tb/immediate_generator_tb.v
run_test "Control unit" control_unit_tb \
  rtl/CONTROL_UNIT/rtl/control_unit.v rtl/CONTROL_UNIT/tb/control_unit_tb.v
run_test "Instruction memory" instruction_memory_tb \
  rtl/INSTRUCTION_MEMORY/rtl/instruction_memory.v rtl/INSTRUCTION_MEMORY/tb/instruction_memory_tb.v
run_test "Data memory" memory_tb \
  rtl/MEMORY/rtl/memory.v rtl/MEMORY/tb/memory_tb.v
run_test "Program counter" pc_tb \
  rtl/PC/rtl/pc.v rtl/PC/tb/pc_tb.v
run_test "Instruction fetch" instruction_fetch_tb \
  rtl/FETCH/rtl/instruction_fetch.v rtl/PC/rtl/pc.v rtl/INSTRUCTION_MEMORY/rtl/instruction_memory.v rtl/FETCH/tb/instruction_fetch_tb.v
run_test "Integrated CPU" cpu_tb \
  rtl/CPU/rtl/cpu.v rtl/CPU/tb/cpu_tb.v rtl/FETCH/rtl/instruction_fetch.v rtl/PC/rtl/pc.v \
  rtl/INSTRUCTION_MEMORY/rtl/instruction_memory.v rtl/IMMEDIATE_GENERATOR/rtl/immediate_generator.v \
  rtl/CONTROL_UNIT/rtl/control_unit.v rtl/REG_FILE/rtl/reg_file.v rtl/MEMORY/rtl/memory.v \
  rtl/ALU/rtl/ALU.v rtl/ALU/rtl/adder.v rtl/ALU/rtl/bitwiseops.v rtl/ALU/rtl/shifter.v

printf '%s\n' '----------------------------------------'
printf ' Result: %d passed, %d failed\n' "$passed" "$failed"
printf '%s\n' '========================================'
exit "$failed"
