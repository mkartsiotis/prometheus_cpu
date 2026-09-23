.section .text.start
.globl _start
.type _start, @function

_start:
    # Initialize the stack pointer.
    la sp, __stack_top

    # Clear the .bss section.
    la t0, __bss_start
    la t1, __bss_end

.Lclear_bss:
    beq t0, t1, .Lcall_main
    sw zero, 0(t0)
    addi t0, t0, 4
    jal zero, .Lclear_bss

.Lcall_main:
    # Call the C entry point.
    jal ra, main
    jal ra, runtime_finish

.Lhalt:
    jal zero, .Lhalt

.size _start, .-_start
