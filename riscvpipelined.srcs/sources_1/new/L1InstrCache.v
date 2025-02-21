`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 02/14/2025 12:28:20 PM
// Module Name: L1InstrCache
// Project Name: riscvpipelined
// Description: L1 instruction cache, implementing a LRU replacement policy
// 
// Dependencies:
// Additional Comments:
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module L1InstrCache#(parameter S = 64,
                     parameter E = 4,
                     parameter B = 64) 
                    (input clk, reset,
                     input [31:0] Address,
                     input [511:0] NewBlock,
                     output [31:0] RD,
                     output L1IMiss);
    
    //Portions of address
    localparam b = $clog2(B);
    localparam s = $clog2(S);
    localparam NumTagBits = 32 - s - b;
    
    //For looping statements
    integer i;
    
    //Different parts of address
    wire [b-1:0] Block;
    wire [s-1:0] Set;
    wire [NumTagBits-1:0] Tag;
    assign Block = Address[b-1:0];
    assign Set = Address[s+b-1:b]; 
    assign Tag = Address[31:s+b]; 
    
    //Storage signals
    reg [(B*8)-1:0] CacheMemory [S-1:0][E-1:0];
    reg [E-1:0] ValidBits [S-1:0];
    reg [NumTagBits-1:0] BlockTags [S-1:0][E-1:0];
    
    //Buffer to store most recently evicted block
    reg [(B*8)-1:0] ReplacementBuffer;
    
    
    //Reset logic
    always @(posedge clk) begin
        if (reset) begin
            for(i = 0; i < S; i = i + 1) begin
                ValidBits[i] = 0;
            end
        end
    end
    
    

endmodule
