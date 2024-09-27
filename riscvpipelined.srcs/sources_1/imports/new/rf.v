`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2024 09:43:28 PM
// Design Name: 
// Module Name: rf
// Project Name: riscvsingle
// Target Devices: 
// Tool Versions: 
// Description: This is a register file, holding all 32 registers used in the RISC-V architecture.
//              This module can read from two registers at a given time, and write to one register.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Note that the RISC-V registers are defined as follows:
//                      Zero Register: x0
//                      Return address: x1
//                      Stack pointer: x2
//                      Global pointer: x3
//                      Thread pointer: x4
//                      Temporary registers: x5-x7, x28-x31
//                      Saved register/Frame pointer: x8
//                      Saved registers x9, x18-x27
//                      Function arguments and return values: x10- x17
//                     
// 
//////////////////////////////////////////////////////////////////////////////////


module rf #(parameter WIDTH = 32)
           (input clk, reset,
            input [4:0] A1, A2, A3,
            input [WIDTH-1:0] WD3,
            input WE3,
            output [WIDTH-1:0] RD1, RD2);
    
    //Signals to hold the values of the created registers at all times
    wire [WIDTH-1:0] RegisterArray [31:0];
    
    //will enable writing to register that matches index of the active bit
    wire [31:0] en;
    
    //Variable used to generate registers x1-x31
    genvar i;
    
    //Initalize the registers
    
    //Zero register
    flop zero(clk, 1'b0, reset, 32'b0, RegisterArray[0]);
    
    //Use generate block and for loop to create remainder of registers
    generate
        for (i = 1; i < 32; i = i+1) begin
            flop r(clk, en[i], reset, WD3, RegisterArray[i]);
        end
    endgenerate
    
    //Reading logic   
    assign RD1 = RegisterArray[A1];
    assign RD2 = RegisterArray[A2];
    
    //Writing Logic (only need to set enable bit)
    writedecoder enabledecoder(A3, WE3, en);     
          
endmodule
