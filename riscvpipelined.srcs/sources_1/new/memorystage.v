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


module memorystage(input clk, reset,
                   //Input Data Signals
                   input [31:0] ALUResultE, WriteDataE,
                   input [31:0] PCTargetE, PCPlus4E,
                   input [31:0] ImmExtE,
                   input [31:0] ReadDataM,
                   input [4:0] RdE,
                   //Input Control Signals
                   input [2:0] WidthSrcE, ResultSrcE,
                   input MemWriteE, RegWriteE,
                   input StallM,
                   //Output Data Signals
                   output [31:0] ReducedDataM, ALUResultM, WriteDataM,
                   output [31:0] PCTargetM, PCPlus4M,
                   output [31:0] ImmExtM,
                   output [31:0] ForwardDataM,
                   output [4:0] RdM,
                   //Output Control Signals
                   output [2:0] ResultSrcM, 
                   output [1:0] WidthSrcMOUT,
                   output MemWriteM, RegWriteM);
    
    localparam REG_WIDTH = 173;
    
    //Signals for holding inputs and outputs of Memory pipeline register
    wire [REG_WIDTH-1:0] MInputs, MOutputs;
    
    //Only need two bits for output, so use internal signal for whole signal
    wire [2:0] WidthSrcM;
    
    assign MInputs = {ALUResultE, WriteDataE, PCTargetE, PCPlus4E, ImmExtE, RdE, 
                      WidthSrcE, ResultSrcE, MemWriteE, RegWriteE};
    
    flop #(.WIDTH (REG_WIDTH)) MemoryReg(.clk (clk),
                                         .en (~StallM),
                                         .reset (reset),
                                         .D (MInputs),
                                         .Q (MOutputs));
    
    assign {ALUResultM, WriteDataM, PCTargetM, PCPlus4M, ImmExtM, RdM, 
            WidthSrcM, ResultSrcM, MemWriteM, RegWriteM} = MOutputs;
    
    assign WidthSrcMOUT = WidthSrcM[1:0];
    
    mux4 ForwardMux(.d0 (ALUResultM),
                    .d1 (PCTargetM),
                    .d2 (PCPlus4M),
                    .d3 (ImmExtM),
                    .s (ResultSrcM[1:0]),
                    .y (ForwardDataM));
    
    reduce WidthChange(.BaseResult (ReadDataM),
                       .WidthSrc (WidthSrcM),
                       .Result (ReducedDataM));
    
endmodule
