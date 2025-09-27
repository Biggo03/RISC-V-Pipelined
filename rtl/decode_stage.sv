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
    output logic [31:0] instr_d_o,
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
    output logic        pc_src_pred_d_o,

    // Control outputs
    output logic        valid_d_o
);
    
    // ----- Pipeline data type -----
    typedef struct packed {
        logic        valid;
        logic [31:0] instr;
        logic [31:0] pc;
        logic [31:0] pc_plus4;
        logic [31:0] pred_pc_target;
        logic        pc_src_pred;
    } decode_signals_t;


    // ----- Parameters -----
    localparam REG_WIDTH = $bits(decode_signals_t);

    // ----- Decode pipeline register -----
    decode_signals_t  inputs_d;
    decode_signals_t  outputs_d;

    assign inputs_d = {
        1'b1,
        instr_f_i,
        pc_f_i,
        pc_plus4_f_i,
        pred_pc_target_f_i,
        pc_src_pred_f_i
    };
    
    flop #(
        .WIDTH                          (REG_WIDTH)
    ) u_flop_decode_reg (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset                          (reset_i | flush_d_i),
        .en                             (~stall_d_i),

        // data input
        .D                              (inputs_d),

        // data output
        .Q                              (outputs_d)
    );
    
    assign {
        valid_d_o,
        instr_d_o,
        pc_d_o,
        pc_plus4_d_o,
        pred_pc_target_d_o,
        pc_src_pred_d_o
    } = outputs_d;
    
    assign rd_d_o = instr_d_o[11:7];
    assign rs1_d_o = instr_d_o[19:15];
    assign rs2_d_o = instr_d_o[24:20];
    
    assign op_d_o = instr_d_o[6:0];
    assign funct3_d_o = instr_d_o[14:12];
    assign funct7_d_o[5] = instr_d_o[30];
    
    imm_extend u_imm_extend (
        // Instruction input
        .instr_i                        (instr_d_o[31:7]),

        // Control input
        .imm_src_i                      (imm_src_d_i),

        // data output
        .imm_ext_o                      (imm_ext_d_o)
    );
    
endmodule
