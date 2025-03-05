`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 02/14/2025 12:28:20 PM
// Module Name: L1InstrCache
// Project Name: riscvpipelined
// Description: L1 instruction cache
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
                     input RepReady,
                     input [31:0] Address,
                     input [(B*8)-1:0] RepBlock,
                     output [31:0] RD,
                     output L1IMiss);
    
    //parameters for addressing
    localparam b = $clog2(B);
    localparam s = $clog2(S);
    localparam NumTagBits = 32 - s - b;
    
    //For generating caches
    genvar i;
    
    //Different parts of address
    wire [b-1:0] Block;
    wire [s-1:0] Set;
    wire [NumTagBits-1:0] Tag;
    assign Block = Address[b-1:0];
    assign Set = Address[s+b-1:b]; 
    assign Tag = Address[31:s+b]; 
    
    //Arrays for set information
    wire [S-1:0] ActiveArray, MissArray;
    wire [31:0] DataArray [S-1:0];
    
    //Generate Sets
    generate 
        for (i = 0; i < S; i = i + 1) begin
            InstrCacheSet#(.B(B),
                           .NumTagBits(NumTagBits),
                           .E(E))
                      Set (.clk(clk),
                           .reset(reset),
                           .ActiveSet(ActiveArray[i]),
                           .RepReady(RepReady),
                           .Block(Block),
                           .Tag(Tag),
                           .RepBlock(RepBlock),
                           .Data(DataArray[i]),
                           .CacheMiss(MissArray[i]));
        end
    endgenerate
    
    //Cache Controller
    InstrCacheController#(.S(S))
              Controller (.Set(Set),
                          .MissArray(MissArray),
                          .ActiveArray(ActiveArray),
                          .CacheMiss(L1IMiss));
    
    
    //Assign output
    assign RD = DataArray[Set];

endmodule
