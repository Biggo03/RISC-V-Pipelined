`timescale 1ns / 1ps
//==============================================================//
//  Module:       branch_processing_unit
//  File:         branch_processing_unit.sv
//  Description:  Unit encapsulating all modules related to branching
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module branch_processing_unit (
        // Clock & Reset
        input  logic        clk,
        input  logic        reset,

        // Status flag inputs
        input  logic        N,
        input  logic        Z,
        input  logic        C,
        input  logic        V,

        // Pipeline control inputs
        input  logic        StallE,
        input  logic        FlushE,

        // Instruction decode inputs
        input  logic [2:0]  funct3E,
        input  logic [1:0]  BranchOpE,
        input  logic [31:0] InstrF,

        // PC inputs
        input  logic [9:0]  PCF,
        input  logic [9:0]  PCE,
        input  logic [31:0] PCTargetE,

        // Branch predictor inputs
        input  logic        TargetMatchE,
        input  logic        PCSrcPredE,

        // Control outputs
        output logic [1:0]  PCSrc,
        output logic [1:0]  PCSrcReg,

        // Branch predictor outputs
        output logic [31:0] PredPCTargetF,
        output logic        PCSrcPredF
    );

    logic PCSrcResE;
    
    branch_resolution_unit u_branch_resolution_unit (
        // Instruction decode inputs
        .funct3     (funct3E),
        .BranchOp   (BranchOpE),

        // Status flag inputs
        .N          (N),
        .Z          (Z),
        .C          (C),
        .V          (V),

        // Resolution output
        .PCSrcRes   (PCSrcResE)
    );
    
    branch_predictor u_branch_predictor (
        // Clock & Reset
        .clk            (clk),
        .reset          (reset),

        // Pipeline control inputs
        .StallE         (StallE),

        // PC inputs
        .PCF            (PCF),
        .PCE            (PCE),
        .PCTargetE      (PCTargetE),

        // Branch resolution inputs
        .PCSrcResE      (PCSrcResE),
        .TargetMatchE   (TargetMatchE),
        .BranchOpE      (BranchOpE),

        // Predictor outputs
        .PCSrcPredF     (PCSrcPredF),
        .PredPCTargetF  (PredPCTargetF)
    );

    branch_control_unit u_branch_control_unit (
        // Instruction decode inputs
        .OpF          (InstrF[6:5]),

        // Predictor inputs
        .PCSrcPredF   (PCSrcPredF),
        .PCSrcPredE   (PCSrcPredE),

        // Branch resolution inputs
        .BranchOpE    (BranchOpE),
        .TargetMatchE (TargetMatchE),
        .PCSrcResE    (PCSrcResE),

        // Control output
        .PCSrc        (PCSrc)
    );
    
    flop #(
        .WIDTH (2)
    ) u_src_reg (
        // Clock & Reset
        .clk    (clk),
        .en     (1'b1),
        .reset  (reset | FlushE),

        // Data input
        .D      (PCSrc),

        // Data output
        .Q      (PCSrcReg)
    );

endmodule
