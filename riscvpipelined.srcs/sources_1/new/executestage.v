`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 10/01/2024 06:53:44 PM
// Module Name: executestage
// Project Name: riscvpipelined
// Description: All logic contained within the Execute pipeline stage, along with its pipeline register.
// 
// Dependencies: mux3 (mux3.v), mux2 (mux2.v), ALU (ALU.v), adder (adder.v)
// Additional Comments: 
//            Input sources: Decode stage, Hazard control unit
//            Output destinations: Memory stage pipeline register, Hazard control unit, Control unit
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module executestage(//Input Data Signals
                    input clk, reset,
                    input [31:0] RD1D, RD2D,
                    input [31:0] ResultW, ForwardDataM,
                    input [31:0] PCD, PCPlus4D,
                    input [31:0] ImmExtD,
                    input [2:0] funct3D,
                    input [4:0] RdD, Rs1D, Rs2D,
                    //Input Control Signals
                    input [3:0] ALUControlD,
                    input [2:0] WidthSrcD, ResultSrcD,
                    input [1:0] BranchOpD,
                    input  RegWriteD, MemWriteD,
                    input PCBaseSrcD, ALUSrcD,
                    input [1:0] ForwardAE, ForwardBE,
                    input FlushE,
                    //Output Data Signals
                    output [31:0] ALUResultE, WriteDataE,
                    output [31:0] PCTargetE, PCPlus4E,
                    output [31:0] ImmExtE,
                    output [4:0] Rs1E, Rs2E, RdE,
                    output [2:0] funct3E,
                    output N, Z, C, V,
                    //Output Control Signals
                    output [2:0] WidthSrcE, ResultSrcE,
                    output [1:0] BranchOpE,
                    output MemWriteE, RegWriteE);
     
     localparam REG_WIDTH = 194;
                    
    //Signals for holding inputs and outputs of Execute pipeline register
    wire [REG_WIDTH-1:0] EInputs, EOutputs;
    
    assign EInputs = {BranchOpD, WidthSrcD, ResultSrcD, MemWriteD, ALUControlD, PCBaseSrcD, ALUSrcD, RegWriteD,
                      funct3D, RD1D, RD2D, PCD, RdD, ImmExtD, Rs1D, Rs2D, PCPlus4D};
                      
    wire EReset;
    
    assign EReset = (reset | FlushE);
    
    flop #(.WIDTH (REG_WIDTH)) ExecuteReg(.clk (clk),
                                          .en (1'b1),
                                          .reset (EReset),
                                          .D (EInputs),
                                          .Q (EOutputs));
    
    //Intermediate signals from pipeline register
    wire [31:0] RD1E, RD2E, PCE;
    wire [3:0] ALUControlE;
    wire PCBaseSrcE, ALUSrcE;
    
    assign {BranchOpE, WidthSrcE, ResultSrcE, MemWriteE, ALUControlE, PCBaseSrcE, ALUSrcE, RegWriteE,
                                        funct3E, RD1E, RD2E, PCE, RdE, ImmExtE, Rs1E, Rs2E, PCPlus4E} = EOutputs;
    
    
    //Inputs for ALU and PCTarget adder
    wire [31:0] SrcAE, SrcBE, PCBaseE;
   
    //Stage multiplexers:
    mux3 ForwardMuxA(.d0 (RD1E),
                     .d1 (ResultW),
                     .d2 (ForwardDataM),
                     .s (ForwardAE),
                     .y (SrcAE));
    
    mux3 ForwardMuxB(.d0 (RD2E),
                     .d1 (ResultW),
                     .d2 (ForwardDataM),
                     .s (ForwardBE),
                     .y (WriteDataE));
    
    mux2 SrcBMux(.d0 (WriteDataE),
                 .d1 (ImmExtE),
                 .s (ALUSrcE),
                 .y (SrcBE));
    
    mux2 PCTargetMux(.d0 (PCE),
                     .d1 (SrcAE),
                     .s (PCBaseSrcE),
                     .y (PCBaseE));
    
    //Arithmetic units:
    ALU ALU(.ALUControl (ALUControlE),
            .A (SrcAE),
            .B (SrcBE),
            .ALUResult (ALUResultE),
            .N (N),
            .Z (Z),
            .C (C),
            .V (V));
            
    adder PCTargetAdder(.a (PCBaseE),
                        .b (ImmExtE),
                        .y (PCTargetE)); 

endmodule
