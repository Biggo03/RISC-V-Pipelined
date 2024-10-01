`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 10/01/2024 02:55:00 PM
// Module Name: decodestage
// Project Name: riscvpipelined
// Description: All logic contained within the decode pipeline stage.
// 
// Dependencies: flop (flop.v), rf (rf.v), controlunit (controlunit.v), extend (extend.v)
// Additional Comments: This is intended to interface with outputs being linked to the decode
//                      stages pipeline register.
//
//////////////////////////////////////////////////////////////////////////////////


module decodestage(input clk, reset,
                   input [31:0] InstrD,
                   input [31:0] PCD, PCPlus4D,
                   input [31:0] RDw, ResultW,
                   input RegWriteW,
                   output [31:0] RD1D, RD2D,
                   output [31:0] ImmExtD,
                   //Control signals
                   output [3:0] ALUControlD,
                   output [2:0] WidthSrcD, ResultSrcD,
                   output [1:0] BranchOpD,
                   output ALUSrcD, PCBaseSrcD, RegWriteD, MemWriteD);
    
    //Control signal ImmSrcD used within module
    wire [2:0] ImmSrcD;
    
    controlunit CU(.op (InstrD[6:0]),
                   .funct3 (InstrD[14:12]),
                   .funct7b5 (InstrD[30]),
                   .ALUControl (ALUControlD),
                   .ImmSrc (ImmSrcD),
                   .WidthSrc (WidthSrcD),
                   .ResultSrc (ResultSrcD),
                   .ALUSrc (ALUSrcD),
                   .RegWrite (RegWriteD),
                   .MemWrite (MemWriteD),
                   .PCBaseSrc (PCBaseSrcD));
    
    rf RegisterFile(.clk (clk),
                    .reset (reset),
                    .A1 (InstrD[19:15]),
                    .A2 (InstrD[24:20]),
                    .A3 (RdW),
                    .WD3 (ResultW),
                    .RD1 (RD1D),
                    .RD2 (RD2D));

    extend ExtensionUnit(.Instr (InstrD[31:7]),
                         .ImmSrc (ImmSrcD),
                         .ImmExt (ImmExtD));
    
endmodule
