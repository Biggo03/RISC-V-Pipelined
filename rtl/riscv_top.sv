`timescale 1ns / 1ps
//==============================================================//
//  Module:       riscv_top
//  File:         riscv_top.sv
//  Description:  Instantiation of all modules involved in the system
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module riscv_top (
    // Clock & reset_i
    input  logic        clk_i,
    input  logic        reset_i,

    // Temporary L1 instruction cache inputs
    input  logic        rep_ready_i,
    input  logic [63:0] rep_word_i,

    // Memory outputs
    output logic [31:0] write_data_m_o,
    output logic [31:0] alu_result_m_o,
    output logic        mem_write_m_o
);
    
    // ----- Pipeline signals -----
    logic [31:0] pc_f;
    logic [31:0] instr_f;
    logic [31:0] read_data_m;
    logic [2:0]  width_src_m;

    // ----- Cache control -----
    logic        instr_miss_f;
    logic        instr_cache_rep_en;

    // ----- Branch/control -----
    logic [1:0]  pc_src_reg;
    logic [1:0]  branch_op_e;
    
    
    pipelined_riscv_core u_pipelined_riscv_core (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Instruction fetch inputs
        .instr_f_i                      (instr_f),
        .instr_miss_f_i                 (instr_miss_f),
        .instr_cache_rep_en_i           (instr_cache_rep_en),

        // Memory inputs
        .read_data_m_i                  (read_data_m),

        // pc outputs
        .pc_f_o                         (pc_f),

        // ALU & memory outputs
        .alu_result_m_o                 (alu_result_m_o),
        .write_data_m_o                 (write_data_m_o),

        // Control outputs
        .width_src_m_o                  (width_src_m),
        .branch_op_e_o                  (branch_op_e),
        .pc_src_reg_o                   (pc_src_reg),
        .mem_write_m_o                  (mem_write_m_o)
    );

`ifndef NO_ICACHE
    icache_l1 #( // u_icache_l1 (
        .S                              (32),
        .E                              (4),
        .B                              (64)
    ) u_icache_l1 (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Control inputs
        .rep_ready_i                    (rep_ready_i),
        .pc_src_reg_i                   (pc_src_reg),
        .branch_op_e_i                  (branch_op_e),

        // Address & data inputs
        .pc_f_i                         (pc_f),
        .rep_word_i                     (rep_word_i),

        // Data outputs
        .instr_f_o                      (instr_f),

        // Status outputs
        .instr_miss_f_o                 (instr_miss_f),
        .instr_cache_rep_en_o           (instr_cache_rep_en)
    );
`else
    instr_mem u_instr_mem (
        // Address & data inputs
        .addr                           (pc_f),

        // Data outputs
        .rd_o                           (instr_f),

        // Status outputs
        .instr_miss_f_o                 (instr_miss_f),
        .instr_cache_rep_en_o           (instr_cache_rep_en)
    );
`endif
        
    data_mem u_data_mem (
        // Clock & control inputs
        .clk_i                          (clk_i),
        .WE                             (mem_write_m_o),
        .width_src                      (width_src_m),

        // Address & write data inputs
        .A                              (alu_result_m_o),
        .WD                             (write_data_m_o),

        // Read data output
        .RD                             (read_data_m)
    );
    
endmodule
