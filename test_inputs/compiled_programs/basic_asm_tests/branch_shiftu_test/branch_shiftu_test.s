    .section .text
    .globl _start
_start:
    # x18 = 15
    addi x18, x0, 15         

    # x19 = 14
    addi x19, x0, 14         

    # Branch: since x18 >= x19, branch taken
    bge  x18, x19, branch1   

    # Should not execute
    addi x18, x0, -1         

branch1:
    # x20 = 15 << 14 = 229376
    slli x20, x18, 14        

    # x20 = 229376 >> 15 = 7
    srli x20, x20, 15        

    # x20 = 7 + 18 = 25
    addi x20, x20, 18        

    # x22 = -1
    addi x22, x0, -1         

    # Arithmetic shift right: x22 stays -1
    srai x22, x22, 10        

    # Unsigned compare: x18 (15) < x22 (0xFFFFFFFF) → branch taken
    bltu x18, x22, store     

    # Should not execute
    addi x20, x0, 2          
    sw   x20, 100(x0)        

store:
    # Store final x20 (25) at mem[100]
    sw   x20, 100(x0)        

done:
    # Infinite loop
    beq  x0, x0, done        
