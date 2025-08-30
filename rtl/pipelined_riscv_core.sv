`timescale 1ns / 1ps
//==============================================================//
//  Module:       pipelined_riscv_core
//  File:         pipelined_riscv_core.sv
//  Description:  Combination of all components of pipelined riscv core
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   WIDTH  - data width
//
//  Notes:        N/A
//==============================================================//

module pipelined_riscv_core (
    // Clock & Reset
    input  logic        clk,
    input  logic        reset,

    // Instruction fetch inputs
    input  logic [31:0] InstrF,
    input  logic        InstrMissF,
    input  logic        InstrCacheRepActive,

    // Memory data inputs
    input  logic [31:0] ReadDataM,

    // PC outputs
    output logic [31:0] PCF,

    // ALU & memory outputs
    output logic [31:0] ALUResultM,
    output logic [31:0] WriteDataM,

    // Control outputs
    output logic [1:0]  WidthSrcMOUT,
    output logic [1:0]  BranchOpE,
    output logic [1:0]  PCSrcReg,
    output logic        MemWriteM
);
                      
    // ----- Control unit inputs -----
    logic [6:0] OpD;
    logic [2:0] funct3D;
    logic       funct7b5D;

    // ----- Control unit outputs -----
    logic [3:0] ALUControlD;
    logic [2:0] WidthSrcD;
    logic [2:0] ResultSrcD;
    logic [2:0] ImmSrcD;
    logic [1:0] BranchOpD;
    logic       RegWriteD;
    logic       MemWriteD;
    logic       ALUSrcD;
    logic       PCBaseSrcD;

    // ----- Hazard control unit inputs -----
    logic [4:0] Rs1D;
    logic [4:0] Rs2D;
    logic [4:0] Rs1E;
    logic [4:0] Rs2E;
    logic [4:0] RdE;
    logic       ResultSrcEb2;
    logic [4:0] RdM;
    logic [4:0] RdW;
    logic       RegWriteM;
    logic       RegWriteW;

    // ----- Hazard control unit outputs -----
    logic [1:0] ForwardAE;
    logic [1:0] ForwardBE;
    logic       StallF;
    logic       StallD;
    logic       StallE;
    logic       FlushD;
    logic       FlushE;

    // ----- Branch processing unit inputs -----
    logic       N;
    logic       Z;
    logic       C;
    logic       V;
    logic [2:0]  funct3E;
    logic [31:0] PCE; 
    logic [31:0] PCTargetE;
    logic       TargetMatchE;
    logic       PCSrcPredE;

    // ----- Branch processing unit outputs -----
    logic [31:0] PredPCTargetF;
    logic [1:0]  PCSrc;
    logic        PCSrcPredF;
    
    
    control_unit u_control_unit (
        // Instruction decode inputs
        .OpD         (OpD),
        .funct3D     (funct3D),
        .funct7b5D   (funct7b5D),

        // Control outputs
        .ALUControlD (ALUControlD),
        .ImmSrcD     (ImmSrcD),
        .WidthSrcD   (WidthSrcD),
        .ResultSrcD  (ResultSrcD),
        .BranchOpD   (BranchOpD),
        .ALUSrcD     (ALUSrcD),
        .RegWriteD   (RegWriteD),
        .MemWriteD   (MemWriteD),
        .PCBaseSrcD  (PCBaseSrcD)
    );
        
        
    hazard_unit u_hazard_unit (
        // Fetch stage inputs
        .InstrMissF           (InstrMissF),

        // Decode stage inputs
        .Rs1D                 (Rs1D),
        .Rs2D                 (Rs2D),

        // Execute stage inputs
        .Rs1E                 (Rs1E),
        .Rs2E                 (Rs2E),
        .RdE                  (RdE),
        .ResultSrcEb2         (ResultSrcEb2),
        .PCSrcb1              (PCSrc[1]),

        // Memory stage inputs
        .RdM                  (RdM),
        .RegWriteM            (RegWriteM),

        // Writeback stage inputs
        .RdW                  (RdW),
        .RegWriteW            (RegWriteW),

        // Branch predictor / cache inputs
        .PCSrcReg             (PCSrcReg),
        .InstrCacheRepActive  (InstrCacheRepActive),

        // Stall outputs
        .StallF               (StallF),
        .StallD               (StallD),
        .StallE               (StallE),
        .StallM               (StallM),
        .StallW               (StallW),

        // Flush outputs
        .FlushD               (FlushD),
        .FlushE               (FlushE),

        // Forwarding outputs
        .ForwardAE            (ForwardAE),
        .ForwardBE            (ForwardBE)
    );
        
    branch_processing_unit u_branch_processing_unit (
        // Clock & Reset
        .clk            (clk),
        .reset          (reset),

        // Status flag inputs
        .N              (N),
        .Z              (Z),
        .C              (C),
        .V              (V),

        // Pipeline control inputs
        .FlushE         (FlushE),

        // Instruction decode inputs
        .funct3E        (funct3E),
        .BranchOpE      (BranchOpE),
        .InstrF         (InstrF[6:5]),

        // PC inputs
        .PCF            (PCF[9:0]),
        .PCE            (PCE[9:0]),
        .PCTargetE      (PCTargetE),

        // Branch predictor inputs
        .TargetMatchE   (TargetMatchE),
        .PCSrcPredE     (PCSrcPredE),

        // Control outputs
        .PCSrc          (PCSrc),
        .PCSrcReg       (PCSrcReg),

        // Predictor outputs
        .PredPCTargetF  (PredPCTargetF),
        .PCSrcPredF     (PCSrcPredF)
    );

    data_path u_data_path (
        // Clock & Reset
        .clk              (clk),
        .reset            (reset),

        // Instruction fetch inputs
        .InstrF           (InstrF),
        .PredPCTargetF    (PredPCTargetF),
        .PCSrc            (PCSrc),
        .PCSrcPredF       (PCSrcPredF),

        // Memory inputs
        .ReadDataM        (ReadDataM),

        // Control inputs
        .ALUControlD      (ALUControlD),
        .WidthSrcD        (WidthSrcD),
        .ResultSrcD       (ResultSrcD),
        .ImmSrcD          (ImmSrcD),
        .BranchOpD        (BranchOpD),
        .MemWriteD        (MemWriteD),
        .RegWriteD        (RegWriteD),
        .ALUSrcD          (ALUSrcD),
        .PCBaseSrcD       (PCBaseSrcD),
        .ForwardAE        (ForwardAE),
        .ForwardBE        (ForwardBE),
        .FlushD           (FlushD),
        .FlushE           (FlushE),
        .StallD           (StallD),
        .StallF           (StallF),
        .StallE           (StallE),
        .StallM           (StallM),
        .StallW           (StallW),

        // Data outputs
        .ALUResultM       (ALUResultM),
        .WriteDataM       (WriteDataM),
        .PCF              (PCF),
        .WidthSrcMOUT     (WidthSrcMOUT),
        .MemWriteM        (MemWriteM),

        // Control outputs
        .OpD              (OpD),
        .funct3D          (funct3D),
        .funct3E          (funct3E),
        .funct7b5D        (funct7b5D),
        .BranchOpE        (BranchOpE),
        .N                (N),
        .Z                (Z),
        .C                (C),
        .V                (V),
        .PCE              (PCE),
        .PCTargetE        (PCTargetE),
        .PCSrcPredE       (PCSrcPredE),
        .TargetMatchE     (TargetMatchE),
        .Rs1D             (Rs1D),
        .Rs2D             (Rs2D),
        .Rs1E             (Rs1E),
        .Rs2E             (Rs2E),
        .RdE              (RdE),
        .ResultSrcEb2     (ResultSrcEb2),
        .RdM              (RdM),
        .RdW              (RdW),
        .RegWriteM        (RegWriteM),
        .RegWriteW        (RegWriteW)
    );

endmodule
