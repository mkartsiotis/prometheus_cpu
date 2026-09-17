.section .text
.globl _start

_start:
    addi x1, x0, 5
    addi x2, x0, 7
    add  x3, x1, x2
    sw   x3, 0(x0)
    addi x6, x0, 1
    sw   x6, 4(x0)         # completion marker
