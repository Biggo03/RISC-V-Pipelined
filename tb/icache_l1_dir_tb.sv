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
// Additional Comments:Already tested more complex functionality at set level, will leave at ensuring basic functions work
//
//////////////////////////////////////////////////////////////////////////////////

module icache_l1_dir_tb();
    
    //Test cache parameters
    localparam S = 32;
    localparam E = 4;
    localparam B = 64;
    localparam words = B/4;
    localparam RepCycles = words/2;
    
    localparam s = $clog2(S);
    localparam b = $clog2(B);
    localparam NumTagBits = 32-s-b;
    
    //DUT signals
    logic clk, reset;
    logic RepReady;
    logic [31:0] Address, RD;
    logic [63:0] RepWord;
    logic [1:0] PCSrcReg, BranchOpE;
    logic L1IMiss;
    logic CacheRepActive;
    
    
    //Signals to make addressing more intuitive
    logic [b-1:0] ByteAddr;
    logic [s-1:0] SetNum;
    assign Address[b-1:0] = ByteAddr;
    assign Address[s+b-1:b] = SetNum;
    
    //Store blocks
    logic [(B*8)-1:0] RepBlocks [S-1:0][E-1:0];
    
    //Stores tag of each block
    logic [NumTagBits-1:0] Tags [S-1:0][E-1:0];
    
    icache_l1#(.S(S), 
                  .E(E), 
                  .B(B))
             DUT (.clk(clk),
                  .reset(reset),
                  .RepReady(RepReady),
                  .Address(Address),
                  .RepWord(RepWord),
                  .PCSrcReg(PCSrcReg),
                  .BranchOpE(BranchOpE),
                  .RD(RD),
                  .L1IMiss(L1IMiss),
                  .CacheRepActive(CacheRepActive));

    always begin
        clk = ~clk; #5;
    end
    
    initial begin

        dump_setup;

        reset = 1; clk = 0; BranchOpE = 0; PCSrcReg = 0; #100; reset = 0; 
        
        //Fill up cache and check initial reads
        for (int i = 0; i < S; i = i + 1) begin
            SetNum = i;
            ByteAddr = 0;
            for (int n = 0; n < E; n = n + 1) begin
                //Set and store unique tag for block
                Address[31:s+b] = (i * 8) + n**3;
                Tags[i][n] = Address[31:s+b];
                #10;
                RepReady = 1;
                
                //Do replacement
                for (int k = 0; k < RepCycles; k = k + 1) begin
                    if (i == 0) begin
                        RepWord[31:0] = k;
                        RepWord[63:32] = k**2;
                    end else begin
                        RepWord[31:0] = (i * 1111) * k**2 + i**2;
                        RepWord[63:32] = (i * 2222) * k**2 + i**2;
                    end 
                    
                    RepBlocks[i][n][k*64 +: 64] = RepWord;
                    #10;
                end
                RepReady = 0;
                
                //Check 
                for (int k = 0; k < words; k = k + 1) begin
                    ByteAddr = k * 4;
                    #10;
                    assert(RD === RepBlocks[i][n][k*32 +: 32] && L1IMiss === 0) else $fatal("Population Read Error");
                end
            end
        end
        
        //Reread
        for (int i = 0; i < S; i = i + 1) begin
            SetNum = i;
            Address[31:s+b] = Tags[i][0];
            #10;
            for (int n = 0; n < E; n = n + 1) begin
                for (int k = 0; k < words; k = k + 1) begin
                    ByteAddr = k * 4;
                    #10;
                    assert(RD === RepBlocks[i][n][k*32 +: 32] && L1IMiss === 0) else $fatal("Population Read Error");
                end
            end
            
        end
        
        //Now test based on branch behaviour
        
        $display("Simulation Succesful!");
        $stop;
    end
              

endmodule
