`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2024 09:21:16 PM
// Design Name: 
// Module Name: mux2
// Project Name: riscvsingle
// Target Devices: 
// Tool Versions: 
// Description: A two-input mux
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux2 #(parameter WIDTH = 32)
        (input [WIDTH-1:0] d0, d1,
         input s,
         output [WIDTH-1:0] y);
            
    assign y = s ? d1 : d0;
        
endmodule
