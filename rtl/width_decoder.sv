`timescale 1ns / 1ps
//==============================================================//
//  Module:       width_decoder
//  File:         width_decoder.sv
//  Description:  Generates a width control signal
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//
`include "instr_macros.sv"
`include "control_macros.sv"


module width_decoder (
    // Instruction inputs
    input  logic [2:0] funct3_i,
    input  logic       width_op_i,

    // Decode outputs
    output logic [2:0] width_src_o
);

    always_comb begin
        if (width_op_i == `WIDTH_CONST) begin
            width_src_o = `WIDTH_32;  // default
        end else begin
            case (funct3_i)
                `F3_WORD: width_src_o   = `WIDTH_32;   // lw, sw
                `F3_HALF: width_src_o   = `WIDTH_16S;  // lh, sh
                `F3_BYTE: width_src_o   = `WIDTH_8S;   // lb, sb
                `F3_HALF_U: width_src_o = `WIDTH_16U;  // lhu
                `F3_BYTE_U: width_src_o = `WIDTH_8U;   // lbu
                default: width_src_o    = `WIDTH_32;  // default val
            endcase
        end
    end

endmodule