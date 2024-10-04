`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2024 09:48:45 PM
// Design Name: 
// Module Name: flop
// Project Name: riscvsingle
// Target Devices: 
// Tool Versions: 
// Description: This is a resettable enabled register with a base width of 32-bits
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module flop #(parameter WIDTH = 32)
             (input clk, en, reset,
              input [WIDTH-1:0] D,
              output reg [WIDTH-1:0] Q);
    
    always @(posedge clk) begin
        if (reset) Q <= 0;
        else if (en) Q <= D;
    end
    
   
endmodule
