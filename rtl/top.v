`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 10/03/2024 10:01:18 PM
// Module Name: top
// Project Name: riscvpipelined
// Description: Instantiation of all modules involved in the system
// 
// Dependencies: riscvpipelined (riscvpipelined.v), instrmem (instrmem.v), datamem (datamem.v)
// Additional Comments: 
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module top(input clk, reset,
           //Temp L1 instruction cache inputs
           input RepReady,
           input [63:0] RepWord,
           //
           output [31:0] WriteDataM,
           output [31:0] DataAdr,
           output MemWriteM);
    
    wire [31:0] PCF, InstrF, ReadDataM;
    wire [1:0] WidthSrcMOUT;
    
    //Cache Related Signals
    wire InstrMissF;
    wire InstrCacheRepActive;
    wire [1:0] PCSrcReg;
    wire [1:0] BranchOpE;
    
    
    riscvpipelined rvpipelined(.clk (clk),
                               .reset (reset),
                               .InstrF (InstrF),
                               .ReadDataM (ReadDataM),
                               .InstrMissF(InstrMissF),
                               .InstrCacheRepActive(InstrCacheRepActive),
                               .PCF (PCF),
                               .ALUResultM (DataAdr),
                               .WriteDataM (WriteDataM),
                               .WidthSrcMOUT (WidthSrcMOUT),
                               .BranchOpE(BranchOpE),
                               .PCSrcReg(PCSrcReg),
                               .MemWriteM (MemWriteM));

    L1InstrCache#(.S(32),
                  .E(4),
                  .B(64))
      InstrCache (.clk(clk),
                  .reset(reset),
                  .RepReady(RepReady),
                  .Address(PCF),
                  .RepWord(RepWord),
                  .PCSrcReg(PCSrcReg),
                  .BranchOpE(BranchOpE),
                  .RD(InstrF),
                  .L1IMiss(InstrMissF),
                  .CacheRepActive(InstrCacheRepActive));
    
    datamem dmem(.clk (clk),
                 .WE (MemWriteM),
                 .WidthSrc (WidthSrcMOUT),
                 .A (DataAdr),
                 .WD (WriteDataM),
                 .RD (ReadDataM));
    
    

endmodule
