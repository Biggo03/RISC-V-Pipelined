`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 01/31/2025 06:53:44 PM
// Module Name: BranchControlUnit
// Project Name: riscvpipelined
// Description: Unit encapsulating all modules related to branching
// 
// Dependencies: 
// Additional Comments: 
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module BranchProcessingUnit(input clk, reset,
                            input N, Z, C, V,
                            input [2:0] funct3E,
                            input [1:0] BranchOpE,
                            input [6:5] InstrF,
                            input [9:0] PCF, PCE,
                            input [31:0] PCTargetE,
                            input TargetMatchE,
                            input PCSrcPredE,
                            output [1:0] PCSrc,
                            output [31:0] PredPCTargetF,
                            output PCSrcPredF);

    wire PCSrcResE;
    
    BranchResolutionUnit BRU(.funct3(funct3E),
                             .BranchOp(BranchOpE),
                             .N(N), 
                             .Z(Z), 
                             .C(C), 
                             .V(V),
                             .PCSrcRes(PCSrcResE));
    
    BranchPredictor BP(.clk(clk),
                       .reset(reset),
                       .PCF(PCF),
                       .PCE(PCE),
                       .PCTargetE(PCTargetE),
                       .PCSrcResE(PCSrcResE),
                       .TargetMatchE(TargetMatchE),
                       .BranchOpEb0(BranchOpE[0]),
                       .PCSrcPredF(PCSrcPredF),
                       .PredPCTargetF(PredPCTargetF));

    BranchControlUnit BCU(.OpF(InstrF[6:5]),
                          .PCSrcPredF(PCSrcPredF),
                          .PCSrcPredE(PCSrcPredE),
                          .BranchOpEb0(BranchOpE[0]),
                          .TargetMatchE(TargetMatchE),
                          .PCSrcResE(PCSrcResE),
                          .PCSrc(PCSrc));


endmodule
