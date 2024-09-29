`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/03/2024 07:02:32 PM
// Design Name: 
// Module Name: datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module datapath(input clk, reset,
                input [3:0] ALUControl,
                input [2:0] ImmSrc, WidthSrc, ResultSrc,
                input ALUSrc,
                input RegWrite,
                input PCSrc, PCBaseSrc,
                input [31:0] instr,
                input [31:0] ReadData,
                output [31:0] WriteData,
                output [31:0] PC,
                output [31:0] ALUResult,
                output N, Z, C, V);
                
    
    //Signals used within the datapath
    wire [31:0] PCNext, PCPlus4, PCBase, PCTarget;
    wire [31:0] ImmExt;
    wire [31:0] SrcA, SrcB; 
    wire [31:0] ReducedData;
    wire [31:0] Result;         
    
    //PCNext Logic
    adder PCadd4(PC, 4, PCPlus4);
    
    mux2 PCtargetmux(PC, SrcA, PCBaseSrc, PCBase);
    adder PCaddtarget(PCBase, ImmExt, PCTarget);
    
    mux2 PCmux(PCPlus4, PCTarget, PCSrc, PCNext);
    flop PCreg(clk, 1'b1, reset, PCNext, PC);
    
    
    //Register File Logic
    rf RegisterFile(clk, reset, instr[19:15], instr[24:20], instr[11:7], Result, RegWrite, SrcA, WriteData);
    extend Extend(instr[31:7], ImmSrc, ImmExt);
    
    
    //ALU Logic
    mux2 ALUmux(WriteData, ImmExt, ALUSrc, SrcB);
    ALU ALU(ALUControl, SrcA, SrcB, ALUResult, N, Z, C, V);
    
    reduce Reduce(ReadData, WidthSrc, ReducedData);
    mux5 Resultmux(ALUResult, PCTarget, PCPlus4, ImmExt, ReducedData, ResultSrc, Result);
               
                
                
endmodule



