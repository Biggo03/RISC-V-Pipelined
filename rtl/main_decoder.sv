`timescale 1ns / 1ps
//==============================================================//
//  Module:       main_decoder
//  File:         main_decoder.sv
//  Description:  Decodes opcodes and outputs associated control signals
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   WIDTH  - data width
//
//  Notes:        N/A
//==============================================================//
`include "InstrMacros.vh"

module main_decoder (
    // Instruction opcode input
    input  logic [6:0] op,

    // Decode outputs
    output logic [2:0] imm_src_o,
    output logic [2:0] result_src_o,
    output logic [1:0] alu_op_o,
    output logic [1:0] branch_op_o,
    output logic       width_op_o,
    output logic       alu_src_o,
    output logic       pc_base_src_o,
    output logic       reg_write_o,
    output logic       mem_write_o
);

    // ---- Intermediate signal ----
    logic [14:0] controls;
    
    assign {reg_write_o, imm_src_o, alu_src_o, mem_write_o,
            result_src_o, branch_op_o, alu_op_o, width_op_o, pc_base_src_o} = controls;
    
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