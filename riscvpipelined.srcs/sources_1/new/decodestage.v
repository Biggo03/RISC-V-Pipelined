`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 10/01/2024 02:55:00 PM
// Module Name: decodestage
// Project Name: riscvpipelined
// Description: All logic contained within the decode stage, along with its pipeline register
// 
// Dependencies: flop (flop.v), extend (extend.v)
// Additional Comments: 
//            Input sources: Fetch stage, Instruction memory, Hazard control unit
//            Output destinations: Memory stage pipeline register, Hazard control unit, Control unit             
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module Dstage(input clk, reset,
              input [31:0] InstrF,
              input [31:0] PCF, PCPlus4F,
              input [2:0] ImmSrcD,
              input StallD, FlushD,
              output [31:0] ImmExtD,
              output [31:0] PCD, PCPlus4D,
              output [4:0] RdD, Rs1D, Rs2D,
              output [6:0] OpD,
              output [2:0] funt3D,
              output funct7b5D);
    
    //Signals for holding inputs and outputs of Decode pipeline register
    wire [95:0] DInputs, DOutputs;
    
    assign DInputs = {InstrF, PCF, PCPlus4F};
    
    //Register should be cleared if either of flush or reset asserted
    wire DReset;
    assign DReset = (reset | FlushD);
    
    flop #(.WIDTH (96)) DecodeReg(.clk (clk),
                                 .en (~StallD),
                                 .reset (DReset),
                                 .D (DInputs),
                                 .Q (DOutputs));
     
     //InstrD not actually output, but used in determining outputs.
     wire [31:0] InstrD;
    
    //Assign all outputs of module accordingly
    assign {InstrD, PCD, PCPlus4D} = DOutputs;
    
    assign RdD = InstrD[11:7];
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    
    assign OpD = InstrD[6:0];
    assign funct3D = InstrD[14:12];
    assign funt7b5D = InstrD[30];
    
    //Extension unit
    extend ExtensionUnit(.Instr (InstrD[31:7]),
                         .ImmSrc (ImmSrcD),
                         .ImmExt (ImmExtD));
    
endmodule