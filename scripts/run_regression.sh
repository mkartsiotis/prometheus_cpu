#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${TMPDIR:-/tmp}/zeus_tpu_regression"
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
printf '%s\n' '========================================'
printf '%s\n' ' Zeus TPU module and CPU regression'
printf '%s\n' '========================================'

run_test "Adder" adder_tb \
  ALU/rtl/adder.v ALU/tb/adder_tb.v
run_test "Bitwise operations" bitwiseops_tb \
  ALU/rtl/bitwiseops.v ALU/tb/bitwiseops_tb.v
run_test "Shifter" shifter_tb \
  ALU/rtl/shifter.v ALU/tb/shifter_tb.v
run_test "ALU wrapper" alu_tb \
  ALU/rtl/ALU.v ALU/rtl/adder.v ALU/rtl/bitwiseops.v ALU/rtl/shifter.v ALU/tb/ALU_tb.v
run_test "Register file" reg_file_tb \
  REG_FILE/rtl/reg_file.v REG_FILE/tb/reg_file_tb.v
run_test "Immediate generator" immediate_generator_tb \
  IMMEDIATE_GENERATOR/rtl/immediate_generator.v IMMEDIATE_GENERATOR/tb/immediate_generator_tb.v
run_test "Control unit" control_unit_tb \
  CONTROL_UNIT/rtl/control_unit.v CONTROL_UNIT/tb/control_unit_tb.v
run_test "Instruction memory" instruction_memory_tb \
  INSTRUCTION_MEMORY/rtl/instruction_memory.v INSTRUCTION_MEMORY/tb/instruction_memory_tb.v
run_test "Data memory" memory_tb \
  MEMORY/rtl/memory.v MEMORY/tb/memory_tb.v
run_test "Program counter" pc_tb \
  PC/rtl/pc.v PC/tb/pc_tb.v
run_test "Instruction fetch" instruction_fetch_tb \
  FETCH/rtl/instruction_fetch.v PC/rtl/pc.v INSTRUCTION_MEMORY/rtl/instruction_memory.v FETCH/tb/instruction_fetch_tb.v
run_test "Integrated CPU" cpu_tb \
  CPU/rtl/cpu.v CPU/tb/cpu_tb.v FETCH/rtl/instruction_fetch.v PC/rtl/pc.v \
  INSTRUCTION_MEMORY/rtl/instruction_memory.v IMMEDIATE_GENERATOR/rtl/immediate_generator.v \
  CONTROL_UNIT/rtl/control_unit.v REG_FILE/rtl/reg_file.v MEMORY/rtl/memory.v \
  ALU/rtl/ALU.v ALU/rtl/adder.v ALU/rtl/bitwiseops.v ALU/rtl/shifter.v

printf '%s\n' '----------------------------------------'
printf ' Result: %d passed, %d failed\n' "$passed" "$failed"
printf '%s\n' '========================================'
exit "$failed"
