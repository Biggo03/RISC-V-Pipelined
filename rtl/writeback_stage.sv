`timescale 1ns / 1ps
//==============================================================//
//  Module:       writeback_stage
//  File:         writeback_stage.sv
//  Description:  All logic contained within the memory pipeline stage and it's pipeline register
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module writeback_stage (
    // Clock & Reset
    input  logic        clk,
    input  logic        reset,

    // Data inputs
    input  logic [31:0] ALUResultM,
    input  logic [31:0] ReducedDataM,
    input  logic [31:0] PCTargetM,
    input  logic [31:0] PCPlus4M,
    input  logic [31:0] ImmExtM,
    input  logic [4:0]  RdM,

    // Control inputs
    input  logic [2:0]  ResultSrcM,
    input  logic        RegWriteM,
    input  logic        StallW,

    // Data outputs
    output logic [31:0] ResultW,
    output logic [4:0]  RdW,

    // Control outputs
    output logic        RegWriteW
);

    // ----- Parameters -----
    localparam REG_WIDTH = 169;

    // ----- Writeback pipeline register -----
    logic [REG_WIDTH-1:0] WInputs;
    logic [REG_WIDTH-1:0] WOutputs;

    // ----- Writeback stage outputs -----
    logic [31:0] ImmExtW;
    logic [31:0] PCPlus4W;
    logic [31:0] PCTargetW;
    logic [31:0] ReducedDataW;
    logic [31:0] ALUResultW;
    logic [2:0]  ResultSrcW;
    
    assign WInputs = {ALUResultM, ReducedDataM, PCTargetM, PCPlus4M, ImmExtM, RdM, ResultSrcM, RegWriteM};
    
    flop #(
        .WIDTH (REG_WIDTH)
    ) u_flop_writeback_reg (
        // Clock & Reset
        .clk   (clk),
        .reset (reset),
        .en    (~StallW),

        // Data input
        .D     (WInputs),

        // Data output
        .Q     (WOutputs)
    );
    
    assign {ALUResultW, ReducedDataW, PCTargetW, PCPlus4W, ImmExtW, RdW, ResultSrcW, RegWriteW} = WOutputs;
    
    mux5 u_mux5_result (
        // Data inputs
        .d0 (ALUResultW),
        .d1 (PCTargetW),
        .d2 (PCPlus4W),
        .d3 (ImmExtW),
        .d4 (ReducedDataW),

        // Select input
        .s  (ResultSrcW),

        // Data output
        .y  (ResultW)
    );

endmodule
