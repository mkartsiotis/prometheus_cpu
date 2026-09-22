from pathlib import Path
import sys

if len(sys.argv) != 3:
    raise SystemExit(f"usage: {sys.argv[0]} input.bin output.hex")

data = Path(sys.argv[1]).read_bytes()

if len(data) % 4:
    raise SystemExit("input size must be a multiple of 4 bytes")

with Path(sys.argv[2]).open("w") as output:
    for offset in range(0, len(data), 4):
        word = int.from_bytes(data[offset : offset + 4], byteorder="little")
        output.write(f"{word:08x}\n")
