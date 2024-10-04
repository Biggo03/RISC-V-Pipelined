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
           output [31:0] WriteDataM,
           output [31:0] DataAdr,
           output MemWriteM);
    
    (* keep = "true" *) wire [31:0] PCF, InstrF, ReadDataM;
    (* keep = "true" *) wire [1:0] WidthSrcMOUT;
    
    riscvpipelined rvpipelined(.clk (clk),
                               .reset (reset),
                               .InstrF (InstrF),
                               .ReadDataM (ReadDataM),
                               .PCF (PCF),
                               .ALUResultM (DataAdr),
                               .WriteDataM (WriteDataM),
                               .WidthSrcMOUT (WidthSrcMOUT),
                               .MemWriteM (MemWriteM));

    instrmem imem(.A (PCF),
                  .RD (InstrF));
    
    datamem dmem(.clk (clk),
                 .WE (MemWriteM),
                 .WidthSrc (WidthSrcMOUT),
                 .A (DataAdr),
                 .WD (WriteDataM),
                 .RD (ReadDataM));
    
    

endmodule
