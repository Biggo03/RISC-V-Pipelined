`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 10/01/2024 08:40:59 PM
// Module Name: memorystage
// Project Name: riscvpipelined
// Description: All logic contained within the memory pipeline stage.
// 
// Dependencies: flop (flop.v), reduce (reduce.v)
// Additional Comments: 
//            Input sources: Execute stage, Hazard control unit
//            Output destinations: Writeback stage pipeline register, Hazard control unit
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module Mstage(input clk, reset,
              //Input Data Signals
              input [31:0] ALUResultE, WriteDataE,
              input [31:0] PCTargetE, PCPlus4E,
              input [31:0] ImmExtE,
              input [31:0] ReadDataM,
              input [4:0] RdE,
              //Input Control Signals
              input [2:0] WidthSrcE, ResultSrcE,
              input MemWriteE, RegWriteE,
              //Output Data Signals
              output [31:0] ReducedDataM, ALUResultM, WriteDataM,
              output [31:0] PCTargetM, PCPlus4M,
              output [31:0] ImmExtM,
              output [4:0] RdM,
              //Output Control Signals
              output [2:0] ResultSrcM, WidthSrcM,
              output MemWriteM, RegWriteM);
    
    localparam REG_WIDTH = 173;
    
    //Signals for holding inputs and outputs of Memory pipeline register
    wire [REG_WIDTH-1:0] MInputs, MOutputs;
    
    assign MInputs = {ALUResultE, WriteDataE, PCTargetE, PCPlus4E, ImmExtE, RdE, 
                      WidthSrcE, ResultSrcE, MemWriteE, RegWriteE};
    
    flop #(.WIDTH (REG_WIDTH)) MemoryReg(.clk (clk),
                                         .en (1'b1),
                                         .reset (reset),
                                         .D (MInputs),
                                         .Q (MOutputs));
    
    assign {ALUResultM, WriteDataM, PCTargetM, PCPlus4M, ImmExtM, RdM, 
            WidthSrcM, ResultSrcM, MemWriteM, RegWriteM} = MOutputs;
    
    reduce WidthChange(.BaseResult (ReadDataM),
                       .WidthSrc (WidthSrcM),
                       .Result (ReducedDataM));
    
endmodule
