module InstrCacheSetMulti #(parameter B = 64,
                       parameter NumTagBits = 20,
                       parameter E = 4)
                      (input clk, reset,
                       input ActiveSet,
                       input RepReady,
                       input [$clog2(B)-1:0] Block,
                       input [NumTagBits-1:0] Tag,
                       input [(B*8)-1:0] RepBlock,
                       output [31:0] Data,
                       output RepComplete,
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
    reg RepBegin;
    assign RepActive = CacheMiss && ActiveSet && RepReady;
    
    wire [31:0] RepBlockArray [words-1:0];
    
    //Stored data
    (* ram_style = "distributed" *) reg [31:0] SetData [(words*E)-1:0];
    
    //Block Offset calculation
    wire [$clog2(words)-1:0] BlockOffset; //Allows blocks to be indexed by word
    assign BlockOffset = Block[b-1:2];
    
    //The set number currently being output
    reg [$clog2(E)-1:0] OutSet;
    
    //For looping constructs
    integer i;
    genvar n;
    
    //Re-indexes RepBlock for easier indexing
    generate
        for (n = 0; n < words; n = n+1) begin
            assign RepBlockArray[n] = RepBlock[n << 5 +: 32];
        end
    endgenerate
    
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
    
    //Determine block to replace
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
    
    //Replacement logic, and LRU updates (Block to replace, LRU updates)
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
                        //RemovedBlock = i;
                        LRUBits[RemovedBlock] <= 0;
                    end else begin
                        LRUBits[i] <= LRUBits[i] + 1;
                    end
                end
                
            //Populate cache with data
            end else begin
                //RemovedBlock = NextFill;
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
    
    assign RepComplete = RepCounter == (words-1);
    
    //Replacement logic (storage changes)
    always @(posedge clk) begin
        if (RepActive && RepBegin) begin
            SetData[(RemovedBlock*words) + RepCounter] <= RepBlockArray[RepCounter];
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
        for (i = 0; i < E; i = i + 1) begin
            if (MatchedBlock[i]) OutSet = i;
        end 
    end
    
    assign Data = SetData[(OutSet*words) + BlockOffset];
    
endmodule