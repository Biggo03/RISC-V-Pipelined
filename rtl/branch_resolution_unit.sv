`timescale 1ns / 1ps
//==============================================================//
//  Module:       branch_resolution_unit
//  File:         branch_resolution_unit.sv
//  Description:  Resolves branch predictions. Determines if a branch occured.
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
`include "instr_macros.sv"

module branch_resolution_unit (
    // Instruction decode inputs
    input  logic [2:0] funct3_i,
    input  logic [1:0] branch_op_i,

    // Status flag inputs
    input  logic       neg_flag_i,
    input  logic       zero_flag_i,
    input  logic       carry_flag_i,
    input  logic       v_flag_i,

    // Resolution output
    output logic       pc_src_res_o
);

    always @(*) begin
        
        case(branch_op_i)
            `NON_BRANCH: pc_src_res_o = 1'b0;
            `JUMP:       pc_src_res_o = 1'b1;
            `BRANCH: begin
                case(funct3_i)
                    `F3_BEQ:  pc_src_res_o = zero_flag_i;
                    `F3_BNE:  pc_src_res_o = ~zero_flag_i;
                    `F3_BGE:  pc_src_res_o = ~(neg_flag_i^v_flag_i);
                    `F3_BGEU: pc_src_res_o = carry_flag_i;
                    `F3_BLT:  pc_src_res_o = neg_flag_i^v_flag_i;
                    `F3_BLTU: pc_src_res_o = ~carry_flag_i;
                    default:  pc_src_res_o = 1'b0;
                endcase
            end
            default: pc_src_res_o = 1'b0; //Unknown branch_op_i
        endcase
    
    end

endmodule
