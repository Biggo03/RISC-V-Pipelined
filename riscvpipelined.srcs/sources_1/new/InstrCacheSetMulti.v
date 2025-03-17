//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 03/10/2025 02:39:28 PM
// Module Name: L1InstrCacheSetMulti
// Project Name: riscvpipelined
// Description: A parameterized cache set module, implementing a LRU replacement policy
//              Takes multiple cycles to complete replacement
// 
// Dependencies:
// Additional Comments: This module assumes the L2 cache can't provide data in the
//                      same cycle as a miss
//                      
//
//////////////////////////////////////////////////////////////////////////////////

module InstrCacheSetMulti #(parameter B = 64,
                       parameter NumTagBits = 20,
                       parameter E = 4)
                      (input clk, reset,
                       input ActiveSet,
                       input RepReady,
                       input [$clog2(B)-1:0] Block,
                       input [NumTagBits-1:0] Tag,
                       input [63:0] RepWord,
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
    reg [$clog2(E)-1:0] NextFill;
    reg [$clog2(E)-1:0] RemovedBlock;
    reg [$clog2(words)-1:0] RepCounter; //Need extra bit so last rep cycle runs
    wire RepActive;
    wire RepComplete;
    reg RepBegin;
    assign RepActive = CacheMiss && ActiveSet && RepReady;
    
    //Stored data
    (* ram_style = "distributed" *) reg [63:0] SetData [(words*E)/2-1:0];
    
    //Block Offset calculation
    wire [$clog2(words)-1:0] BlockOffset; //Allows blocks to be indexed by word
    assign BlockOffset = Block[b-1:3];
    
    //The set number currently being output
    reg [$clog2(E)-1:0] OutSet;
    
    //For looping constructs
    integer i;
    genvar n;
    
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
    
    //Block to remove logic
    always @(posedge clk) begin
        if (CacheMiss && ActiveSet && ~RepBegin) begin
            if (ValidBits == {E{1'b1}}) begin
                for (i = 0; i < E; i = i + 1) begin
                    if (LRUBits[i] == E-1) begin              
                        RemovedBlock <= i;
                    end 
                end
            end else begin
                RemovedBlock <= NextFill;
            end
        end
    end
    
    //LRU and ValidBit updates
    always @(posedge clk) begin
        
        //Reset logic
        if (reset) begin
            ValidBits <= 0;
            NextFill <= 0;
            RepBegin <= 0;
            for (i = 0; i < E; i = i + 1) begin
                LRUBits[i] <= 0;
            end
        
        //Handle Block Replacement LRU and ValidBit updates
        end else if (RepActive && ~RepBegin) begin
            RepBegin <= 1;
            
            //Replace when sets full of valid data
            if (ValidBits == {E{1'b1}}) begin
                for (i = 0; i < E; i = i + 1) begin
                    if (LRUBits[i] == E-1) begin              
                        LRUBits[RemovedBlock] <= 0;
                    end else begin
                        LRUBits[i] <= LRUBits[i] + 1;
                    end
                end
                
            //Populate cache with data
            end else begin
                LRUBits[RemovedBlock] <= 0;
                ValidBits[RemovedBlock] <= 1;   
                NextFill <= NextFill + 1;
                for (i = 0; i < E; i = i + 1) begin
                    if (i < NextFill) begin
                        LRUBits[i] <= LRUBits[i] + 1;
                    end
                end
            end
        
        //Handle LRU updates on non-replacing accesses
        end else  if (ActiveSet && ~CacheMiss) begin
            RepBegin <= 0;
            for (i = 0; i < E; i = i + 1) begin
                if (~MatchedBlock[i] && ValidBits[i] && LRUBits[i] < LastLRUStatus) begin
                    LRUBits[i] <= LRUBits[i] + 1;
                end else if (MatchedBlock[i]) begin
                    LRUBits[i] <= 0;
                end
            end
        end else if (RepComplete) begin
            RepBegin <= 0;
        end
    end
    
    assign RepComplete = RepCounter == (words/2)-1;
    
    //Replacement logic
    always @(posedge clk) begin
        if (RepActive) begin
            SetData[(RemovedBlock*words/2) + RepCounter] <= RepWord;
            //Replace tag and reset counter when replacement complete
            if (RepComplete) begin
                RepCounter <= 0;
                BlockTags[RemovedBlock] <= Tag;
            end else begin
                RepCounter <= RepCounter + 1;
            end
        end else begin
            RepCounter <= 0;
        end
    end
    
    //Output logic
    always @(*) begin
        if (MatchedBlock != 0) begin
            for (i = 0; i < E; i = i + 1) begin
                if (MatchedBlock[i]) OutSet = i;
            end 
        end else begin
            OutSet = 0;
        end

    end
    
    assign Data = Block[2] ? SetData[(OutSet*words)/2 + BlockOffset][63:32] : SetData[(OutSet*words)/2 + BlockOffset][31:0];
    
endmodule