`timescale 1ns / 1ps
//==============================================================//
//  Module:       pipelined_riscv_core
//  File:         pipelined_riscv_core.sv
//  Description:  Combination of all components of pipelined riscv core
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   WIDTH  - data width
//
//  Notes:        N/A
//==============================================================//

module pipelined_riscv_core (
    // Clock & reset_i
    input  logic        clk_i,
    input  logic        reset_i,

    // Instruction fetch inputs
    input  logic [31:0] instr_f_i,
    input  logic        instr_hit_f_i,
    input  logic        ic_repl_permit_i,

    // Memory data inputs
    input  logic [31:0] read_data_m_i,

    // pc outputs
    output logic [31:0] pc_f_o,

    // ALU & memory outputs
    output logic [31:0] alu_result_m_o,
    output logic [31:0] write_data_m_o,

    // Control outputs
    output logic [2:0]  width_src_m_o,
    output logic [1:0]  branch_op_e_o,
    output logic [1:0]  pc_src_reg_o,
    output logic        mem_write_m_o
);
                      
    // ----- Control unit inputs -----
    logic [6:0] op_d;
    logic [2:0] funct3_d;
    logic [6:0] funct7_d;

    // ----- Control unit outputs -----
    logic [3:0] alu_control_d;
    logic [2:0] width_src_d;
    logic [2:0] result_src_d;
    logic [2:0] imm_src_d;
    logic [1:0] branch_op_d;
    logic       reg_write_d;
    logic       mem_write_d;
    logic       alu_src_d;
    logic       pc_base_src_d;

    // ----- Hazard control unit inputs -----
    logic [4:0] rs1_d;
    logic [4:0] rs2_d;
    logic [4:0] rs1_e;
    logic [4:0] rs2_e;
    logic [4:0] rd_e;
    logic [2:0] result_src_e;
    logic [4:0] rd_m;
    logic [4:0] rd_w;
    logic       reg_write_m;
    logic       reg_write_w;

    // ----- Hazard control unit outputs -----
    logic [1:0] forward_a_e;
    logic [1:0] forward_b_e;
    logic       stall_f;
    logic       stall_d;
    logic       stall_e;
    logic       flush_d;
    logic       flush_e;

    // ----- Branch processing unit inputs -----
    logic        neg_flag;
    logic        zero_flag;
    logic        carry_flag;
    logic        v_flag;
    logic [2:0]  funct3_e;
    logic [31:0] pc_e; 
    logic [31:0] pc_target_e;
    logic        target_match_e;
    logic        pc_src_pred_e;

    // ----- Branch processing unit outputs -----
    logic [31:0] pred_pc_target_f;
    logic [1:0]  pc_src;
    logic        pc_src_pred_f;
    
    
    control_unit u_control_unit (
        // Instruction decode inputs
        .op_d_i                         (op_d),
        .funct3_d_i                     (funct3_d),
        .funct7_d_i                     (funct7_d),

        // Control outputs
        .alu_control_d_o                (alu_control_d),
        .imm_src_d_o                    (imm_src_d),
        .width_src_d_o                  (width_src_d),
        .result_src_d_o                 (result_src_d),
        .branch_op_d_o                  (branch_op_d),
        .alu_src_d_o                    (alu_src_d),
        .reg_write_d_o                  (reg_write_d),
        .mem_write_d_o                  (mem_write_d),
        .pc_base_src_d_o                (pc_base_src_d)
    );
        
        
    hazard_unit u_hazard_unit (
        // Fetch stage inputs
        .instr_hit_f_i                 (instr_hit_f_i),

        // Decode stage inputs
        .rs1_d_i                        (rs1_d),
        .rs2_d_i                        (rs2_d),

        // Execute stage inputs
        .rs1_e_i                        (rs1_e),
        .rs2_e_i                        (rs2_e),
        .rd_e_i                         (rd_e),
        .result_src_e_i                 (result_src_e),
        .pc_src_i                       (pc_src),

        // Memory stage inputs
        .rd_m_i                         (rd_m),
        .reg_write_m_i                  (reg_write_m),

        // Writeback stage inputs
        .rd_w_i                         (rd_w),
        .reg_write_w_i                  (reg_write_w),

        // Branch predictor / cache inputs
        .pc_src_reg_i                   (pc_src_reg_o),
        .ic_repl_permit_i               (ic_repl_permit_i),

        // stall outputs
        .stall_f_o                      (stall_f),
        .stall_d_o                      (stall_d),
        .stall_e_o                      (stall_e),
        .stall_m_o                      (stall_m),
        .stall_w_o                      (stall_w),

        // flush outputs
        .flush_d_o                      (flush_d),
        .flush_e_o                      (flush_e),

        // Forwarding outputs
        .forward_a_e_o                  (forward_a_e),
        .forward_b_e_o                  (forward_b_e)
    );
        
    branch_processing_unit u_branch_processing_unit (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Status flag inputs
        .neg_flag_i                     (neg_flag),
        .zero_flag_i                    (zero_flag),
        .carry_flag_i                   (carry_flag),
        .v_flag_i                       (v_flag),

        // Pipeline control inputs
        .flush_e_i                      (flush_e),

        // Instruction decode inputs
        .funct3_e_i                     (funct3_e),
        .branch_op_e_i                  (branch_op_e_o),
        .instr_f_i                      (instr_f_i),

        // pc inputs
        .pc_f_i                         (pc_f_o[9:0]),
        .pc_e_i                         (pc_e[9:0]),
        .pc_target_e_i                  (pc_target_e),

        // Branch predictor inputs
        .target_match_e_i               (target_match_e),
        .pc_src_pred_e_i                (pc_src_pred_e),

        // Control outputs
        .pc_src_o                       (pc_src),
        .pc_src_reg_o                   (pc_src_reg_o),

        // Predictor outputs
        .pred_pc_target_f_o             (pred_pc_target_f),
        .pc_src_pred_f_o                (pc_src_pred_f)
    );

    data_path u_data_path (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Instruction fetch inputs
        .instr_f_i                      (instr_f_i),
        .pred_pc_target_f_i             (pred_pc_target_f),
        .pc_src_i                       (pc_src),
        .pc_src_pred_f_i                (pc_src_pred_f),

        // Memory inputs
        .read_data_m_i                  (read_data_m_i),

        // Control inputs
        .alu_control_d_i                (alu_control_d),
        .width_src_d_i                  (width_src_d),
        .result_src_d_i                 (result_src_d),
        .imm_src_d_i                    (imm_src_d),
        .branch_op_d_i                  (branch_op_d),
        .mem_write_d_i                  (mem_write_d),
        .reg_write_d_i                  (reg_write_d),
        .alu_src_d_i                    (alu_src_d),
        .pc_base_src_d_i                (pc_base_src_d),
        .forward_a_e_i                  (forward_a_e),
        .forward_b_e_i                  (forward_b_e),
        .flush_d_i                      (flush_d),
        .flush_e_i                      (flush_e),
        .stall_d_i                      (stall_d),
        .stall_f_i                      (stall_f),
        .stall_e_i                      (stall_e),
        .stall_m_i                      (stall_m),
        .stall_w_i                      (stall_w),

        // data outputs
        .alu_result_m_o                 (alu_result_m_o),
        .write_data_m_o                 (write_data_m_o),
        .pc_f_o                         (pc_f_o),
        .width_src_m_o                  (width_src_m_o),
        .mem_write_m_o                  (mem_write_m_o),

        // Control outputs
        .op_d_o                         (op_d),
        .funct3_d_o                     (funct3_d),
        .funct3_e_o                     (funct3_e),
        .funct7_d_o                     (funct7_d),
        .branch_op_e_o                  (branch_op_e_o),
        .neg_flag_o                     (neg_flag),
        .zero_flag_o                    (zero_flag),
        .carry_flag_o                   (carry_flag),
        .v_flag_o                       (v_flag),
        .pc_e_o                         (pc_e),
        .pc_target_e_o                  (pc_target_e),
        .pc_src_pred_e_o                (pc_src_pred_e),
        .target_match_e_o               (target_match_e),
        .rs1_d_o                        (rs1_d),
        .rs2_d_o                        (rs2_d),
        .rs1_e_o                        (rs1_e),
        .rs2_e_o                        (rs2_e),
        .rd_e_o                         (rd_e),
        .result_src_e_o                 (result_src_e),
        .rd_m_o                         (rd_m),
        .rd_w_o                         (rd_w),
        .reg_write_m_o                  (reg_write_m),
        .reg_write_w_o                  (reg_write_w)
    );

endmodule
