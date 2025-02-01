`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 01/23/2025 06:54:50 PM
// Module Name: BranchPredictor
// Project Name: riscvpipelined
// Description: Combination of GHR and BranchingBuffer in order to determine branch predictions
// 
// Dependencies: GHR (GHR.v), BranchingBuffer (BranchingBuffer.v)
// Additional Comments: 
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module BranchPredictor(input clk, reset,
                       input [9:0] PCF, PCE,
                       input [31:0] PCTargetE,
                       input PCSrcResE,
                       input TargetMatchE,
                       input BranchOpEb0,
                       output PCSrcPredF,
                       output [31:0] PredPCTargetF);

    wire [1:0] LocalSrc;
    
    GHR GHR(.clk(clk),
            .reset(reset),
            .BranchOpEb0(BranchOpEb0),
            .PCSrcResE(PCSrcResE),
            .LocalSrc(LocalSrc));
            

    BranchingBuffer BB(.clk(clk),
                       .reset(reset),
                       .PCTargetE(PCTargetE),
                       .PCF(PCF),
                       .PCE(PCE),
                       .LocalSrc(LocalSrc),
                       .PCSrcResE(PCSrcResE),
                       .TargetMatch(TargetMatchE),
                       .BranchOpEb0(BranchOpEb0),
                       .PCSrcPredF(PCSrcPredF),
                       .PredPCTargetF(PredPCTargetF));

endmodule
