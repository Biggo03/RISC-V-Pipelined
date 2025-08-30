`timescale 1ns / 1ps
//==============================================================//
//  Module:       instr_cache_set
//  File:         instr_cache_set.sv
//  Description:  A parameterized cache set module, implementing a LRU replacement policy
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   B  - Size of block in bytes
//                NumTagBits - Number of tag bits
//                E - Associativity
//
//  Notes:        N/A
//==============================================================//

module instr_cache_set #(
    parameter int B           = 64,
    parameter int NumTagBits  = 20,
    parameter int E           = 4
) (
    // Clock & Reset
    input  logic                      clk,
    input  logic                      reset,

    // Control inputs
    input  logic                      ActiveSet,
    input  logic                      RepReady,

    // Address & data inputs
    input  logic [$clog2(B)-1:0]      Block,
    input  logic [NumTagBits-1:0]     Tag,
    input  logic [(B*8)-1:0]          RepBlock,

    // Data outputs
    output logic [31:0]               Data,
    output logic                      CacheMiss
);
    
    // ----- Parameters -----
    localparam b = $clog2(B);
    localparam words = B/4;
    
    // ----- Tag + validity -----
    logic [NumTagBits-1:0] BlockTags   [E-1:0];
    logic [E-1:0]          ValidBits;
    logic [E-1:0]          MatchedBlock;

    // ----- Replacement policy -----
    logic [$clog2(E)-1:0]  LRUBits       [E-1:0];
    logic [$clog2(E)-1:0]  LastLRUStatus;
    logic [$clog2(E)-1:0]  NextFill;
    logic [$clog2(E)-1:0]  RepSet;

    // ----- Data storage -----
    (* ram_style = "distributed" *)
    logic [(B*8)-1:0] SetData [E-1:0];

    // ----- Block addressing -----
    logic [b+2:0]      BlockOffset;
    logic [$clog2(E)-1:0] OutSet;

    // ----- Looping constructs -----
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
    
        for (i = 0; i < E; i = i + 1) begin
            if (MatchedBlock[i]) OutSet = i;
        end 
    end
    
    assign Data = SetData[OutSet] >> BlockOffset;
    
endmodule