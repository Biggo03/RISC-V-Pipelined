`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2024 12:17:34 PM
// Design Name: 
// Module Name: instrmem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Stores instructions describing a program
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instrmem(input [31:0] A,
                output [31:0] RD);
    
    //Initialize a RAM array (32-bit words, store 64 words)
    reg [31:0] RAM [127:0];
    
    //Initialize instruction memory with given file
    initial begin
    
       $readmemh("riscvprogram_7.txt", RAM);
 
    end
    
    //[31:2] as to maintain word alignment
    assign RD = RAM[A[31:2]];

endmodule
