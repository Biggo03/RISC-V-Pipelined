    .section .text._start
    .globl _start
_start:
    # set up stack
    la sp, __stack_top

    # zero out .bss
    la t0, __bss_start
    la t1, __bss_end
1:  beq t0, t1, 2f
    sw x0, 0(t0)
    addi t0, t0, 4
    j 1b
2:
    # call main
    call main

    # if main ever returns, hang
hang:
    j hang
