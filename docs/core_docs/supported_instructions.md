# Supported Instructions

## Overview
This document lists all instructions currently supported by the processor, grouped by type.  
Each entry includes a short description of its function and operands.  
The full instruction encodings and decode mappings are maintained in [`spreadsheets/instr_decode_table.xlsx`](spreadsheets/instr_decode_table.xlsx).

## Arithmetic and Logical Instructions
| Mnemonic | Type | Description |
|----------|------|-------------|
| ADD  | R | Add two registers. |
| SUB  | R | Subtract second register from first. |
| AND  | R | Bitwise AND. |
| OR   | R | Bitwise OR. |
| XOR  | R | Bitwise XOR. |
| SLL  | R | Shift left logical. |
| SRL  | R | Shift right logical. |
| SRA  | R | Shift right arithmetic. |
| SLT  | R | Set if less than (signed). |
| SLTU | R | Set if less than (unsigned). |

## Immediate Arithmetic Instructions
| Mnemonic | Type | Description |
|----------|------|-------------|
| ADDI  | I | Add immediate. |
| ANDI  | I | Bitwise AND with immediate. |
| ORI   | I | Bitwise OR with immediate. |
| XORI  | I | Bitwise XOR with immediate. |
| SLLI  | I | Shift left logical immediate. |
| SRLI  | I | Shift right logical immediate. |
| SRAI  | I | Shift right arithmetic immediate. |
| SLTI  | I | Set if less than immediate (signed). |
| SLTIU | I | Set if less than immediate (unsigned). |

## Load and Store Instructions
| Mnemonic | Type | Description |
|----------|------|-------------|
| LW  | I | Load word. |
| LH  | I | Load halfword (sign-extended). |
| LHU | I | Load halfword (zero-extended). |
| LB  | I | Load byte (sign-extended). |
| LBU | I | Load byte (zero-extended). |
| SW  | S | Store word. |
| SH  | S | Store halfword. |
| SB  | S | Store byte. |

## Branch and Jump Instructions
| Mnemonic | Type | Description |
|----------|------|-------------|
| BEQ  | B | Branch if equal. |
| BNE  | B | Branch if not equal. |
| BLT  | B | Branch if less than (signed). |
| BGE  | B | Branch if greater or equal (signed). |
| BLTU | B | Branch if less than (unsigned). |
| BGEU | B | Branch if greater or equal (unsigned). |
| JAL  | J | Jump and link. |
| JALR | I | Jump and link register. |

## Upper Immediate Instructions
| Mnemonic | Type | Description |
|----------|------|-------------|
| LUI   | U | Load upper immediate. |
| AUIPC | U | Add upper immediate to PC. |

## System Instructions (planned)
| Mnemonic | Type | Description |
|----------|------|-------------|
| CSRRW  | I | Read CSR and write new value. |
| CSRRS  | I | Read CSR and set bits specified in source register. |
| CSRRC  | I | Read CSR and clear bits specified in source register. |
| CSRRWI | I | Read CSR and write new value (immediate form). |
| CSRRSI | I | Read CSR and set bits specified by immediate value. |
| CSRRCI | I | Read CSR and clear bits specified by immediate value. |