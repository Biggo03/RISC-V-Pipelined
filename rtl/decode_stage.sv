`timescale 1ns / 1ps
//==============================================================//
//  Module:       decode_stage
//  File:         decode_stage.sv
//  Description:  All logic contained within the decode stage, along with its pipeline register
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module decode_stage (
    // Clock & reset_i
    input  logic        clk_i,
    input  logic        reset_i,

    // Data inputs
    input  logic [31:0] instr_f_i,
    input  logic [31:0] pc_f_i,
    input  logic [31:0] pc_plus4_f_i,
    input  logic [31:0] pred_pc_target_f_i,
    input  logic        pc_src_pred_f_i,

    // Control inputs
    input  logic [2:0]  imm_src_d_i,
    input  logic        stall_d_i,
    input  logic        flush_d_i,

    // Data outputs
    output logic [31:0] imm_ext_d_o,
    output logic [31:0] pc_d_o,
    output logic [31:0] pc_plus4_d_o,
    output logic [31:0] pred_pc_target_d_o,
    output logic [4:0]  rd_d_o,
    output logic [4:0]  rs1_d_o,
    output logic [4:0]  rs2_d_o,
    output logic [6:0]  op_d_o,
    output logic [2:0]  funct3_d_o,
    output logic [6:0]  funct7_d_o,
    output logic        pc_src_pred_d_o
);
    
    // ----- Parameters -----
    localparam REG_WIDTH = 129;

    // ----- Decode pipeline register -----
    logic [REG_WIDTH-1:0] inputs_d;
    logic [REG_WIDTH-1:0] outputs_d;
    logic                 reset_d;

    // ----- Decode stage intermediates -----
    logic [31:0] instr_d;

    assign inputs_d = {instr_f_i, pc_f_i, pc_plus4_f_i, pred_pc_target_f_i, pc_src_pred_f_i};
    assign reset_d = (reset_i | flush_d_i);
    
    flop #(
        .WIDTH                          (REG_WIDTH)
    ) u_flop_decode_reg (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset                          (reset_d),
        .en                             (~stall_d_i),

        // Data input
        .D                              (inputs_d),

        // Data output
        .Q                              (outputs_d)
    );
    
    assign {instr_d, pc_d_o, pc_plus4_d_o, pred_pc_target_d_o, pc_src_pred_d_o} = outputs_d;
    
    assign rd_d_o = instr_d[11:7];
    assign rs1_d_o = instr_d[19:15];
    assign rs2_d_o = instr_d[24:20];
    
    assign op_d_o = instr_d[6:0];
    assign funct3_d_o = instr_d[14:12];
    assign funct7_d_o[5] = instr_d[30];
    
    
    
    imm_extend u_imm_extend (
        // Instruction input
        .instr_i                        (instr_d[31:7]),

        // Control input
        .imm_src_i                      (imm_src_d_i),

        // Data output
        .imm_ext_o                      (imm_ext_d_o)
    );
    
endmodule
