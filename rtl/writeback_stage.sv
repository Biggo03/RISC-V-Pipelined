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
`include "control_macros.sv"

module writeback_stage (
    // Clock & reset_i
    input  logic        clk_i,
    input  logic        reset_i,

    // data inputs
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

    // data outputs
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

        // data input
        .D                              (inputs_w),

        // data output
        .Q                              (outputs_w)
    );
    
    assign {alu_result_w, reduced_data_w, pc_target_w, pc_plus4_w, imm_ext_w, rd_w_o, result_src_w, reg_write_w_o} = outputs_w;
    
    // result mux
    always_comb begin
        case (result_src_w)
            `RESULT_ALU:      result_w_o = alu_result_w;
            `RESULT_PCTARGET: result_w_o = pc_target_w;
            `RESULT_PCPLUS4:  result_w_o = pc_plus4_w;
            `RESULT_IMM_EXT:  result_w_o = imm_ext_w;
            `RESULT_MEM_DATA: result_w_o = reduced_data_w;
            default:          result_w_o = '0;
        endcase
    end

endmodule
