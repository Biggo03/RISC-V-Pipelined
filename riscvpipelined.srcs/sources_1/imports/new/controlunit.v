`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 09/01/2024 04:13:20 PM
// Module Name: controlunit
// Project Name: riscvpipelined
// Description: Control unit for pipelined riscv processor
// 
// Dependencies: maindecoder (maindecoder.v), ALUdecoder (ALUdecoder.v), 
//               widthdecoder (widthdecoder.v), branchdecoder (branchdecoder.v)
//
// Additional Comments: 
//            Input sources: Decode stage, Execute stage
//            Output destinations: Decode stage pipeline register, fetch stage PC multiplexer
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module controlunit(input [6:0] OpD,
                   input [2:0] funct3D, funct3E,
                   input funct7b5D,
                   input [1:0] BranchOpE,
                   input N, Z, C, V,
                   output [3:0] ALUControlD,
                   output [2:0] ImmSrcD, WidthSrcD, ResultSrcD,
                   output [1:0] BranchOpD,
                   output PCSrcE,
                   output ALUSrcD,
                   output RegWriteD, MemWriteD,
                   output PCBaseSrcD);
        
    
    //Internal control signals
    wire [1:0] ALUOp;
    wire WidthOp;
    
    //Main Decoder
    maindecoder MainDec(.op (OpD),
                        .ImmSrc (ImmSrcD),
                        .ResultSrc (ResultSrcD),
                        .ALUOp (ALUOp),
                        .BranchOp (BranchOpD),
                        .WidthOp (WidthOp),
                        .ALUSrc (ALUSrcD),
                        .PCBaseSrc (PCBaseSrcD),
                        .RegWrite (RegWriteD),
                        .MemWrite (MemWriteD));
    
    //ALU Decoder
    ALUdecoder ALUDec(.funct3 (funct3D),
                      .ALUOp (ALUOp),
                      .op5 (OpD[5]),
                      .funct7b5 (funct7b5D),
                      .ALUControl (ALUControlD));
    
    //Width Decoder
    widthdecoder WidthDec(.funct3 (funct3D),
                          .WidthOp (WidthOp),
                          .WidthSrc (WidthSrcD));     
    
    //Branch Decoder   
    branchdecoder BranchDec(.funct3 (funct3E),
                            .BranchOp (BranchOpE),
                            .N (N),
                            .Z (Z),
                            .C (C),
                            .V (V),
                            .PCSrc (PCSrcE));
        
        
endmodule   
