`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 10/01/2024 08:40:59 PM
// Module Name: memorystage
// Project Name: riscvpipelined
// Description: All logic contained within the memory pipeline stage.
// 
// Dependencies: datamem (datamem.v), reduce (reduce.v)
// Additional Comments: This is intended to interface with inputs coming from the Memory stages pipeline register
//                      and outputs being linked to the Writeback stages pipeline register
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module memorystage(input clk,
                   input [31:0] ALUResultM, WriteDataM,
                   input [2:0] WidthSrcM,
                   input MemWriteM,
                   output [31:0] ReducedDataM);

    wire [31:0] ReadDataM;

    datamem DataMemory(.clk (clk),
                       .WE (MemWriteM),
                       .WidthSrc (WidthSrcM[1:0]),
                       .A (ALUResultM),
                       .RD (ReadDataM));
    
    reduce WidthChange(.BaseResult (ReadDataM),
                       .WidthSrc (WidthSrcM),
                       .Result (ReducedDataM));
    
endmodule
