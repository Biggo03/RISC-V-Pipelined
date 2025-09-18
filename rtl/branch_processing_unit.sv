`timescale 1ns / 1ps
//==============================================================//
//  Module:       branch_processing_unit
//  File:         branch_processing_unit.sv
//  Description:  Unit encapsulating all modules related to branching
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module branch_processing_unit (
        // Clock & reset_i
        input  logic        clk_i,
        input  logic        reset_i,

        // Status flag inputs
        input  logic        neg_flag_i,
        input  logic        zero_flag_i,
        input  logic        carry_flag_i,
        input  logic        v_flag_i,

        // Pipeline control inputs
        input  logic        stall_e_i,
        input  logic        flush_e_i,

        // Instruction decode inputs
        input  logic [2:0]  funct3_e_i,
        input  logic [1:0]  branch_op_e_i,
        input  logic [31:0] instr_f_i,

        // pc inputs
        input  logic [9:0]  pc_f_i,
        input  logic [9:0]  pc_e_i,
        input  logic [31:0] pc_target_e_i,

        // Branch predictor inputs
        input  logic        target_match_e_i,
        input  logic        pc_src_pred_e_i,

        // Control outputs
        output logic [1:0]  pc_src_o,
        output logic [1:0]  pc_src_reg_o,

        // Branch predictor outputs
        output logic [31:0] pred_pc_target_f_o,
        output logic        pc_src_pred_f_o
    );

    logic pc_src_res_e;
    
    branch_resolution_unit u_branch_resolution_unit (
        // Instruction decode inputs
        .funct3_i                       (funct3_e_i),
        .branch_op_i                    (branch_op_e_i),

        // Status flag inputs
        .neg_flag_i                     (neg_flag_i),
        .zero_flag_i                    (zero_flag_i),
        .carry_flag_i                   (carry_flag_i),
        .v_flag_i                       (v_flag_i),

        // Resolution output
        .pc_src_res_o                   (pc_src_res_e)
    );
    
    branch_predictor u_branch_predictor (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Pipeline control inputs
        .stall_e_i                      (stall_e_i),

        // pc inputs
        .pc_f_i                         (pc_f_i),
        .pc_e_i                         (pc_e_i),
        .pc_target_e_i                  (pc_target_e_i),

        // Branch resolution inputs
        .pc_src_res_e_i                 (pc_src_res_e),
        .target_match_e_i               (target_match_e_i),
        .branch_op_e_i                  (branch_op_e_i),

        // Predictor outputs
        .pc_src_pred_f_o                (pc_src_pred_f_o),
        .pred_pc_target_f_o             (pred_pc_target_f_o)
    );

    branch_control_unit u_branch_control_unit (
        // Instruction decode inputs
        .op_f_i                         (instr_f_i[6:5]),

        // Predictor inputs
        .pc_src_pred_f_i                (pc_src_pred_f_o),
        .pc_src_pred_e_i                (pc_src_pred_e_i),

        // Branch resolution inputs
        .branch_op_e_i                  (branch_op_e_i),
        .target_match_e_i               (target_match_e_i),
        .pc_src_res_e_i                 (pc_src_res_e),

        // Control output
        .pc_src_o                       (pc_src_o)
    );
    
    flop #(
        .WIDTH                          (2)
    ) u_src_reg (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .en                             (1'b1),
        .reset                          (reset_i | flush_e_i),

        // data_i input
        .D                              (pc_src_o),

        // data_i output
        .Q                              (pc_src_reg_o)
    );

endmodule
