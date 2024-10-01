`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2024 04:13:20 PM
// Design Name: 
// Module Name: controlunit
// Project Name: riscvsingle
// Target Devices: 
// Tool Versions: 
// Description: Combines the various decoders used for generating control signals into one unit.
//              Outputs all control signals used in the data path.
// 
// Dependencies: maindecoder.v, ALUdecoder.v, branchdecoder.v, and widthdecoder.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module controlunit(input [6:0] op,
                   input [2:0] funct3,
                   input funct7b5,
                   output [3:0] ALUControl,
                   output [2:0] ImmSrc, WidthSrc, ResultSrc,
                   output ALUSrc,
                   output RegWrite, MemWrite,
                   output PCBaseSrc);
        
    
    //Internal control signals
    wire [1:0] ALUOp, BranchOp;
    wire WidthOp;
    
    //Main Decoder
    maindecoder MainDec(op, ImmSrc, ResultSrc, ALUOp, BranchOp, WidthOp, ALUSrc, PCBaseSrc, RegWrite, MemWrite);
    
    //ALU Decoder
    ALUdecoder ALUDec(funct3, ALUOp, op[5], funct7b5, ALUControl);
    
    //Width Decoder
    widthdecoder WidthDec(funct3, WidthOp, WidthSrc);        
        
        
        
endmodule   
