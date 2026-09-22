# GCC INTEGRATION

## Goal

The main goal of this stage of the project is running freestanding tests and more complete validation such as the gcc torture suite.  

## Steps

1. Rebuild the testbench so as to include data memory initialization and bss data integration.  
The new testbench uses 2 hex input files. One for instruction memory initialization and one for data memory initialization.  
2. Re-engineer validation mechanism. For that step of the process the decision was made to reserve the first 2 words of the data memory for validation.  
Specifically:

| Memory Address | Purpose | Function |
| --- | --- | --- |
| `mem[0]` | Result | Outputs the return value of the program |
| `mem[1]` | Status | `0` = running, `1` = passed and completed, `2` = runtime fail

1. Linker update: All of these changes need to be incorporated into the linker script so that the linker places all the usable data after address 8.  
2. Create the crt0 script that handles stack pointer etc.  

### Verilog testbench module creation

The testbench module accepts the following arguments:
`+INSTRUCTION_IMAGE=` : Instruction image path(hex file)  
`+DATA_IMAGE=` : Data image path(hex file)  
`+INSTRUCTION_WORDS=` : Instruction word count(for memory instantiation)  
`+DATA_WORDS=` : Data word count(for memory instantiation)  
