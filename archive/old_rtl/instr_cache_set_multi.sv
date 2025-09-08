`timescale 1ns / 1ps
//==============================================================//
//  Module:       instr_cache_set_multi
//  File:         instr_cache_set_multi.sv
//  Description:  A parameterized cache set module, implementing a LRU replacement policy
//                Takes multiple cycles to complete replacement
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   B: Size of block in bytes
//                NumTagBits: Number of tag bits
//                E: Associativity
//
//  Notes:        This module assumes the L2 cache can't provide data in the same cycle as a miss
//==============================================================//

module instr_cache_set_multi #(
    parameter int B          = 64,
    parameter int NumTagBits = 20,
    parameter int E          = 4
) (
    // Clock & Reset
    input  logic                  clk,
    input  logic                  reset,

    // Control inputs
    input  logic                  ActiveSet,
    input  logic                  RepEnable,

    // Address & data inputs
    input  logic [$clog2(B)-1:0]  Block,
    input  logic [NumTagBits-1:0] Tag,
    input  logic [63:0]           RepWord,

    // Data outputs
    output logic [31:0]           Data,
    output logic                  CacheSetMiss
);
    
    // ----- Parameters -----
    localparam b      = $clog2(B);
    localparam words  = B/4;

    // ----- Tag + validity -----
    logic [NumTagBits-1:0] BlockTags   [E-1:0];
    logic [E-1:0]          ValidBits;
    logic [E-1:0]          MatchedBlock;

    // ----- Replacement policy -----
    logic [$clog2(E)-1:0]  LRUBits      [E-1:0];
    logic [$clog2(E)-1:0]  LastLRUStatus;
    logic [$clog2(E)-1:0]  NextFill;
    logic [$clog2(E)-1:0]  RemovedBlock;
    logic [$clog2(words)-1:0] RepCounter; 
    logic                  RepActive;
    logic                  RepComplete;
    logic                  RepBegin;

    // ----- Data storage -----
    (* ram_style = "distributed" *)
    logic [63:0] SetData [(words*E)/2-1:0];

    // ----- Block addressing -----
    logic [$clog2(words)-1:0] BlockOffset;
    logic [$clog2(E)-1:0]     OutSet;

    // ----- Looping constructs -----
    integer i;
    genvar n;
    
    assign RepActive = CacheSetMiss && ActiveSet && RepEnable;

    //Tag and valid comparison logic
    always @(*) begin
    
        MatchedBlock = 0;
        CacheSetMiss = 1;
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
            if (MatchedBlock == 0) CacheSetMiss = 1;
            else CacheSetMiss = 0;
            
        end
    end
    
    //Block to remove logic
    always @(posedge clk) begin
        if (CacheSetMiss && ActiveSet && ~RepBegin) begin
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
        end else  if (ActiveSet && ~CacheSetMiss) begin
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

    assign BlockOffset = Block[b-1:3];
    assign Data = Block[2] ? SetData[(OutSet*words)/2 + BlockOffset][63:32] : SetData[(OutSet*words)/2 + BlockOffset][31:0];
    
endmodule