`timescale 1ns / 1ps
//==============================================================//
//  Module:       fetch_stage
//  File:         fetch_stage.sv
//  Description:  All logic contained within the fetch pipeline stage, along with its pipeline register
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module fetch_stage (
    // Clock & Reset
    input  logic        clk,
    input  logic        reset,

    // Control inputs
    input  logic [1:0]  PCSrc,
    input  logic        StallF,

    // PC inputs
    input  logic [31:0] PCTargetE,
    input  logic [31:0] PCPlus4E,
    input  logic [31:0] PredPCTargetF,

    // PC outputs
    output logic [31:0] PCF,
    output logic [31:0] PCPlus4F
);

    // ---- Intermediate signal ----
    logic [31:0] PCNextF;
    
    //PC Register logic
    mux4 u_mux4_pc (
        // Data inputs
        .d0 (PCPlus4F),
        .d1 (PredPCTargetF),
        .d2 (PCPlus4E),
        .d3 (PCTargetE),

        // Select input
        .s  (PCSrc),

        // Data output
        .y  (PCNextF)
    );
        
    flop u_pc_reg (
        // Clock & Reset
        .clk   (clk),
        .reset (reset),
        .en    (~StallF),

        // Data input
        .D     (PCNextF),

        // Data output
        .Q     (PCF)
    );

    adder u_adder_pc_plus4 (
        // Data inputs
        .a (PCF),
        .b (4),

        // Data output
        .y (PCPlus4F)
    );

endmodule
