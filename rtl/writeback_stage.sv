`timescale 1ns / 1ps
//==============================================================//
//  Module:       writeback_stage
//  File:         writeback_stage.sv
//  Description:  All logic contained within the memory pipeline stage and it's pipeline register
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module writeback_stage (
    // Clock & reset_i
    input  logic        clk_i,
    input  logic        reset_i,

    // Data inputs
    input  logic [31:0] alu_result_m_i,
    input  logic [31:0] reduced_data_m_i,
    input  logic [31:0] pc_target_m_i,
    input  logic [31:0] pc_plus4_m_i,
    input  logic [31:0] imm_ext_m_i,
    input  logic [4:0]  rd_m_i,

    // Control inputs
    input  logic [2:0]  result_src_m_i,
    input  logic        reg_write_m_i,
    input  logic        stall_w_i,

    // Data outputs
    output logic [31:0] result_w_o,
    output logic [4:0]  rd_w_o,

    // Control outputs
    output logic        reg_write_w_o
);

    // ----- Parameters -----
    localparam REG_WIDTH = 169;

    // ----- Writeback pipeline register -----
    logic [REG_WIDTH-1:0] inputs_w;
    logic [REG_WIDTH-1:0] outputs_w;

    // ----- Writeback stage outputs -----
    logic [31:0] imm_ext_w;
    logic [31:0] pc_plus4_w;
    logic [31:0] pc_target_w;
    logic [31:0] reduced_data_w;
    logic [31:0] alu_result_w;
    logic [2:0]  result_src_w;
    
    assign inputs_w = {alu_result_m_i, reduced_data_m_i, pc_target_m_i, pc_plus4_m_i, imm_ext_m_i, rd_m_i, result_src_m_i, reg_write_m_i};
    
    flop #(
        .WIDTH                          (REG_WIDTH)
    ) u_flop_writeback_reg (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset                          (reset_i),
        .en                             (~stall_w_i),

        // Data input
        .D                              (inputs_w),

        // Data output
        .Q                              (outputs_w)
    );
    
    assign {alu_result_w, reduced_data_w, pc_target_w, pc_plus4_w, imm_ext_w, rd_w_o, result_src_w, reg_write_w_o} = outputs_w;
    
    mux5 u_mux5_result (
        // Data inputs
        .d0                             (alu_result_w),
        .d1                             (pc_target_w),
        .d2                             (pc_plus4_w),
        .d3                             (imm_ext_w),
        .d4                             (reduced_data_w),

        // Select input
        .s                              (result_src_w),

        // Data output
        .y                              (result_w_o)
    );

endmodule
