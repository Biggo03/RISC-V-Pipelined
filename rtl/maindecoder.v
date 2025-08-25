`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2024 04:12:05 PM
// Design Name: 
// Module Name: maindecoder
// Project Name: riscvsingle
// Target Devices: 
// Tool Versions: 
// Description: Deocodes the given opcode and outputs a majority of control signals
//              additional decoding done by the ALUdecoder
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "InstrMacros.vh"

module maindecoder(input [6:0] op,
                   output [2:0] ImmSrc, ResultSrc,
                   output [1:0] ALUOp, BranchOp,
                   output WidthOp,
                   output ALUSrc, PCBaseSrc,
                   output RegWrite, MemWrite);


    reg [14:0] controls;
    
    assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
            ResultSrc, BranchOp, ALUOp, WidthOp, PCBaseSrc} = controls;
    
    always @(*) begin
    
        case(op)
        //RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_BranchOp_ALUOp_WidthOp_PCBaseSrc
            
            `R_TYPE_OP: controls = {`WRITE_REG, `DONT_CARE_EXT, `ALU_SRC_WD, `NO_WRITE_MEM, `RESULT_ALU, `NON_BRANCH, `ALU_OP_PROCESS, `WIDTH_CONST, `PC_BASE_DONT_CARE};
            `I_TYPE_ALU_OP: controls = {`WRITE_REG, `I_EXT, `ALU_SRC_IMM, `NO_WRITE_MEM, `RESULT_ALU, `NON_BRANCH, `ALU_OP_PROCESS, `WIDTH_CONST, `PC_BASE_DONT_CARE}; //I-Type ALU Instructions
            `I_TYPE_LOAD_OP: controls = {`WRITE_REG, `I_EXT, `ALU_SRC_IMM, `NO_WRITE_MEM, `RESULT_MEM_DATA, `NON_BRANCH, `ALU_OP_ADD, `WIDTH_PROCESS, `PC_BASE_DONT_CARE}; //I-Type Load Instructions
            `S_TYPE_OP: controls = {`NO_WRITE_REG, `S_EXT, `ALU_SRC_IMM, `WRITE_MEM, `RESULT_NA, `NON_BRANCH, `ALU_OP_ADD, `WIDTH_PROCESS, `PC_BASE_DONT_CARE}; //S-Type Instructions
            `B_TYPE_OP: controls = {`NO_WRITE_REG, `B_EXT, `ALU_SRC_WD, `NO_WRITE_MEM, `RESULT_NA, `BRANCH, `ALU_OP_SUB, `WIDTH_DONT_CARE, `PC_BASE_PC}; //B-Type Instructions
            `JAL_OP: controls = {`WRITE_REG, `J_EXT, `ALU_SRC_DONT_CARE, `NO_WRITE_MEM, `RESULT_PCPLUS4, `JUMP, `ALU_OP_DONT_CARE, `WIDTH_CONST, `PC_BASE_PC}; //jal
            `JALR_OP: controls = {`WRITE_REG, `I_EXT, `ALU_SRC_DONT_CARE, `NO_WRITE_MEM, `RESULT_PCPLUS4, `JUMP, `ALU_OP_DONT_CARE, `WIDTH_CONST, `PC_BASE_SRCA}; //jalr
            `LUI_OP: controls = {`WRITE_REG, `U_EXT, `ALU_SRC_DONT_CARE, `NO_WRITE_MEM, `RESULT_IM_EXT, `NON_BRANCH, `ALU_OP_DONT_CARE, `WIDTH_CONST, `PC_BASE_DONT_CARE}; //lui
            `AUIPC_OP: controls = {`WRITE_REG, `U_EXT, `ALU_SRC_DONT_CARE, `NO_WRITE_MEM, `RESULT_PCTARGET, `NON_BRANCH, `ALU_OP_DONT_CARE, `WIDTH_CONST, `PC_BASE_PC}; //auipc
            default: controls = 15'b0; //Unknown opcode
            
        endcase
    
    end                   

endmodule