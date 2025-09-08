`timescale 1ns / 1ps
//==============================================================//
//  Module:       memory_stage
//  File:         memory_stage.sv
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

module memory_stage (
    // Clock & reset_i
    input  logic        clk_i,
    input  logic        reset_i,

    // Data inputs
    input  logic [31:0] alu_result_e_i,
    input  logic [31:0] write_data_e_i,
    input  logic [31:0] pc_target_e_i,
    input  logic [31:0] pc_plus4_e_i,
    input  logic [31:0] imm_ext_e_i,
    input  logic [31:0] read_data_m_i,
    input  logic [4:0]  rd_e_i,

    // Control inputs
    input  logic [2:0]  width_src_e_i,
    input  logic [2:0]  result_src_e_i,
    input  logic        mem_write_e_i,
    input  logic        reg_write_e_i,
    input  logic        stall_m_i,

    // Data outputs
    output logic [31:0] reduced_data_m_o,
    output logic [31:0] alu_result_m_o,
    output logic [31:0] write_data_m_o,
    output logic [31:0] pc_target_m_o,
    output logic [31:0] pc_plus4_m_o,
    output logic [31:0] imm_ext_m_o,
    output logic [31:0] forward_data_m_o,
    output logic [4:0]  rd_m_o,

    // Control outputs
    output logic [2:0]  result_src_m_o,
    output logic [2:0]  width_src_m_o,
    output logic        mem_write_m_o,
    output logic        reg_write_m_o
);
    
    // ----- Parameters -----
    localparam REG_WIDTH = 173;

    // ----- Memory pipeline register -----
    logic [REG_WIDTH-1:0] inputs_m;
    logic [REG_WIDTH-1:0] outputs_m;
    
    assign inputs_m = {alu_result_e_i, write_data_e_i, pc_target_e_i, pc_plus4_e_i, imm_ext_e_i, rd_e_i, 
                      width_src_e_i, result_src_e_i, mem_write_e_i, reg_write_e_i};
    
    flop #(
        .WIDTH                          (REG_WIDTH)
    ) u_flop_memory_reg (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset                          (reset_i),
        .en                             (~stall_m_i),

        // Data input
        .D                              (inputs_m),

        // Data output
        .Q                              (outputs_m)
    );
    
    assign {alu_result_m_o, write_data_m_o, pc_target_m_o, pc_plus4_m_o, imm_ext_m_o, rd_m_o, 
            width_src_m_o, result_src_m_o, mem_write_m_o, reg_write_m_o} = outputs_m;
    
    mux4 u_mux4_forward (
        // Data inputs
        .d0                             (alu_result_m_o),
        .d1                             (pc_target_m_o),
        .d2                             (pc_plus4_m_o),
        .d3                             (imm_ext_m_o),

        // Select input
        .s                              (result_src_m_o[1:0]),

        // Data output
        .y                              (forward_data_m_o)
    );
        
    reduce u_reduce_width_change (
        // Data input
        .BaseResult                     (read_data_m_i),

        // Control input
        .width_src_i                    (width_src_m_o),

        // Data output
        .result_o                       (reduced_data_m_o)
    );
    
endmodule
