//////////////////////////////////////////////
//                 OP CODES                 //
//////////////////////////////////////////////
`define R_TYPE_OP 7'b0110011
`define I_TYPE_ALU_OP 7'b0010011
`define I_TYPE_LOAD_OP 7'b0000011
`define S_TYPE_OP 7'b0100011
`define B_TYPE_OP 7'b1100011
`define JAL_OP 7'b1101111
`define JALR_OP 7'b1100111
`define LUI_OP 7'b0110111
`define AUIPC_OP 7'b0010111

//////////////////////////////////////////////
//             CONTROL SIGNALS              //
//////////////////////////////////////////////

//RegWrite
`define WRITE_REG 1'b1
`define NO_WRITE_REG 1'b0

//ImmSrc
`define I_EXT 3'b000
`define S_EXT 3'b001
`define B_EXT 3'b010
`define J_EXT 3'b011
`define U_EXT 3'b100
`define DONT_CARE_EXT 3'bx

//ALUSrc UPDATE
`define ALU_SRC_WD 1'b0
`define ALU_SRC_IMM 1'b1
`define ALU_SRC_DONT_CARE 1'bx

//MemWrite
`define WRITE_MEM 1'b1
`define NO_WRITE_MEM 1'b0

//ResultSrc UPDATE
`define RESULT_ALU 3'b000
`define RESULT_PCTARGET 3'b001
`define RESULT_PCPLUS4 3'b010
`define RESULT_IM_EXT 3'b011
`define RESULT_MEM_DATA 3'b100
`define RESULT_NA 3'b0xx

//BranchOp
`define NON_BRANCH 2'b00
`define JUMP 2'b01
`define BRANCH 2'b11

//ALUOp UPDATE
`define ALU_OP_ADD 2'b00
`define ALU_OP_SUB 2'b01
`define ALU_OP_PROCESS 2'b10
`define ALU_OP_DONT_CARE 2'bxx

//ALUControl
`define ALU_SRL 4'b0000
`define ALU_SRA 4'b0001
`define ALU_AND 4'b0010
`define ALU_OR 4'b0011
`define ALU_XOR 4'b0100
`define ALU_SLT 4'b0101
`define ALU_SLTU 4'b0110
`define ALU_SLL 4'b0111
`define ALU_ADD 4'b1000
`define ALU_SUB 4'b1001

//WidthOp UPDATE
`define WIDTH_CONST 1'b0
`define WIDTH_PROCESS 1'b1
`define WIDTH_DONT_CARE 1'bx

//WidthSrc
`define WIDTH_32 3'b000
`define WIDTH_16S 3'b010
`define WIDTH_16U 3'b110
`define WIDTH_8S 3'b001
`define WIDTH_8U 3'b101

//PCBaseSRC //UPDATE
`define PC_BASE_PC 1'b0
`define PC_BASE_SRCA 1'b1
`define PC_BASE_DONT_CARE 1'bx

