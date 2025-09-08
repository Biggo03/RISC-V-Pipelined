`timescale 1ns / 1ps
//==============================================================//
//  Module:       data_path
//  File:         data_path.sv
//  Description:  All logic contained within the datapath
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A   
//
//  Notes:        N/A
//==============================================================//

module data_path (
    // Clock & reset_i
    input  logic        clk_i,
    input  logic        reset_i,

    // Data inputs
    input  logic [31:0] instr_f_i,
    input  logic [31:0] read_data_m_i,
    input  logic [31:0] pred_pc_target_f_i,

    // Control inputs
    input  logic [3:0]  alu_control_d_i,
    input  logic [2:0]  width_src_d_i,
    input  logic [2:0]  result_src_d_i,
    input  logic [2:0]  imm_src_d_i,
    input  logic [1:0]  branch_op_d_i,
    input  logic        mem_write_d_i,
    input  logic        reg_write_d_i,
    input  logic        alu_src_d_i,
    input  logic        pc_base_src_d_i,
    input  logic [1:0]  pc_src_i,
    input  logic        pc_src_pred_f_i,

    // Hazard control inputs
    input  logic [1:0]  forward_a_e_i,
    input  logic [1:0]  forward_b_e_i,
    input  logic        flush_d_i,
    input  logic        flush_e_i,
    input  logic        stall_d_i,
    input  logic        stall_f_i,
    input  logic        stall_e_i,
    input  logic        stall_m_i,
    input  logic        stall_w_i,

    // Memory outputs
    output logic [31:0] alu_result_m_o,
    output logic [31:0] write_data_m_o,
    output logic [31:0] pc_f_o,
    output logic [2:0]  width_src_m_o,
    output logic        mem_write_m_o,

    // Control unit outputs
    output logic [6:0]  op_d_o,
    output logic [2:0]  funct3_d_o,
    output logic [2:0]  funct3_e_o,
    output logic [6:0]  funct7_d_o,
    output logic [1:0]  branch_op_e_o,
    output logic        N,
    output logic        Z,
    output logic        C,
    output logic        V,

    // Branch processing outputs
    output logic [31:0] pc_e_o,
    output logic [31:0] pc_target_e_o,  // Only need 10 LSBs
    output logic        pc_src_pred_e_o,
    output logic        target_match_e_o,

    // Hazard control outputs
    output logic [4:0]  rs1_d_o,
    output logic [4:0]  rs2_d_o,
    output logic [4:0]  rs1_e_o,
    output logic [4:0]  rs2_e_o,
    output logic [4:0]  rd_e_o,
    output logic [2:0]  result_src_e_o,
    output logic [4:0]  rd_m_o,
    output logic [4:0]  rd_w_o,
    output logic        reg_write_m_o,
    output logic        reg_write_w_o
);

    // ----- Fetch stage -----
    logic [31:0] pc_plus4_f;

    // ----- Decode stage -----
    logic [31:0] imm_ext_d;
    logic [31:0] pc_d;
    logic [31:0] pc_plus4_d;
    logic [31:0] pred_pc_target_d;
    logic [4:0]  rd_d;
    logic        pc_src_pred_d;

    // ----- Execute stage -----
    logic [31:0] alu_result_e;
    logic [31:0] write_data_e;
    logic [31:0] pc_plus4_e;
    logic [31:0] imm_ext_e;
    logic [2:0]  width_src_e;
    logic        mem_write_e;
    logic        reg_write_e;

    // ----- Memory stage -----
    logic [31:0] reduced_data_m;
    logic [31:0] pc_target_m;
    logic [31:0] pc_plus4_m;
    logic [31:0] imm_ext_m;
    logic [31:0] forward_data_m;
    logic [2:0]  result_src_m;

    // ----- Writeback stage -----
    logic [31:0] result_w;

    // ----- Register file -----
    logic [31:0] rd1_d;
    logic [31:0] rd2_d;
    
    fetch_stage u_fetch_stage (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // pc inputs
        .pc_target_e_i                  (pc_target_e_o),
        .pc_plus4_e_i                   (pc_plus4_e),
        .pred_pc_target_f_i             (pred_pc_target_f_i),
        .pc_src_i                       (pc_src_i),

        // Control inputs
        .stall_f_i                      (stall_f_i),

        // pc outputs
        .pc_f_o                         (pc_f_o),
        .pc_plus4_f_o                   (pc_plus4_f)
    );

    decode_stage u_decode_stage (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Instruction & pc inputs
        .instr_f_i                      (instr_f_i),
        .pc_f_i                         (pc_f_o),
        .pc_plus4_f_i                   (pc_plus4_f),
        .pred_pc_target_f_i             (pred_pc_target_f_i),
        .pc_src_pred_f_i                (pc_src_pred_f_i),

        // Control inputs
        .imm_src_d_i                    (imm_src_d_i),
        .stall_d_i                      (stall_d_i),
        .flush_d_i                      (flush_d_i),

        // Data outputs
        .imm_ext_d_o                    (imm_ext_d),
        .pred_pc_target_d_o             (pred_pc_target_d),
        .pc_d_o                         (pc_d),
        .pc_plus4_d_o                   (pc_plus4_d),
        .rd_d_o                         (rd_d),
        .rs1_d_o                        (rs1_d_o),
        .rs2_d_o                        (rs2_d_o),
        .op_d_o                         (op_d_o),
        .funct3_d_o                     (funct3_d_o),
        .funct7_d_o                     (funct7_d_o),
        .pc_src_pred_d_o                (pc_src_pred_d)
    );

    execute_stage u_execute_stage (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Data inputs
        .rd1_d_i                        (rd1_d),
        .rd2_d_i                        (rd2_d),
        .result_w_i                     (result_w),
        .forward_data_m_i               (forward_data_m),
        .pc_d_i                         (pc_d),
        .pc_plus4_d_i                   (pc_plus4_d),
        .imm_ext_d_i                    (imm_ext_d),
        .pred_pc_target_d_i             (pred_pc_target_d),

        // Control inputs
        .funct3_d_i                     (funct3_d_o),
        .rd_d_i                         (rd_d),
        .rs1_d_i                        (rs1_d_o),
        .rs2_d_i                        (rs2_d_o),
        .alu_control_d_i                (alu_control_d_i),
        .width_src_d_i                  (width_src_d_i),
        .result_src_d_i                 (result_src_d_i),
        .branch_op_d_i                  (branch_op_d_i),
        .reg_write_d_i                  (reg_write_d_i),
        .mem_write_d_i                  (mem_write_d_i),
        .pc_base_src_d_i                (pc_base_src_d_i),
        .alu_src_d_i                    (alu_src_d_i),
        .forward_a_e_i                  (forward_a_e_i),
        .forward_b_e_i                  (forward_b_e_i),
        .flush_e_i                      (flush_e_i),
        .stall_e_i                      (stall_e_i),
        .pc_src_pred_d_i                (pc_src_pred_d),

        // Data outputs
        .alu_result_e_o                 (alu_result_e),
        .write_data_e_o                 (write_data_e),
        .pc_target_e_o                  (pc_target_e_o),
        .pc_plus4_e_o                   (pc_plus4_e),
        .imm_ext_e_o                    (imm_ext_e),
        .pc_e_o                         (pc_e_o),
        .rs1_e_o                        (rs1_e_o),
        .rs2_e_o                        (rs2_e_o),
        .rd_e_o                         (rd_e_o),

        // Control outputs
        .funct3_e_o                     (funct3_e_o),
        .N                              (N),
        .Z                              (Z),
        .C                              (C),
        .V                              (V),
        .width_src_e_o                  (width_src_e),
        .result_src_e_o                 (result_src_e_o),
        .branch_op_e_o                  (branch_op_e_o),
        .mem_write_e_o                  (mem_write_e),
        .reg_write_e_o                  (reg_write_e),
        .pc_src_pred_e_o                (pc_src_pred_e_o),
        .target_match_e_o               (target_match_e_o)
    );
    
    memory_stage u_memory_stage (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Data inputs
        .alu_result_e_i                 (alu_result_e),
        .write_data_e_i                 (write_data_e),
        .pc_target_e_i                  (pc_target_e_o),
        .pc_plus4_e_i                   (pc_plus4_e),
        .imm_ext_e_i                    (imm_ext_e),
        .read_data_m_i                  (read_data_m_i),
        .rd_e_i                         (rd_e_o),

        // Control inputs
        .width_src_e_i                  (width_src_e),
        .result_src_e_i                 (result_src_e_o),
        .mem_write_e_i                  (mem_write_e),
        .reg_write_e_i                  (reg_write_e),

        // Data outputs
        .reduced_data_m_o               (reduced_data_m),
        .alu_result_m_o                 (alu_result_m_o),
        .write_data_m_o                 (write_data_m_o),
        .pc_target_m_o                  (pc_target_m),
        .pc_plus4_m_o                   (pc_plus4_m),
        .imm_ext_m_o                    (imm_ext_m),
        .forward_data_m_o               (forward_data_m),
        .rd_m_o                         (rd_m_o),

        // Control outputs
        .result_src_m_o                 (result_src_m),
        .width_src_m_o                  (width_src_m_o),
        .mem_write_m_o                  (mem_write_m_o),
        .reg_write_m_o                  (reg_write_m_o)
    );

    writeback_stage u_writeback_stage (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Data inputs
        .alu_result_m_i                 (alu_result_m_o),
        .reduced_data_m_i               (reduced_data_m),
        .pc_target_m_i                  (pc_target_m),
        .pc_plus4_m_i                   (pc_plus4_m),
        .imm_ext_m_i                    (imm_ext_m),
        .rd_m_i                         (rd_m_o),

        // Control inputs
        .result_src_m_i                 (result_src_m),
        .reg_write_m_i                  (reg_write_m_o),

        // Data outputs
        .result_w_o                     (result_w),
        .rd_w_o                         (rd_w_o),

        // Control outputs
        .reg_write_w_o                  (reg_write_w_o)
    );

    reg_file u_reg_file (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Register addresses
        .a1_i                           (rs1_d_o),
        .a2_i                           (rs2_d_o),
        .a3_i                           (rd_w_o),

        // Write port
        .wd3_i                          (result_w),
        .we3_i                          (reg_write_w_o),

        // Read ports
        .rd1_o                          (rd1_d),
        .rd2_o                          (rd2_d)
    );
                         
endmodule
