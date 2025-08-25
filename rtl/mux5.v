`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2024 09:23:44 PM
// Design Name: 
// Module Name: mux5
// Project Name: riscvsingle
// Target Devices: 
// Tool Versions: 
// Description: A 5-input mux
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux5 #(parameter WIDTH = 32)
              (input [WIDTH-1:0] d0, d1, d2, d3, d4,
               input [2:0] s,
               output [WIDTH-1:0] y);
         
    assign y = s[2] ? d4 : (s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1 : d0));
         
         
endmodule
