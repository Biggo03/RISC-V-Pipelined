`timescale 1ns / 1ps
//==============================================================//
//  Module:       branch_predictor
//  File:         branch_predictor.sv
//  Description:  Combination of GHR and BranchingBuffer in order to determine branch predictions
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module branch_predictor (
    // Clock & Reset
    input  logic        clk,
    input  logic        reset,

    // Pipeline control inputs
    input  logic        StallE,

    // PC inputs
    input  logic [9:0]  PCF,
    input  logic [9:0]  PCE,
    input  logic [31:0] PCTargetE,

    // Branch resolution inputs
    input  logic        PCSrcResE,
    input  logic        TargetMatchE,
    input  logic        BranchOpEb0,

    // Predictor outputs
    output logic        PCSrcPredF,
    output logic [31:0] PredPCTargetF
);

    // ---- Control signal ----
    logic [1:0] LocalSrc;
    
    ghr u_ghr (
        // Clock & Reset
        .clk         (clk),
        .reset       (reset),

        // Control inputs
        .StallE      (StallE),
        .BranchOpEb0 (BranchOpEb0),
        .PCSrcResE   (PCSrcResE),

        // Control output
        .LocalSrc    (LocalSrc)
    );
                

    branching_buffer u_branching_buffer (
        // Clock & Reset
        .clk            (clk),
        .reset          (reset),

        // PC & control inputs
        .PCTargetE      (PCTargetE),
        .PCF            (PCF),
        .PCE            (PCE),
        .LocalSrc       (LocalSrc),
        .PCSrcResE      (PCSrcResE),
        .TargetMatch    (TargetMatchE),
        .BranchOpEb0    (BranchOpEb0),

        // Control outputs
        .PCSrcPredF     (PCSrcPredF),
        .PredPCTargetF  (PredPCTargetF)
    );

endmodule
