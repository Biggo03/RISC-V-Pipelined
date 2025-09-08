`timescale 1ns / 1ps
//==============================================================//
//  Module:       memory_stage
//  File:         memory_stage.sv
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

module memory_stage (
    // Clock & Reset
    input  logic        clk,
    input  logic        reset,

    // Data inputs
    input  logic [31:0] ALUResultE,
    input  logic [31:0] WriteDataE,
    input  logic [31:0] PCTargetE,
    input  logic [31:0] PCPlus4E,
    input  logic [31:0] ImmExtE,
    input  logic [31:0] ReadDataM,
    input  logic [4:0]  RdE,

    // Control inputs
    input  logic [2:0]  WidthSrcE,
    input  logic [2:0]  ResultSrcE,
    input  logic        MemWriteE,
    input  logic        RegWriteE,
    input  logic        StallM,

    // Data outputs
    output logic [31:0] ReducedDataM,
    output logic [31:0] ALUResultM,
    output logic [31:0] WriteDataM,
    output logic [31:0] PCTargetM,
    output logic [31:0] PCPlus4M,
    output logic [31:0] ImmExtM,
    output logic [31:0] ForwardDataM,
    output logic [4:0]  RdM,

    // Control outputs
    output logic [2:0]  ResultSrcM,
    output logic [2:0]  WidthSrcM,
    output logic        MemWriteM,
    output logic        RegWriteM
);
    
    // ----- Parameters -----
    localparam REG_WIDTH = 173;

    // ----- Memory pipeline register -----
    logic [REG_WIDTH-1:0] InputsM;
    logic [REG_WIDTH-1:0] OutputsM;

    // ----- Memory stage outputs -----
    logic [2:0] WidthSrcM;
    
    assign InputsM = {ALUResultE, WriteDataE, PCTargetE, PCPlus4E, ImmExtE, RdE, 
                      WidthSrcE, ResultSrcE, MemWriteE, RegWriteE};
    
    flop #(
        .WIDTH (REG_WIDTH)
    ) u_flop_memory_reg (
        // Clock & Reset
        .clk   (clk),
        .reset (reset),
        .en    (~StallM),

        // Data input
        .D     (InputsM),

        // Data output
        .Q     (OutputsM)
    );
    
    assign {ALUResultM, WriteDataM, PCTargetM, PCPlus4M, ImmExtM, RdM, 
            WidthSrcM, ResultSrcM, MemWriteM, RegWriteM} = OutputsM;
    
    mux4 u_mux4_forward (
        // Data inputs
        .d0 (ALUResultM),
        .d1 (PCTargetM),
        .d2 (PCPlus4M),
        .d3 (ImmExtM),

        // Select input
        .s  (ResultSrcM[1:0]),

        // Data output
        .y  (ForwardDataM)
    );
        
    reduce u_reduce_width_change (
        // Data input
        .BaseResult (ReadDataM),

        // Control input
        .WidthSrc   (WidthSrcM),

        // Data output
        .Result     (ReducedDataM)
    );
    
endmodule
