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
    wire [2:0] funct3D, funct3E;
    wire funct7b5D;
    wire [1:0] BranchOpE;
    wire N, Z, C, V;
    
    //Control unit outputs
    wire [3:0] ALUControlD;
    wire [2:0] WidthSrcD, ResultSrcD, ImmSrcD;
    wire [1:0] BranchOpD;
    wire RegWriteD, MemWriteD;
    wire ALUSrcD, PCBaseSrcD;
    wire PCSrcE; //Also input to hazard control unit
    
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
    
    
    controlunit CU(.OpD (OpD),
                   .funct3D (funct3D),
                   .funct3E (funct3E),
                   .funct7b5D (funct7b5D),
                   .BranchOpE (BranchOpE),
                   .N (N),
                   .Z (Z),
                   .C (C),
                   .V (V),
                   .ALUControlD (ALUControlD),
                   .ImmSrcD (ImmSrcD),
                   .WidthSrcD (WidthSrcD),
                   .ResultSrcD (ResultSrcD),
                   .BranchOpD (BranchOpD),
                   .PCSrcE (PCSrcE),
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
                      .PCSrcE (PCSrcE),
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

    datapath DP(.clk (clk),
                .reset (reset),
                .InstrF (InstrF),
                .ReadDataM (ReadDataM),
                .ALUControlD (ALUControlD),
                .WidthSrcD (WidthSrcD),
                .ResultSrcD (ResultSrcD),
                .ImmSrcD (ImmSrcD),
                .BranchOpD (BranchOpD),
                .MemWriteD (MemWriteD),
                .RegWriteD (RegWriteD),
                .ALUSrcD (ALUSrcD),
                .PCBaseSrcD (PCBaseSrcD),
                .PCSrcE (PCSrcE),
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
