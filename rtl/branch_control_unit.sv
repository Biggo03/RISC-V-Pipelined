`timescale 1ns / 1ps
//==============================================================//
//  Module:       branch_control_unit
//  File:         branch_control_unit.sv
//  Description:  Part of control unit handelling branching operations
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

module branch_control_unit (
    // Control inputs
    input  logic [1:0] op_f_i,
    input  logic       pc_src_pred_f_i,
    input  logic       pc_src_pred_e_i,
    input  logic [1:0] branch_op_e_i,
    input  logic       target_match_e_i,
    input  logic       pc_src_res_e_i,

    // Control outputs
    output logic [1:0] pc_src_o
);

    // ----- Branch resolution intermediates -----
    logic [1:0] first_stage_out;
    logic [3:0] second_stage_in;
    
    assign second_stage_in = {target_match_e_i, branch_op_e_i[0], pc_src_pred_e_i, pc_src_res_e_i};
    
    //Prediction logic
    always @(*) begin
        if (op_f_i == 2'b11 & pc_src_pred_f_i) first_stage_out = `PC_SRC_PRED_F;
        else                                   first_stage_out = `PC_SRC_SEQ_F;
    end
    
    //Rollback logic
    always @(*) begin
        casez (second_stage_in)
            4'b0111: pc_src_o = `PC_SRC_TARGET_E;
            4'b?110: pc_src_o = `PC_SRC_SEQ_E;
            4'b?101: pc_src_o = `PC_SRC_TARGET_E;
            default: pc_src_o = first_stage_out;
        endcase
    end

endmodule
