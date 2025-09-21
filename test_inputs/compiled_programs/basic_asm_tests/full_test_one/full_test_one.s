    .section .text
    .globl _start
_start:
    # --- First block: LUI, ADDI, stores, compares, branches ---
    lui   x18, 709518              # x18 = 0xAD38E000
    addi  x18, x18, 2000           # x18 = 0xAD38E7D0
    sw    x18, 40(x0)              # mem[40] = 0xAD38E7D0

    lh    x19, 40(x0)              # x19 = -6192 (0xFFFFE7D0)
    lhu   x20, 42(x0)              # x20 = 44344 (0x0000AD38)
    sltu  x21, x20, x19            # unsigned compare, x21 = 1
    bne   x0, x21, branch0         # branch taken
    add   x19, x0, x0              # should not execute

branch0:
    xor   x19, x19, x20            # x19 = -46360
    auipc x20, 4                   # x20 = PC+16384
    addi  x19, x19, -1516          # x19 = -47876
    slti  x21, x19, 20             # signed compare, x21 = 1
    sltiu x22, x19, 20             # unsigned compare, x22 = 0
    add   x21, x21, x22            # x21 = 1
    add   x20, x19, x20            # x20 = -31456
    add   x20, x20, x21            # x20 = -31455
    jalr  x21, x0, 72              # jump to srli

    addi  x20, x0, 0               # should not run
    srli  x20, x20, 22             # x20 = 1023
    sub   x20, x20, x21            # x20 = 955
    addi  x20, x20, -930           # x20 = 25
    sw    x20, 144(x0)             # mem[144] = 25

    # --- Second block: store/loads with bytes/halfwords ---
    add   x18, x0, x0              # clear x18
    addi  x1, x0, 500              # x1 = 500
    sb    x1, 40(x0)               # mem[40] = ..F4
    addi  x1, x0, 1950             # x1 = 1950
    sh    x1, 42(x0)               # mem[42..43] = 0x079E
    addi  x2, x0, -1               # x2 = -1
    sb    x2, 41(x0)               # mem[41] = 0xFF
    bgeu  x2, x11, branch1         # branch taken
    sh    x1, 40(x0)               # should not run

branch1:
    lb    x1, 40(x0)               # x1 = -12
    lbu   x2, 42(x0)               # x2 = 158
    andi  x2, x2, 125              # x2 = 4
    ori   x2, x2, 25               # x2 = 29
    xori  x2, x2, 4                # x2 = 25
    add   x2, x2, x1               # x2 = 13
    addi  x2, x2, 12               # x2 = 25
    sw    x2, 148(x0)              # mem[148] = 25

    # --- Third block: shift + branch test ---
    add   x18, x0, x0
    addi  x3, x0, 15
    addi  x4, x0, 14
    bge   x3, x4, branch2
    addi  x3, x0, -1               # should not run

branch2:
    slli  x5, x3, 14               # x5 = 229376
    srli  x5, x5, 15               # x5 = 7
    addi  x5, x5, 18               # x5 = 25
    addi  x6, x0, -1               # x6 = -1
    srai  x6, x6, 10               # x6 = -1
    bltu  x3, x6, store3           # branch taken
    addi  x5, x0, 2                # should not run
    sw    x5, 100(x0)              # should not run

store3:
    sw    x5, 152(x0)              # mem[152] = 25

    # --- Fourth block: more branch/shift mix ---
    add   x18, x0, x0
    addi  x7, x0, 15
    addi  x8, x0, 14
    bne   x8, x7, branch3          # branch taken
    addi  x9, x0, -1               # should not run

branch3:
    sll   x9, x7, x8               # x9 = 229376
    srl   x9, x9, x7               # x9 = 7
    addi  x9, x9, 18               # x9 = 25
    addi  x10, x0, -1              # x10 = -1
    sra   x10, x10, x8             # x10 = -1
    blt   x10, x7, store4          # branch taken
    addi  x9, x0, 2                # should not run
    sw    x9, 100(x0)              # should not run

store4:
    sw    x9, 156(x0)              # mem[156] = 25

    # --- Fifth block: simple OR/AND/SLT test ---
    add   x18, x0, x0
    addi  x11, x0, 5
    addi  x12, x0, 12
    addi  x14, x12, -9             # x14 = 3
    or    x13, x14, x11            # x13 = 7
    and   x15, x12, x13            # x15 = 4
    add   x15, x15, x13            # x15 = 11
    beq   x15, x14, end1           # not taken
    slt   x13, x12, x13            # x13 = 1
    beq   x13, x0, around1         # taken
    addi  x15, x0, 0               # should not run

around1:
    slt   x13, x14, x11            # x13 = 1
    add   x14, x13, x15            # x14 = 12
    sub   x14, x14, x11            # x14 = 7
    sw    x14, 84(x12)             # mem[96] = 7
    lw    x11, 96(x0)              # x11 = 7
    add   x16, x11, x15            # x16 = 18
    jal   x12, end1                # jump to end1

    addi  x12, x12, -272           # should not run
    addi  x11, x0, 1               # should not run

end1:
    add   x11, x11, x16            # x11 = 25
    sw    x11, -180(x12)           # mem[160] = 25

    # --- Sixth block: register walk + final check ---
    add   x18, x0, x0
    addi  x17, x0, 1
    addi  x22, x17, 1
    addi  x23, x22, 1
    addi  x24, x23, 1
    addi  x25, x24, 1
    addi  x26, x25, 1
    addi  x27, x26, 1
    addi  x28, x27, 1
    addi  x29, x28, 1
    addi  x30, x29, 1
    addi  x31, x30, 1

    lw    x1, 144(x0)              # x1 = 25
    lw    x2, 148(x0)              # x2 = 25
    lw    x3, 152(x0)              # x3 = 25
    lw    x4, 156(x0)              # x4 = 25
    lw    x5, 160(x0)              # x5 = 25

    add   x6, x0, x0
    add   x6, x6, x1
    sub   x6, x6, x2
    add   x6, x6, x3
    sub   x6, x6, x4
    add   x6, x6, x5
    sw    x6, 100(x0)              # mem[100] = 25

done:
    beq   x0, x0, done             # infinite loop

