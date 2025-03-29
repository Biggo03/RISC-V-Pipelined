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
                            (input clk, reset,
                             input [$clog2(S)-1:0] Set,
                             input [S-1:0] MissArray,
                             input [1:0] PCSrcReg,
                             input [1:0] BranchOpE,
                             output [S-1:0] ActiveArray,
                             output CacheMiss,
                             output CacheRepActive);
    
    reg DelayApplied;
    
    //Decoding input set
    assign ActiveArray = 1'b1 << Set;
    assign CacheMiss = MissArray[Set];
    
    //Signal determining if replacement active
    assign CacheRepActive = ~(BranchOpE[0] & CacheMiss & (~DelayApplied)) & ~PCSrcReg[1]; //Must route proper signals
    
    //Replacement state machine logic
    always @(posedge clk) begin
        if (reset) begin
            DelayApplied <= 0;
        end else if (~DelayApplied & ~CacheRepActive) begin
            DelayApplied <= 1'b1;
        end else if (DelayApplied & (~CacheMiss | PCSrcReg[1])) begin
            DelayApplied <= 0;
        end
    end
  
endmodule
