`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 08:47:04 PM
// Design Name: 
// Module Name: InstrCacheController
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


module InstrCacheController#(parameter S = 64) 
                            (input [$clog2(S)-1:0] Set,
                             input [S-1:0] MissArray,
                             output [S-1:0] ActiveArray,
                             output CacheMiss);
  
    //Length of parts of address
    localparam s = $clog2(S);
    
    //Decoding
    assign ActiveArray = 1'b1 << Set;
    assign CacheMiss = MissArray[Set];
  
endmodule
