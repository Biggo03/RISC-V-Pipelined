`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 10/03/2024 04:31:46 PM
// Module Name: datapath
// Project Name: riscvpipelined
// Description: All logic contained within the datapath
// 
// Dependencies: fetchstage (fetchstage.v), decodestage (decodestage.v), executestage (executestage.v),
//               memorystage (memorystage.v), writebackstage (writebackstage.v) rf (rf.v),
//               all dependancies associated with these modules are also neccesary.
//
// Additional Comments: 
//            Input sources: Control unit, hazard control unit, instruction memory, data memory
//            Output destinations: Control unit, hazard control unit, instruction memory, data memory             
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module datapath(input clk, reset,
                //Input Data Signals
                input [31:0] InstrF, ReadDataM, PredPCTargetF,
                //Input Control Signals
                input [3:0] ALUControlD,
                input [2:0] WidthSrcD, ResultSrcD, ImmSrcD,
                input [1:0] BranchOpD, 
                input MemWriteD, RegWriteD,
                input ALUSrcD, PCBaseSrcD,
                input [1:0] PCSrc,
                input PCSrcPredF,
                //Input Hazard Control Signals
                input [1:0] ForwardAE, ForwardBE,
                input FlushD, FlushE,
                input StallD, StallF,
                //Output Signals (Memory)
                output [31:0] ALUResultM, WriteDataM,
                output [31:0] PCF,
                output [1:0] WidthSrcMOUT,
                output MemWriteM,
                //Output Signals (Control Unit)
                output [6:0] OpD,
                output [2:0] funct3D, funct3E,
                output funct7b5D,
                output [1:0] BranchOpE,
                output N, Z, C, V,
                //Output Signals (Branch Processing Unit)
                output [31:0] PCE, //Only need 10LSB's
                output PCSrcPredE,
                output TargetMatchE,
                //Output Data Signals (Hazard Control Unit)
                output [4:0] Rs1D, Rs2D,
                output [4:0] Rs1E, Rs2E, RdE,
                output ResultSrcEb2,
                output [4:0] RdM, RdW,
                output RegWriteM, RegWriteW);

    //Instantiation of intermediate signals:
    
    //Fetch Stage Outputs:
    wire [31:0] PCPlus4F;
    
    //Decode Stage Outputs:
    wire [31:0] ImmExtD, PCD, PCPlus4D, PredPCTargetD;
    wire [4:0] RdD;
    wire PCSrcPredD;
    
    //Execute Stage Outputs:
    wire [31:0] ALUResultE, WriteDataE, PCTargetE, PCPlus4E, ImmExtE;
    wire [2:0] WidthSrcE, ResultSrcE;
    wire MemWriteE, RegWriteE;
    
    //Memory Stage Outputs:
    wire [31:0] ReducedDataM, PCTargetM, PCPlus4M, ImmExtM, ForwardDataM;
    wire [2:0] ResultSrcM;
    
    //Writeback Stage Outputs:
    wire [31:0] ResultW;
    
    //Register File Outputs:
    wire [31:0] RD1D, RD2D;
    
    
    //Pipeline Stages
    fetchstage Fetch(.clk (clk),
                     .reset (reset),
                     .PCTargetE (PCTargetE),
                     .PCPlus4E(PCPlus4E),
                     .PredPCTargetF(PredPCTargetF),
                     .PCSrc (PCSrc),
                     .StallF (StallF),
                     .PCF (PCF),
                     .PCPlus4F (PCPlus4F));

    decodestage Decode(.clk (clk),
                       .reset (reset),
                       .InstrF (InstrF),
                       .PCF (PCF),
                       .PCPlus4F (PCPlus4F),
                       .PredPCTargetF(PredPCTargetF),
                       .PCSrcPredF(PCSrcPredF),
                       .ImmSrcD (ImmSrcD),
                       .StallD (StallD),
                       .FlushD (FlushD),
                       .ImmExtD (ImmExtD),
                       .PredPCTargetD(PredPCTargetD),
                       .PCD (PCD),
                       .PCPlus4D (PCPlus4D),
                       .RdD (RdD),
                       .Rs1D (Rs1D),
                       .Rs2D (Rs2D),
                       .OpD (OpD),
                       .funct3D (funct3D),
                       .funct7b5D (funct7b5D),
                       .PCSrcPredD(PCSrcPredD));

    executestage Execute(.clk (clk),
                         .reset (reset),
                         .RD1D (RD1D),
                         .RD2D (RD2D),
                         .ResultW (ResultW),
                         .ForwardDataM (ForwardDataM),
                         .PCD (PCD),
                         .PCPlus4D (PCPlus4D),
                         .ImmExtD (ImmExtD),
                         .PredPCTargetD (PredPCTargetD),
                         .funct3D (funct3D),
                         .RdD (RdD),
                         .Rs1D (Rs1D),
                         .Rs2D (Rs2D),
                         .ALUControlD (ALUControlD),
                         .WidthSrcD (WidthSrcD),
                         .ResultSrcD (ResultSrcD),
                         .BranchOpD (BranchOpD),
                         .RegWriteD (RegWriteD),
                         .MemWriteD (MemWriteD),
                         .PCBaseSrcD (PCBaseSrcD),
                         .ALUSrcD (ALUSrcD),
                         .ForwardAE (ForwardAE),
                         .ForwardBE (ForwardBE),
                         .FlushE (FlushE),
                         .PCSrcPredD (PCSrcPredD),
                         .ALUResultE (ALUResultE),
                         .WriteDataE (WriteDataE),
                         .PCTargetE (PCTargetE),
                         .PCPlus4E (PCPlus4E),
                         .ImmExtE (ImmExtE),
                         .PCE (PCE),
                         .Rs1E (Rs1E),
                         .Rs2E (Rs2E),
                         .RdE (RdE),
                         .funct3E (funct3E),
                         .N (N),
                         .Z (Z),
                         .C (C),
                         .V (V),
                         .WidthSrcE (WidthSrcE),
                         .ResultSrcE (ResultSrcE),
                         .BranchOpE (BranchOpE),
                         .MemWriteE (MemWriteE),
                         .RegWriteE (RegWriteE),
                         .PCSrcPredE(PCSrcPredE),
                         .TargetMatchE(TargetMatchE));
    
    //Need whole ResultSrcE signal internally, only need MSB externally
    assign ResultSrcEb2 = ResultSrcE[2];
    
    
    memorystage Memory(.clk (clk),
                       .reset (reset),
                       .ALUResultE (ALUResultE),
                       .WriteDataE (WriteDataE),
                       .PCTargetE (PCTargetE),
                       .PCPlus4E (PCPlus4E),
                       .ImmExtE (ImmExtE),
                       .ReadDataM (ReadDataM),
                       .RdE (RdE),
                       .WidthSrcE (WidthSrcE),
                       .ResultSrcE (ResultSrcE),
                       .MemWriteE (MemWriteE),
                       .RegWriteE (RegWriteE),
                       .ReducedDataM (ReducedDataM),
                       .ALUResultM (ALUResultM),
                       .WriteDataM (WriteDataM),
                       .PCTargetM (PCTargetM),
                       .PCPlus4M (PCPlus4M),
                       .ImmExtM (ImmExtM),
                       .ForwardDataM (ForwardDataM),
                       .RdM (RdM),
                       .ResultSrcM (ResultSrcM),
                       .WidthSrcMOUT (WidthSrcMOUT),
                       .MemWriteM (MemWriteM),
                       .RegWriteM (RegWriteM));

    writebackstage Writeback(.clk (clk),
                             .reset (reset),
                             .ALUResultM (ALUResultM),
                             .ReducedDataM (ReducedDataM),
                             .PCTargetM (PCTargetM),
                             .PCPlus4M (PCPlus4M),
                             .ImmExtM (ImmExtM),
                             .RdM (RdM),
                             .ResultSrcM (ResultSrcM),
                             .RegWriteM (RegWriteM),
                             .ResultW (ResultW),
                             .RdW (RdW),
                             .RegWriteW (RegWriteW));

    //Register File
    rf RegisterFile(.clk (clk),
                    .reset (reset),
                    .A1 (Rs1D),
                    .A2 (Rs2D),
                    .A3 (RdW),
                    .WD3 (ResultW),
                    .WE3 (RegWriteW),
                    .RD1 (RD1D),
                    .RD2 (RD2D));
                         
    

endmodule
