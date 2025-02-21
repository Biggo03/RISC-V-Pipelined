`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 02/16/2025 02:39:28 PM
// Module Name: L1InstrCache
// Project Name: riscvpipelined
// Description: A parameterized cache set module, implementing a LRU replacement policy
// 
// Dependencies:
// Additional Comments:
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module InstrCacheSet #(parameter B = 64,
                       parameter NumTagBits = 26,
                       parameter E = 4)
                      (input clk, reset,
                       input ActiveSet,
                       input RepReady,
                       input [$clog2(B)-1:0] Block,
                       input [NumTagBits-1:0] Tag,
                       input [(B*8)-1:0] RepBlock,
                       output reg [31:0] Data,
                       output reg CacheMiss);
    
    localparam b = $clog2(B);
    
    //Stored address information
    reg [NumTagBits-1:0] BlockTags [E-1:0];
    reg [E-1:0] ValidBits;
    reg [E-1:0] MatchedBlock;
    
    //Replacement policy signals
    reg [$clog2(E)-1:0] LRUBits [E-1:0]; 
    reg [$clog2(E)-1:0] LastLRUStatus;
    
    //Signal to keep track of which unfilled set is to be added next
    reg [$clog2(E)-1:0] NextFill;
    
    //Stored data
    reg [(B*8)-1:0] SetData [E-1:0];
    
    //For looping constructs
    integer i;
    
    //Reset logic
    always @(posedge clk) begin
    
        if (reset) begin
            ValidBits <= 0;
            NextFill <= 0;
            LastLRUStatus <= 0;
            for (i = 0; i < E; i = i + 1) begin
                LRUBits[i] <= 0;
            end
        end
    end
    
    //Tag and valid comparison logic
    always @(*) begin
    
        MatchedBlock = 0;
        CacheMiss = 1;
        LastLRUStatus = 0;
        
        if (ActiveSet) begin
             //Determine if a block matches
            for (i = 0; i < E; i = i + 1) begin
                if (ValidBits[i] == 1 && Tag == BlockTags[i]) begin
                    MatchedBlock[i] = 1;
                    LastLRUStatus = LRUBits[i];
                end else begin
                    MatchedBlock[i] = 0;
                end
            end
        
            //Declare a miss
            if (MatchedBlock == 0) CacheMiss = 1;
            else CacheMiss = 0;
            
        end
    end
    
    //LRUBits update logic
    always @(posedge clk) begin
    
        if (ActiveSet && ~CacheMiss) begin
            for (i = 0; i < E; i = i + 1) begin
                if (~MatchedBlock[i] && ValidBits[i] && LRUBits[i] < LastLRUStatus) begin
                    LRUBits[i] = LRUBits[i] + 1;
                end else if (MatchedBlock[i]) begin
                    LRUBits[i] = 0;
                end
            end
        end
    end
    
    //Replacement logic
    always @(posedge clk) begin
    
        if (CacheMiss && ActiveSet && RepReady) begin
            //Replace when sets full of valid data
            if (ValidBits == {E{1'b1}}) begin
                for (i = 0; i < E; i = i + 1) begin
                    if (LRUBits[i] == E-1) begin
                        SetData[i] <= RepBlock;
                        BlockTags[i] <= Tag;
                        LRUBits[i] <= 0;
                    end else begin
                        LRUBits[i] <= LRUBits[i] + 1;
                    end
                end
                            
            end else begin
                SetData[NextFill] <= RepBlock;
                ValidBits[NextFill] <= 1;
                BlockTags[NextFill] <= Tag;
                LRUBits[NextFill] <= 0;
                NextFill <= NextFill + 1;
                
                //If new block being added, all other blocks in set must have their LRUBits incremented
                for (i = 0; i < E; i = i + 1) begin
                    if (i < NextFill) begin
                        LRUBits[i] = LRUBits[i] + 1;
                    end
                end
                
            end
        end
    end
    
    //Output logic
    always @(*) begin
        
        Data = 32'bx;
  
        if (ActiveSet && ~CacheMiss) begin
            for (i = 0; i < E; i = i + 1) begin
                if (MatchedBlock[i] == 1) Data = SetData[i][{Block[b-1:2], 5'b0} +: 32]; //Include 5'b0 for proper word addressing
            end
        end
    end
    
endmodule
