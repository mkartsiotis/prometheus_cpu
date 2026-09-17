.section .text
.globl _start

_start:
    addi x1, x0, 25
    addi x2, x0, 8
    add  x3, x1, x2
    sub  x4, x3, x2
    sw   x4, 0(x0)
