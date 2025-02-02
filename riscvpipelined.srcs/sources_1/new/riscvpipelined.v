`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 10/03/2024 09:05:33 PM
// Module Name: riscvpipelined
// Project Name: riscvpipelined
// Description: Combination of all smaller components of processor
// 
// Dependencies: datapath (datapath.v), controlunit (controlunit.v), hazardcontrol (hazardcontrol.v)
// Additional Comments: 
//            Input sources: Instruction memory, data memory
//            Output destinations: Instruction memory, data memory
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module riscvpipelined(input clk, reset,
                      input [31:0] InstrF, ReadDataM,
                      output [31:0] PCF, 
                      output [31:0] ALUResultM, WriteDataM,
                      output [1:0] WidthSrcMOUT,
                      output MemWriteM);
                      
    //Control unit inputs
    wire [6:0] OpD;
    wire [2:0] funct3D;
    wire funct7b5D;
    
    //Control unit outputs
    wire [3:0] ALUControlD;
    wire [2:0] WidthSrcD, ResultSrcD, ImmSrcD;
    wire [1:0] BranchOpD;
    wire RegWriteD, MemWriteD;
    wire ALUSrcD, PCBaseSrcD;
    
    //Hazard control unit inputs
    wire [4:0] Rs1D, Rs2D;
    wire [4:0] Rs1E, Rs2E, RdE;
    wire ResultSrcEb2;
    wire [4:0] RdM, RdW;
    wire RegWriteM, RegWriteW;
    
    //Hazard control unit outputs
    wire [1:0] ForwardAE, ForwardBE;
    wire StallF, StallD;
    wire FlushD, FlushE;
    
    //Branch Processing Unit Inputs:
    wire N, Z, C, V;
    wire [2:0] funct3E;
    wire [1:0] BranchOpE;
    wire [31:0] PCE; //Only need 10 LSB's
    wire [31:0] PCTargetE;
    wire TargetMatchE;
    wire PCSrcPredE;
    
    //Branch Processing Unit Outputs:
    wire [1:0] PCSrc; //MSB also input to HCU
    wire [31:0] PredPCTargetF;
    wire PCSrcPredF;
    
    
    controlunit CU(.OpD (OpD),
                   .funct3D (funct3D),
                   .funct7b5D (funct7b5D),
                   .ALUControlD (ALUControlD),
                   .ImmSrcD (ImmSrcD),
                   .WidthSrcD (WidthSrcD),
                   .ResultSrcD (ResultSrcD),
                   .BranchOpD (BranchOpD),
                   .ALUSrcD (ALUSrcD),
                   .RegWriteD (RegWriteD),
                   .MemWriteD (MemWriteD),
                   .PCBaseSrcD (PCBaseSrcD));
    
    
    hazardcontrol HCU(.Rs1D (Rs1D),
                      .Rs2D (Rs2D),
                      .Rs1E (Rs1E),
                      .Rs2E (Rs2E),
                      .RdE (RdE),
                      .ResultSrcEb2 (ResultSrcEb2),
                      .PCSrcb1 (PCSrc[1]),
                      .RdM (RdM),
                      .RegWriteM (RegWriteM),
                      .RdW (RdW),
                      .RegWriteW (RegWriteW),
                      .StallF (StallF),
                      .StallD (StallD),
                      .FlushD (FlushD),
                      .FlushE (FlushE),
                      .ForwardAE (ForwardAE),
                      .ForwardBE (ForwardBE));
    
    BranchProcessingUnit BPU(.clk(clk),
                             .reset(reset),
                             .N(N),
                             .Z(Z),
                             .C(C),
                             .V(V),
                             .funct3E(funct3E),
                             .BranchOpE(BranchOpE),
                             .InstrF(InstrF[6:5]),
                             .PCF(PCF[9:0]),
                             .PCE(PCE[9:0]),
                             .PCTargetE(PCTargetE),
                             .TargetMatchE(TargetMatchE),
                             .PCSrcPredE(PCSrcPredE),
                             //Outputs
                             .PCSrc(PCSrc),
                             .PredPCTargetF(PredPCTargetF),
                             .PCSrcPredF(PCSrcPredF));

    datapath DP(.clk (clk),
                .reset (reset),
                .InstrF (InstrF),
                .ReadDataM (ReadDataM),
                .PredPCTargetF(PredPCTargetF),
                .ALUControlD (ALUControlD),
                .WidthSrcD (WidthSrcD),
                .ResultSrcD (ResultSrcD),
                .ImmSrcD (ImmSrcD),
                .BranchOpD (BranchOpD),
                .MemWriteD (MemWriteD),
                .RegWriteD (RegWriteD),
                .ALUSrcD (ALUSrcD),
                .PCBaseSrcD (PCBaseSrcD),
                .PCSrc (PCSrc),
                .PCSrcPredF(PCSrcPredF),
                .ForwardAE (ForwardAE),
                .ForwardBE (ForwardBE),
                .FlushD (FlushD),
                .FlushE (FlushE),
                .StallD (StallD),
                .StallF (StallF),
                .ALUResultM (ALUResultM),
                .WriteDataM (WriteDataM),
                .PCF (PCF),
                .WidthSrcMOUT (WidthSrcMOUT),
                .MemWriteM (MemWriteM),
                .OpD (OpD),
                .funct3D (funct3D),
                .funct3E (funct3E),
                .funct7b5D (funct7b5D),
                .BranchOpE (BranchOpE),
                .N (N),
                .Z (Z),
                .C (C),
                .V (V),
                .PCE(PCE),
                .PCSrcPredE(PCSrcPredE),
                .TargetMatchE(TargetMatchE),
                .Rs1D (Rs1D),
                .Rs2D (Rs2D),
                .Rs1E (Rs1E),
                .Rs2E (Rs2E),
                .RdE (RdE),
                .ResultSrcEb2 (ResultSrcEb2),
                .RdM (RdM),
                .RdW (RdW),
                .RegWriteM (RegWriteM),
                .RegWriteW (RegWriteW));

endmodule
