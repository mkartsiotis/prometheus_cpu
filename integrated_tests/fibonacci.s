.section .text
.globl _start

_start:
    addi x1, x0, 0
    addi x2, x0, 1
    addi x3, x0, 8

fib_loop:
    add  x4, x1, x2
    addi x1, x2, 0
    addi x2, x4, 0
    addi x3, x3, -1
    beq  x3, x0, fib_done
    beq  x0, x0, fib_loop

fib_done:
    sw   x2, 0(x0)
