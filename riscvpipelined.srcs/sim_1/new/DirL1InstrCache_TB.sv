`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2025 10:13:14 PM
// Design Name: 
// Module Name: DirL1InstrCache_TB
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


module DirL1InstrCache_TB();

localparam S = 32;
localparam E = 4;
localparam B = 64;
localparam words = B/4;
localparam RepCycles = words/2;

localparam s = $clog2(S);
localparam b = $clog2(B);
localparam NumTagBits = 32-s-b;


logic clk, reset;
logic RepReady;
logic [31:0] Address, RD;
logic [63:0] RepWord;
logic L1IMiss;

//Signals to make addressing more intuitive
logic [b-1:0] ByteAddr;
logic [s-1:0] Set;
assign Address[b-1:0] = ByteAddr;
assign Address[s+b-1:b] = Set;

//Store blocks
logic [(B*8)-1:0] RepBlocks [S-1:0][E-1:0];

//Stores tag of each block
logic [NumTagBits-1:0] Tags [S-1:0][E-1:0];

    L1InstrCache#(.S(S), 
                .E(E), 
                .B(B))
            DUT (.clk(clk),
                .reset(reset),
                .RepReady(RepReady),
                .Address(Address),
                .RepWord(RepWord),
                .RD(RD),
                .L1IMiss(L1IMiss));

    always begin
        clk = ~clk; #5;
    end
    
    initial begin
        reset = 1; clk = 0; #100; reset = 0;
        
        //Fill up cache and check initial reads
        for (int i = 0; i < 32; i = i + 1) begin
            Set = i;
            ByteAddr = 0;
            for (int n = 0; n < E; n = n + 1) begin
                //Set and store unique tag for block
                Address[31:s+b] = (i * 8) + n**3;
                Tags[i][n] = Address[31:s+b];
                #10;
                RepReady = 1;
                
                //Do replacement
                for (int k = 0; k < RepCycles; k = k + 1) begin
                    if (i == 0) RepWord = k;
                    else RepWord = (i * 1111) * k**2 + i**2;
                    
                    RepBlocks[i][n][k*64 +: 64] = RepWord;
                    #10;
                end
                RepReady = 0;
                
                for (int k = 0; k < words; k = k + 1) begin
                    ByteAddr = k * 4;
                    #10;
                    assert(RD === RepBlocks[i][n][k*32 +: 32] && L1IMiss === 0) else $fatal("Read Error");
                end
            end   
        end
    end
              

endmodule
