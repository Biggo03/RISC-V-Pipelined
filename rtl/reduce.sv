`timescale 1ns / 1ps
//==============================================================//
//  Module:       reduce
//  File:         reduce.sv
//  Description:  Reduction unit to reduce the effective width of data retrieved from memory.
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

module reduce (
    // data inputs
    input  logic [31:0] BaseResult,

    // Control inputs
    input  logic [2:0]  width_src_i,

    // data outputs
    output logic [31:0] result_o
);
    
    always @(*) begin
        case(width_src_i)
            `WIDTH_32:  result_o = BaseResult;
            `WIDTH_16S: result_o = {{16{BaseResult[15]}}, BaseResult[15:0]};
            `WIDTH_16U: result_o = {16'b0, BaseResult[15:0]};
            `WIDTH_8S:  result_o = {{24{BaseResult[7]}}, BaseResult[7:0]};
            `WIDTH_8U:  result_o = {24'b0, BaseResult[7:0]};
            default:    result_o = 32'bx;
        endcase
    
    end
    
endmodule