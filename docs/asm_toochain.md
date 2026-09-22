# Assembly toolchain documentation

## Basic pipeline

The toolchain is a software-to-hardware simulation pipeline:

RISC-V assembly
      |
      v
riscv64-elf-as       assembler
      |
      v
object file (.o)
      |
      v
riscv64-elf-ld       linker + linker script
      |
      v
ELF executable (.elf)
      |
      v
riscv64-elf-objcopy  extract machine-code section
      |
      v
raw binary (.bin)
      |
      v
bin-to-hex conversion
      |
      v
word-oriented memory image (.hex)
      |
      v
Icarus Verilog + CPU testbench
      |
      v
simulated CPU execution + metrics

## Reformed repo structure

prometheus_cpu/
├── rtl/
│   ├── CPU/rtl/
│   ├── ALU/rtl/
│   ├── MEMORY/rtl/
│   ├── REG_FILE/rtl/
│   └── ...
├── programs/
│   ├── asm/
│   │   ├── add_sub.s
│   │   ├── logic.s
│   │   ├── memory.s
│   │   └── ...
│   └── linker/
│       └── linker.ld
├── tools/
│   ├── bin_to_hex.py
│   └── run_tests/
│       ├── run_asm_test.sh
│       ├── final_validation.sh
│       └── run_regression.sh
├── build/
│   └── assembly/
├── results/
│   └── benchmark_results.tsv
└── README.md

The principle is:

┌──────────────────┬────────────────────────────────────────────────┐
│ Directory        │ Purpose                                        │
├──────────────────┼────────────────────────────────────────────────┤
│ rtl/             │ Hardware implementation and module testbenches │
├──────────────────┼────────────────────────────────────────────────┤
│ programs/asm/    │ Input assembly programs                        │
├──────────────────┼────────────────────────────────────────────────┤
│ programs/linker/ │ Linker scripts defining memory layout          │
├──────────────────┼────────────────────────────────────────────────┤
│ tools/           │ Conversion and automation scripts              │
├──────────────────┼────────────────────────────────────────────────┤
│ build/           │ Generated intermediate files                   │
├──────────────────┼────────────────────────────────────────────────┤
│ results/         │ Human-readable measurement reports             │
└──────────────────┴────────────────────────────────────────────────┘
