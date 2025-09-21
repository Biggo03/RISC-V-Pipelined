    .section .text
    .globl _start
_start:
    # Set stack pointer
    la sp, _stack_top

    # Clear .bss
    la a0, __bss_start   # start of bss
    la a1, __bss_end     # end of bss
    li a2, 0             # zero value
bss_clear:
    bgeu a0, a1, bss_done
    sw a2, 0(a0)
    addi a0, a0, 4
    j bss_clear
bss_done:

    # Call main()
    call main

    # If main returns, spin forever
1:  j 1b

