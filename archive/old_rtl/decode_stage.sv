`timescale 1ns / 1ps
//==============================================================//
//  Module:       decode_stage
//  File:         decode_stage.sv
//  Description:  All logic contained within the decode stage, along with its pipeline register
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module decode_stage (
    // Clock & Reset
    input  logic        clk,
    input  logic        reset,

    // Data inputs
    input  logic [31:0] InstrF,
    input  logic [31:0] PCF,
    input  logic [31:0] PCPlus4F,
    input  logic [31:0] PredPCTargetF,
    input  logic        PCSrcPredF,

    // Control inputs
    input  logic [2:0]  ImmSrcD,
    input  logic        StallD,
    input  logic        FlushD,

    // Data outputs
    output logic [31:0] ImmExtD,
    output logic [31:0] PCD,
    output logic [31:0] PCPlus4D,
    output logic [31:0] PredPCTargetD,
    output logic [4:0]  RdD,
    output logic [4:0]  Rs1D,
    output logic [4:0]  Rs2D,
    output logic [6:0]  OpD,
    output logic [2:0]  funct3D,
    output logic [6:0]  funct7D,
    output logic        PCSrcPredD
);
    
    // ----- Parameters -----
    localparam REG_WIDTH = 129;

    // ----- Decode pipeline register -----
    logic [REG_WIDTH-1:0] InputsD;
    logic [REG_WIDTH-1:0] OutputsD;
    logic                 ResetD;

    // ----- Decode stage intermediates -----
    logic [31:0] InstrD;

    assign InputsD = {InstrF, PCF, PCPlus4F, PredPCTargetF, PCSrcPredF};
    assign ResetD = (reset | FlushD);
    
    flop #(
        .WIDTH (REG_WIDTH)
    ) u_flop_decode_reg (
        // Clock & Reset
        .clk   (clk),
        .reset (ResetD),
        .en    (~StallD),

        // Data input
        .D     (InputsD),

        // Data output
        .Q     (OutputsD)
    );
    
    assign {InstrD, PCD, PCPlus4D, PredPCTargetD, PCSrcPredD} = OutputsD;
    
    assign RdD = InstrD[11:7];
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    
    assign OpD = InstrD[6:0];
    assign funct3D = InstrD[14:12];
    assign funct7D[5] = InstrD[30];
    
    
    
    imm_extend u_imm_extend (
        // Instruction input
        .Instr   (InstrD[31:7]),

        // Control input
        .ImmSrc  (ImmSrcD),

        // Data output
        .ImmExt  (ImmExtD)
    );
    
endmodule
