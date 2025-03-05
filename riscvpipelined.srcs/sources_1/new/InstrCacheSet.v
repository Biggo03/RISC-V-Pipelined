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
                       parameter NumTagBits = 20,
                       parameter E = 4)
                      (input clk, reset,
                       input ActiveSet,
                       input RepReady,
                       input [$clog2(B)-1:0] Block,
                       input [NumTagBits-1:0] Tag,
                       input [(B*8)-1:0] RepBlock,
                       output [31:0] Data,
                       output reg CacheMiss);
    
    localparam b = $clog2(B);
    localparam words = B/4;
    
    //Stored address information
    reg [NumTagBits-1:0] BlockTags [E-1:0];
    reg [E-1:0] ValidBits;
    reg [E-1:0] MatchedBlock;
    
    //Replacement policy signals
    reg [$clog2(E)-1:0] LRUBits [E-1:0]; 
    reg [$clog2(E)-1:0] LastLRUStatus;
    
    //Signal to keep track of which unfilled set is to be added next
    reg [$clog2(E)-1:0] NextFill;
    
    //Signal storing which set to is to be replaced
    reg [$clog2(E)-1:0] RepSet;
    
    //Stored data
    //Each set has an array of 32-bit words
    (* ram_style = "block" *) reg [(B*8)-1:0] SetData [E-1:0];

    
    //Block Offset calculation
    wire [b+2:0] BlockOffset; //Allows blocks to be indexed by word
    assign BlockOffset = {Block[b-1:2], 5'b0};
    
    reg [$clog2(E)-1:0] OutSet;
    
    //For looping constructs
    integer i;
    
    
    //Reset logic
    always @(posedge clk) begin
    
        if (reset) begin
            ValidBits <= 0;
            NextFill <= 0;
            LastLRUStatus = 0;
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
                    LRUBits[i] <= LRUBits[i] + 1;
                end else if (MatchedBlock[i]) begin
                    LRUBits[i] <= 0;
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
                        RepSet = i;
                        LRUBits[RepSet] <= 0;
                    end else begin
                        LRUBits[i] <= LRUBits[i] + 1;
                    end
                end
            end else begin
                RepSet = NextFill;
                LRUBits[RepSet] <= 0;
                ValidBits[RepSet] <= 1;   
                NextFill <= NextFill + 1; //Increment next set to fill
                
                //If new block being added, all other blocks in set must have their LRUBits incremented
                for (i = 0; i < E; i = i + 1) begin
                    if (i < NextFill) begin
                        LRUBits[i] <= LRUBits[i] + 1;
                    end
                end
            end
            
            SetData[RepSet] <= RepBlock;
            BlockTags[RepSet] <= Tag;
            
        end
    end
    
    //Output logic
    always @(*) begin
  
        if (ActiveSet && ~CacheMiss) begin
            for (i = 0; i < E; i = i + 1) begin
                if (MatchedBlock[i]) OutSet = i;
            end
        end
        
    end
    
    assign Data = SetData[OutSet] >> BlockOffset;
    
endmodule
