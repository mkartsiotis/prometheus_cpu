CROSS := riscv64-elf-

CC      := $(CROSS)gcc
AS      := $(CROSS)as
LD      := $(CROSS)ld
OBJCOPY := $(CROSS)objcopy

PYTHON  := python3
IVERILOG := iverilog
VVP     := vvp

PROGRAM ?= programs/c/return_value.c
PROGRAM_NAME := $(basename $(notdir $(PROGRAM)))
BUILD        := build/c/$(PROGRAM_NAME)
C_SOURCE := $(PROGRAM)

CRT0     := programs/runtime/crt0.S
RUNTIME  := programs/runtime/runtime.c
LINKER   := programs/linker/linker.ld

TEXT_BIN  := $(BUILD)/$(PROGRAM_NAME).text.bin
DATA_BIN  := $(BUILD)/$(PROGRAM_NAME).data.bin
TEXT_HEX  := $(BUILD)/$(PROGRAM_NAME).text.hex
DATA_HEX  := $(BUILD)/$(PROGRAM_NAME).data.hex
ELF       := $(BUILD)/$(PROGRAM_NAME).elf

.PHONY: help run clean

help:
	@printf '%s\n' \
		'Targets:' \
		'  make help    Show this help' \
		'  make run PROGRAM=/path/to/test.c    Build and run the C program' \
		'  make clean   Remove generated build artifacts'

$(BUILD):
	mkdir -p "$@"

$(BUILD)/$(PROGRAM_NAME).o: $(C_SOURCE) | $(BUILD)
	$(CC) -march=rv32i -mabi=ilp32 -ffreestanding -nostdlib \
		-nostartfiles -O0 -c "$<" -o "$@"

$(BUILD)/crt0.o: $(CRT0) | $(BUILD)
	$(AS) -march=rv32i -mabi=ilp32 "$<" -o "$@"

$(BUILD)/runtime.o: $(RUNTIME) | $(BUILD)
	$(CC) -march=rv32i -mabi=ilp32 -ffreestanding -nostdlib \
		-nostartfiles -O0 -c "$<" -o "$@"

$(ELF): $(BUILD)/$(PROGRAM_NAME).o $(BUILD)/crt0.o $(BUILD)/runtime.o $(LINKER)
	$(LD) -m elf32lriscv -T "$(LINKER)" -o "$@" \
		$(BUILD)/crt0.o $(BUILD)/runtime.o $(BUILD)/$(PROGRAM_NAME).o

$(TEXT_BIN): $(ELF)
	$(OBJCOPY) -O binary -j .text "$<" "$@"

$(DATA_BIN): $(ELF)
	$(OBJCOPY) -O binary -j .data "$<" "$@"

$(TEXT_HEX): $(TEXT_BIN)
	$(PYTHON) tools/bin_to_hex.py "$<" "$@"

$(DATA_HEX): $(DATA_BIN)
	$(PYTHON) tools/bin_to_hex.py "$<" "$@"

$(BUILD)/$(PROGRAM_NAME).out: \
		rtl/CPU/rtl/cpu.v rtl/FETCH/rtl/instruction_fetch.v \
		rtl/PC/rtl/pc.v rtl/INSTRUCTION_MEMORY/rtl/instruction_memory.v \
		rtl/IMMEDIATE_GENERATOR/rtl/immediate_generator.v \
		rtl/CONTROL_UNIT/rtl/control_unit.v rtl/REG_FILE/rtl/reg_file.v \
		rtl/MEMORY/rtl/memory.v rtl/ALU/rtl/ALU.v \
		rtl/ALU/rtl/adder.v rtl/ALU/rtl/bitwiseops.v rtl/ALU/rtl/shifter.v \
		tb/cpu_c_tester.v
	$(IVERILOG) -Wall -s cpu_c_tester -o "$@" $^

run: $(TEXT_HEX) $(DATA_HEX) $(BUILD)/$(PROGRAM_NAME).out
	$(VVP) "$(BUILD)/$(PROGRAM_NAME).out" \
		"+INSTRUCTION_IMAGE=$(TEXT_HEX)" \
		"+DATA_IMAGE=$(DATA_HEX)" \
		"+INSTRUCTION_WORDS=$$(wc -l < "$(TEXT_HEX)")" \
		"+DATA_WORDS=$$(wc -l < "$(DATA_HEX)")"

clean:
	rm -rf build/c
