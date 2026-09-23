# GCC INTEGRATION

## Goal

The goal of this stage is to run compiler-generated freestanding C programs on
the Verilog CPU without an operating system or hosted C library. Later, this
flow can support a selected subset of the GCC torture tests.

## Steps

The current flow is:

```text
C source
  -> riscv64-elf-gcc
  -> C object file
  -> crt0.S + linker
  -> ELF executable
  -> .text/.data binary images
  -> word-oriented .hex files
  -> Icarus Verilog CPU simulation
```

Run a program from the repository root with:

```bash
make run PROGRAM=programs/c/return_value.c
```

Generated files are stored in `build/c/<program-name>/`.

## Validation mailbox

The testbench uses two reserved data-memory words:

  | Memory Address | Purpose | Function |
  | --- | --- | --- |
  | `mem[0]` | Result | Outputs the return value of the program |
  | `mem[1]` | Status | `0` = running, `1` = passed and completed, `2` = runtime fail

Normal program data begins at address `0x10000008`, which is data-memory word
`mem[2]` in the current testbench mapping.

## Startup code: `programs/runtime/crt0.S`

`crt0.S` is the first code executed after reset. It:

1. Loads the stack pointer from the linker-defined `__stack_top` symbol.
2. Clears `.bss` from `__bss_start` through `__bss_end`.
3. Calls the C function `main`.
4. Stores the return value from `a0` in `mem[0]`.
5. Stores status `1` in `mem[1]`.
6. Loops forever while the testbench observes the mailbox.

The startup sequence is target-specific runtime code; it is not the standard
hosted C runtime and does not require an operating system.

### Verilog testbench module creation

The testbench module accepts the following plusargs:

| Plusarg | Meaning |
| --- | --- |
| `+INSTRUCTION_IMAGE=` | Instruction image path |
| `+DATA_IMAGE=` | Initialized data image path |
| `+INSTRUCTION_WORDS=` | Number of instruction words to load |
| `+DATA_WORDS=` | Number of data words to load |

## Linker script: `programs/linker/linker.ld`

The linker script defines the CPU memory map:

```ld
IMEM (rx): origin 0x00000000, length 1K
DMEM (rw): origin 0x10000008, length 16376
```

It places:

| Section | Destination | Meaning |
| --- | --- | --- |
| `.text` | instruction memory | Executable instructions |
| `.rodata` | instruction memory | Read-only constants |
| `.data` | data memory | Initialized writable data |
| `.bss` | data memory | Zero-initialized data |

The script exports:

```text
__bss_start
__bss_end
__stack_top
```

`crt0.S` uses these symbols to clear `.bss` and initialize the stack. The
`.bss` section is marked `NOLOAD`, so it occupies runtime memory but does not
need bytes in the initialized data image.

`riscv64-elf-objcopy` extracts `.text` and `.data` separately. The generated
binary files are converted by `tools/bin_to_hex.py`, which groups four
little-endian bytes into one 32-bit word per line for `$readmemh`.

The successful simulator output has the form:

```text
PROGRAM_RESULT result=25 status=1 cycles=21
```

## Completing calls for GCC-TORTURE TESTING

We need to implement some runtime functions so as to be able to run the gcc-torture suite and validate the CPU completely.  
Specifically:

- exit  
- abort  
- memory functions(memcpy, memmove, memset, memcmp)  

Basic exit and abort functions will be implemented in the ![runtime.c](../programs/runtime/runtime.c) file.  
The mechanism is easy since we have already reserved an address(mem[1]) for the status. So we just need some code to turn that to 1 (exit(0)) or 2(abort(), exit(1)) to indicate failure.  
