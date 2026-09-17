.section .text
.globl _start

_start:
    addi x1, x0, 123
    sw   x1, 16(x0)
    lw   x2, 16(x0)
    addi x2, x2, 7
    sw   x2, 0(x0)
