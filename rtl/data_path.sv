`timescale 1ns / 1ps
//==============================================================//
//  Module:       data_path
//  File:         data_path.sv
//  Description:  All logic contained within the datapath
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A   
//
//  Notes:        N/A
//==============================================================//

module data_path (
    // Clock & Reset
    input  logic        clk,
    input  logic        reset,

    // Data inputs
    input  logic [31:0] InstrF,
    input  logic [31:0] ReadDataM,
    input  logic [31:0] PredPCTargetF,

    // Control inputs
    input  logic [3:0]  ALUControlD,
    input  logic [2:0]  WidthSrcD,
    input  logic [2:0]  ResultSrcD,
    input  logic [2:0]  ImmSrcD,
    input  logic [1:0]  BranchOpD,
    input  logic        MemWriteD,
    input  logic        RegWriteD,
    input  logic        ALUSrcD,
    input  logic        PCBaseSrcD,
    input  logic [1:0]  PCSrc,
    input  logic        PCSrcPredF,

    // Hazard control inputs
    input  logic [1:0]  ForwardAE,
    input  logic [1:0]  ForwardBE,
    input  logic        FlushD,
    input  logic        FlushE,
    input  logic        StallD,
    input  logic        StallF,
    input  logic        StallE,
    input  logic        StallM,
    input  logic        StallW,

    // Memory outputs
    output logic [31:0] ALUResultM,
    output logic [31:0] WriteDataM,
    output logic [31:0] PCF,
    output logic [1:0]  WidthSrcMOUT,
    output logic        MemWriteM,

    // Control unit outputs
    output logic [6:0]  OpD,
    output logic [2:0]  funct3D,
    output logic [2:0]  funct3E,
    output logic        funct7b5D,
    output logic [1:0]  BranchOpE,
    output logic        N,
    output logic        Z,
    output logic        C,
    output logic        V,

    // Branch processing outputs
    output logic [31:0] PCE,
    output logic [31:0] PCTargetE,  // Only need 10 LSBs
    output logic        PCSrcPredE,
    output logic        TargetMatchE,

    // Hazard control outputs
    output logic [4:0]  Rs1D,
    output logic [4:0]  Rs2D,
    output logic [4:0]  Rs1E,
    output logic [4:0]  Rs2E,
    output logic [4:0]  RdE,
    output logic        ResultSrcEb2,
    output logic [4:0]  RdM,
    output logic [4:0]  RdW,
    output logic        RegWriteM,
    output logic        RegWriteW
);

    // ----- Fetch stage -----
    logic [31:0] PCPlus4F;

    // ----- Decode stage -----
    logic [31:0] ImmExtD;
    logic [31:0] PCD;
    logic [31:0] PCPlus4D;
    logic [31:0] PredPCTargetD;
    logic [4:0]  RdD;
    logic        PCSrcPredD;

    // ----- Execute stage -----
    logic [31:0] ALUResultE;
    logic [31:0] WriteDataE;
    logic [31:0] PCPlus4E;
    logic [31:0] ImmExtE;
    logic [2:0]  WidthSrcE;
    logic [2:0]  ResultSrcE;
    logic        MemWriteE;
    logic        RegWriteE;

    // ----- Memory stage -----
    logic [31:0] ReducedDataM;
    logic [31:0] PCTargetM;
    logic [31:0] PCPlus4M;
    logic [31:0] ImmExtM;
    logic [31:0] ForwardDataM;
    logic [2:0]  ResultSrcM;

    // ----- Writeback stage -----
    logic [31:0] ResultW;

    // ----- Register file -----
    logic [31:0] RD1D;
    logic [31:0] RD2D;
    
    fetch_stage u_fetch_stage (
        // Clock & Reset
        .clk            (clk),
        .reset          (reset),

        // PC inputs
        .PCTargetE      (PCTargetE),
        .PCPlus4E       (PCPlus4E),
        .PredPCTargetF  (PredPCTargetF),
        .PCSrc          (PCSrc),

        // Control inputs
        .StallF         (StallF),

        // PC outputs
        .PCF            (PCF),
        .PCPlus4F       (PCPlus4F)
    );

    decode_stage u_decode_stage (
        // Clock & Reset
        .clk            (clk),
        .reset          (reset),

        // Instruction & PC inputs
        .InstrF         (InstrF),
        .PCF            (PCF),
        .PCPlus4F       (PCPlus4F),
        .PredPCTargetF  (PredPCTargetF),
        .PCSrcPredF     (PCSrcPredF),

        // Control inputs
        .ImmSrcD        (ImmSrcD),
        .StallD         (StallD),
        .FlushD         (FlushD),

        // Data outputs
        .ImmExtD        (ImmExtD),
        .PredPCTargetD  (PredPCTargetD),
        .PCD            (PCD),
        .PCPlus4D       (PCPlus4D),
        .RdD            (RdD),
        .Rs1D           (Rs1D),
        .Rs2D           (Rs2D),
        .OpD            (OpD),
        .funct3D        (funct3D),
        .funct7b5D      (funct7b5D),
        .PCSrcPredD     (PCSrcPredD)
    );

    execute_stage u_execute_stage (
        // Clock & Reset
        .clk            (clk),
        .reset          (reset),

        // Data inputs
        .RD1D           (RD1D),
        .RD2D           (RD2D),
        .ResultW        (ResultW),
        .ForwardDataM   (ForwardDataM),
        .PCD            (PCD),
        .PCPlus4D       (PCPlus4D),
        .ImmExtD        (ImmExtD),
        .PredPCTargetD  (PredPCTargetD),

        // Control inputs
        .funct3D        (funct3D),
        .RdD            (RdD),
        .Rs1D           (Rs1D),
        .Rs2D           (Rs2D),
        .ALUControlD    (ALUControlD),
        .WidthSrcD      (WidthSrcD),
        .ResultSrcD     (ResultSrcD),
        .BranchOpD      (BranchOpD),
        .RegWriteD      (RegWriteD),
        .MemWriteD      (MemWriteD),
        .PCBaseSrcD     (PCBaseSrcD),
        .ALUSrcD        (ALUSrcD),
        .ForwardAE      (ForwardAE),
        .ForwardBE      (ForwardBE),
        .FlushE         (FlushE),
        .StallE         (StallE),
        .PCSrcPredD     (PCSrcPredD),

        // Data outputs
        .ALUResultE     (ALUResultE),
        .WriteDataE     (WriteDataE),
        .PCTargetE      (PCTargetE),
        .PCPlus4E       (PCPlus4E),
        .ImmExtE        (ImmExtE),
        .PCE            (PCE),
        .Rs1E           (Rs1E),
        .Rs2E           (Rs2E),
        .RdE            (RdE),

        // Control outputs
        .funct3E        (funct3E),
        .N              (N),
        .Z              (Z),
        .C              (C),
        .V              (V),
        .WidthSrcE      (WidthSrcE),
        .ResultSrcE     (ResultSrcE),
        .BranchOpE      (BranchOpE),
        .MemWriteE      (MemWriteE),
        .RegWriteE      (RegWriteE),
        .PCSrcPredE     (PCSrcPredE),
        .TargetMatchE   (TargetMatchE)
    );
    
    //Need whole ResultSrcE signal internally, only need MSB externally
    assign ResultSrcEb2 = ResultSrcE[2];
    
    memory_stage u_memory_stage (
        // Clock & Reset
        .clk           (clk),
        .reset         (reset),

        // Data inputs
        .ALUResultE    (ALUResultE),
        .WriteDataE    (WriteDataE),
        .PCTargetE     (PCTargetE),
        .PCPlus4E      (PCPlus4E),
        .ImmExtE       (ImmExtE),
        .ReadDataM     (ReadDataM),
        .RdE           (RdE),

        // Control inputs
        .WidthSrcE     (WidthSrcE),
        .ResultSrcE    (ResultSrcE),
        .MemWriteE     (MemWriteE),
        .RegWriteE     (RegWriteE),

        // Data outputs
        .ReducedDataM  (ReducedDataM),
        .ALUResultM    (ALUResultM),
        .WriteDataM    (WriteDataM),
        .PCTargetM     (PCTargetM),
        .PCPlus4M      (PCPlus4M),
        .ImmExtM       (ImmExtM),
        .ForwardDataM  (ForwardDataM),
        .RdM           (RdM),

        // Control outputs
        .ResultSrcM    (ResultSrcM),
        .WidthSrcMOUT  (WidthSrcMOUT),
        .MemWriteM     (MemWriteM),
        .RegWriteM     (RegWriteM)
    );

    writeback_stage u_writeback_stage (
        // Clock & Reset
        .clk          (clk),
        .reset        (reset),

        // Data inputs
        .ALUResultM   (ALUResultM),
        .ReducedDataM (ReducedDataM),
        .PCTargetM    (PCTargetM),
        .PCPlus4M     (PCPlus4M),
        .ImmExtM      (ImmExtM),
        .RdM          (RdM),

        // Control inputs
        .ResultSrcM   (ResultSrcM),
        .RegWriteM    (RegWriteM),

        // Data outputs
        .ResultW      (ResultW),
        .RdW          (RdW),

        // Control outputs
        .RegWriteW    (RegWriteW)
    );

    reg_file u_reg_file (
        // Clock & Reset
        .clk   (clk),
        .reset (reset),

        // Register addresses
        .A1    (Rs1D),
        .A2    (Rs2D),
        .A3    (RdW),

        // Write port
        .WD3   (ResultW),
        .WE3   (RegWriteW),

        // Read ports
        .RD1   (RD1D),
        .RD2   (RD2D)
    );
                         
endmodule
