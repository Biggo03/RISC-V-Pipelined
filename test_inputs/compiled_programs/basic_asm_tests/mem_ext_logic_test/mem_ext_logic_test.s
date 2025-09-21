    .section .text
    .globl _start
_start:
    # x18 = 500 (0x1F4)
    addi x18, x0, 500         

    # mem[40] = 0x..F4 (store byte)
    sb   x18, 40(x0)          

    # x18 = 1950 (0x79E)
    addi x18, x0, 1950        

    # mem[42..43] = 0x079E (store halfword)
    sh   x18, 42(x0)          

    # x19 = -1 (0xFFFFFFFF)
    addi x19, x0, -1          

    # mem[41] = 0xFF (store byte)
    sb   x19, 41(x0)          

    # Branch taken: unsigned(-1) >= unsigned(1950)
    bgeu x19, x18, branch1    

    # Should not execute
    sh   x18, 40(x0)          

branch1:
    # Load byte (sign-extended): x18 = -12 (0xFFFFFFF4)
    lb   x18, 40(x0)          

    # Load byte (zero-extended): x19 = 158 (0x9E)
    lbu  x19, 42(x0)          

    # x19 = 158 & 125 = 4
    andi x19, x19, 125        

    # x19 = 4 | 25 = 29
    ori  x19, x19, 25         

    # x19 = 29 ^ 4 = 25
    xori x19, x19, 4          

    # x19 = 25 + (-12) = 13
    add  x19, x19, x18        

    # x19 = 13 + 12 = 25
    addi x19, x19, 12         

    # Store result at mem[100] = 25
    sw   x19, 100(x0)         

done:
    # Infinite loop
    beq  x0, x0, done         
