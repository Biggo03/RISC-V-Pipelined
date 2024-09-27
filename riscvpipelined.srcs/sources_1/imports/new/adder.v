`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2024 08:32:57 PM
// Design Name: 
// Module Name: adder
// Project Name: riscvsingle
// Target Devices: 
// Tool Versions: 
// Description: Adds two 32-bit inputs, a and b.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adder #(parameter WIDTH = 32)
              (input [WIDTH-1:0] a, b,
               output [WIDTH-1:0] y);
    
    assign y = a + b;
    
endmodule
