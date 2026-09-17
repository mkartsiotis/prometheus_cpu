.section .text
.globl _start

_start:
    lui  x1, 0x1
    addi x1, x1, 23
    auipc x2, 0
    sub  x3, x1, x2
    sw   x3, 0(x0)
