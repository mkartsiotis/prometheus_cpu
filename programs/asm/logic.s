.section .text
.globl _start

_start:
    addi x1, x0, 15
    addi x2, x0, 9
    and  x3, x1, x2
    or   x4, x1, x2
    xor  x5, x1, x2
    add  x6, x3, x4
    add  x6, x6, x5
    sw   x6, 0(x0)
    addi x6, x0, 1
    sw   x6, 4(x0)         # completion marker
