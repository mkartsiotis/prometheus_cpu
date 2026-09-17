.section .text
.globl _start

_start:
    addi x1, x0, 0
    addi x2, x0, 1
    addi x3, x0, 6

loop:
    add  x1, x1, x2
    addi x3, x3, -1
    beq  x3, x0, done
    beq  x0, x0, loop

done:
    sw   x1, 0(x0)
    addi x6, x0, 1
    sw   x6, 4(x0)         # completion marker
