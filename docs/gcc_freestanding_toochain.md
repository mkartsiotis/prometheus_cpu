# GCC INTEGRATION

## Goal

The main goal of this stage of the project is running freestanding tests and more complete validation such as the gcc torture suite.  

## Steps

1. Rebuild the testbench so as to include data memory initialization and bss data integration.  
The new testbench uses 2 hex input files. One for instruction memory initialization and one for data memory initialization.  
2. Re-engineer validation mechanism. For that step of the process the decision was made to reserve the first 2 words of the instruction memory for validation.  
Specifically:
| Memory Address | Purpose | Function |
| --- | --- | --- |
| `mem[0]` | Result | Outputs the return value of the program |
| `mem[1]` | Status | `0` = running, `1` = passed and completed, `2` = runtime fail |
