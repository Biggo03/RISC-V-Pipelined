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
//               widthdecoder (widthdecoder.v), BranchResolutionUnit (BranchResolutionUnit.v)
//
// Additional Comments: 
//            Input sources: Decode stage, Execute stage
//            Output destinations: Decode stage pipeline register, fetch stage PC multiplexer
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module controlunit(input [6:0] OpD,
                   input [2:0] funct3D,
                   input funct7b5D,
                   //Main Decoder Outputs
                   output [2:0] ImmSrcD, ResultSrcD,
                   output [1:0] BranchOpD,
                   output ALUSrcD, PCBaseSrcD,
                   output RegWriteD, MemWriteD,
                   //ALU Decoder Output
                   output [3:0] ALUControlD,
                   //Width Decoder Output
                   output [2:0] WidthSrcD);
        
    
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
        
        
endmodule   
