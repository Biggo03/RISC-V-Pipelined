//////////////////////////////////////////////
//                 OP CODES                 //
//////////////////////////////////////////////
`define R_TYPE_OP       7'b0110011
`define I_TYPE_ALU_OP   7'b0010011
`define I_TYPE_LOAD_OP  7'b0000011
`define S_TYPE_OP       7'b0100011
`define B_TYPE_OP       7'b1100011
`define JAL_OP          7'b1101111
`define JALR_OP         7'b1100111
`define LUI_OP          7'b0110111
`define AUIPC_OP        7'b0010111
`define CSR_OP          7'b1110011

//////////////////////////////////////////////
//              FUNCT7 CODES                //
//////////////////////////////////////////////

`define FUNCT7_SUB_SRA 7'b0100000
`define FUNCT7_ADD_SRL 7'b0000000

//////////////////////////////////////////////
//              FUNCT3 CODES                //
//////////////////////////////////////////////

// BRANCHING
`define F3_BEQ      3'b000
`define F3_BNE      3'b001
`define F3_BGE      3'b101
`define F3_BGEU     3'b111
`define F3_BLT      3'b100
`define F3_BLTU     3'b110

// ALU
`define F3_ADD_SUB  3'b000
`define F3_SLL      3'b001
`define F3_SLT      3'b010
`define F3_SLTU     3'b011
`define F3_XOR      3'b100
`define F3_SRL_SRA  3'b101
`define F3_OR       3'b110
`define F3_AND      3'b111

// WIDTH
`define F3_WORD     3'b010
`define F3_HALF     3'b001
`define F3_BYTE     3'b000
`define F3_HALF_U   3'b101
`define F3_BYTE_U   3'b100

// CSR
`define F3_CSRRW    3'b001
`define F3_CSRRS    3'b010
`define F3_CSRRC    3'b110
`define F3_CSRRWI   3'b101
`define F3_CSRRSI   3'b110
`define F3_CSRRCI   3'b111

//////////////////////////////////////////////
//                   OTHER                  //
//////////////////////////////////////////////
`define NOP_INSTR 32'h00000013