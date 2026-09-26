## Requirements

To build, simulate, and synthesize this project you'll need:

- **Icarus Verilog** (`iverilog`) — RTL simulation and running the testbenches
  - `sudo apt install iverilog`
- **GTKWave** (optional) — viewing simulation waveforms
  - `sudo apt install gtkwave`
- **Yosys** (0.66+) — synthesis
  - `sudo apt install yosys` (or build from source for the latest version)
- **nextpnr-ice40** — place and route for the target FPGA (Lattice iCE40-HX8K, `ct256`)
  - `sudo apt install nextpnr-ice40` (or via [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build))
- **RISC-V GNU Toolchain** (`riscv64-unknown-elf-as`, `-ld`, `-objcopy`) — assembling and linking test programs
  - Build from [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) or install a prebuilt release
- **Python 3.x** — the hex packaging script that converts `.bin` → `.hex` for `$readmemh`
- **Bash** — running `scripts/run_asm_test.sh` and `scripts/final_validation.sh`
- GNU make
