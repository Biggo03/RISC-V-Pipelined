    .section .text
    .globl _start
_start:
    # x18 = 15
    addi x18, x0, 15         

    # x19 = 14
    addi x19, x0, 14         

    # Branch: since x19 != x18, branch taken
    bne  x19, x18, branch1   

    # Should not execute
    addi x20, x0, -1         

branch1:
    # x20 = 15 << 14 = 229376
    sll  x20, x18, x19       

    # x20 = 229376 >> 15 = 7
    srl  x20, x20, x18       

    # x20 = 7 + 18 = 25
    addi x20, x20, 18        

    # x22 = -1
    addi x22, x0, -1         

    # Arithmetic shift right: x22 remains -1
    sra  x22, x22, x19       

    # Branch: since -1 < 15 (signed), branch taken
    blt  x22, x18, store     

    # Should not execute
    addi x20, x0, 2          
    sw   x20, 100(x0)        

store:
    # Store final x20 (25) at mem[100]
    sw   x20, 100(x0)        

done:
    # Infinite loop
    beq  x0, x0, done        
