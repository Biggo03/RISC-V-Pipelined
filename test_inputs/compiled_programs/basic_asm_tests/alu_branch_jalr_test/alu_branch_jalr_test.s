    .section .text
    .globl _start
_start:
    # x18 = 0xAD38E000
    lui   x18, 709518             

    # x18 = 0xAD38E7D0
    addi  x18, x18, 2000          

    # mem[40] = 0xAD38E7D0
    sw    x18, 40(x0)             

    # x19 = 0xFFFFE7D0 (-6192)
    lh    x19, 40(x0)             

    # x20 = 0x0000AD38 (44344)
    lhu   x20, 42(x0)             

    # x21 = (unsigned(x20) < unsigned(x19)) ? 1 : 0
    sltu  x21, x20, x19           

    # Branch taken: x21 != 0
    bne   x0, x21, branch         

    # Should not execute
    add   x19, x0, x0             

branch:
    # x19 = -6192 ^ 44344 = -46360
    xor   x19, x19, x20           

    # x20 = PC + 16384 = 36 + 16384 = 16420
    auipc x20, 4                  

    # x19 = -46360 - 1516 = -47876
    addi  x19, x19, -1516         

    # x21 = (signed(x19) < 20) ? 1 : 0
    slti  x21, x19, 20            

    # x22 = (unsigned(x19) < 20) ? 1 : 0 → 0
    sltiu x22, x19, 20            

    # x21 = 1 + 0 = 1
    add   x21, x21, x22           

    # x20 = -47876 + 16420 = -31456
    add   x20, x19, x20           

    # x20 = -31456 + 1 = -31455
    add   x20, x20, x21           

    # Jump to PC + 72 → lands at srli
    jalr  x21, x0, 72             

    # Should not execute
    addi  x20, x0, 0              

    # x20 = -31455 >> 22 = 1023
    srli  x20, x20, 22            

    # x20 = 1023 - 68 = 955
    sub   x20, x20, x21           

    # x20 = 955 - 930 = 25
    addi  x20, x20, -930          

    # Store result: mem[100] = 25
    sw    x20, 100(x0)            

done:
    # Infinite loop
    beq   x0, x0, done            
