`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2024 07:26:18 PM
// Design Name: 
// Module Name: mux3
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


module mux3 #(parameter WIDTH = 32)
        (input [WIDTH-1:0] d0, d1, d2,
         input [1:0] s,
         output [WIDTH-1:0] y);

    assign y = s[1] ? d2 : (s[0] ? d1 : d0);
    
endmodule
