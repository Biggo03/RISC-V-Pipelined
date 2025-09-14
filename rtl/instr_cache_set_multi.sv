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
//                num_tag_bits: Number of tag bits
//                E: Associativity
//
//  Notes:        This module assumes the L2 cache can't provide data in the same cycle as a miss
//==============================================================//

module instr_cache_set_multi #(
    parameter int B          = 64,
    parameter int num_tag_bits = 20,
    parameter int E          = 4
) (
    // Clock & reset_i
    input  logic                  clk_i,
    input  logic                  reset_i,

    // Control inputs
    input  logic                  ActiveSet,
    input  logic                  rep_active_i,

    // Address & data inputs
    input  logic [$clog2(B)-1:0]  block_i,
    input  logic [num_tag_bits-1:0] tag_i,
    input  logic [63:0]           rep_word_i,

    // Data outputs
    output logic [31:0]           Data,
    output logic                  CacheSetMiss
);
    
    // ----- Parameters -----
    localparam b      = $clog2(B);
    localparam words  = B/4;

    // ----- tag_i + validity -----
    logic [num_tag_bits-1:0] block_tags   [E-1:0];
    logic [E-1:0]          valid_bits;
    logic [E-1:0]          matched_block;

    // ----- Replacement policy -----
    logic [$clog2(E)-1:0]  lru_bits      [E-1:0];
    logic [$clog2(E)-1:0]  last_lru_status;
    logic [$clog2(E)-1:0]  next_fill;
    logic [$clog2(E)-1:0]  removed_block;
    logic [$clog2(words)-1:0] rep_counter; 
    logic                  rep_active;
    logic                  rep_complete;
    logic                  rep_begin;

    // ----- Data storage -----
    (* ram_style = "distributed" *)
    logic [63:0] set_data [(words*E)/2-1:0];

    // ----- block_i addressing -----
    logic [$clog2(words)-1:0] block_offset;
    logic [$clog2(E)-1:0]     out_set;

    // ----- Looping constructs -----
    integer i;
    genvar n;
    
    assign rep_active = CacheSetMiss && ActiveSet && rep_active_i;

    //tag_i and valid comparison logic
    always @(*) begin
    
        matched_block = 0;
        CacheSetMiss = 1;
        last_lru_status = 0;
        
        if (ActiveSet) begin
             //Determine if a block matches
            for (i = 0; i < E; i = i + 1) begin
                if (valid_bits[i] == 1 && tag_i == block_tags[i]) begin
                    matched_block[i] = 1;
                    last_lru_status = lru_bits[i];
                end else begin
                    matched_block[i] = 0;
                end
            end
        
            //Declare a miss
            if (matched_block == 0) CacheSetMiss = 1;
            else CacheSetMiss = 0;
            
        end
    end
    
    //block_i to remove logic
    always @(posedge clk_i) begin
        if (CacheSetMiss && ActiveSet && ~rep_begin) begin
            if (valid_bits == {E{1'b1}}) begin
                for (i = 0; i < E; i = i + 1) begin
                    if (lru_bits[i] == E-1) begin              
                        removed_block <= i;
                    end 
                end
            end else begin
                removed_block <= next_fill;
            end
        end
    end
    
    //LRU and ValidBit updates
    always @(posedge clk_i) begin
        
        //reset_i logic
        if (reset_i) begin
            valid_bits <= 0;
            next_fill <= 0;
            rep_begin <= 0;
            for (i = 0; i < E; i = i + 1) begin
                lru_bits[i] <= 0;
            end
        
        //Handle block_i Replacement LRU and ValidBit updates
        end else if (rep_active && ~rep_begin) begin
            rep_begin <= 1;
            
            //Replace when sets full of valid data
            if (valid_bits == {E{1'b1}}) begin
                for (i = 0; i < E; i = i + 1) begin
                    if (lru_bits[i] == E-1) begin              
                        lru_bits[removed_block] <= 0;
                    end else begin
                        lru_bits[i] <= lru_bits[i] + 1;
                    end
                end
                
            //Populate cache with data
            end else begin
                lru_bits[removed_block] <= 0;
                valid_bits[removed_block] <= 1;   
                next_fill <= next_fill + 1;
                for (i = 0; i < E; i = i + 1) begin
                    if (i < next_fill) begin
                        lru_bits[i] <= lru_bits[i] + 1;
                    end
                end
            end
        
        //Handle LRU updates on non-replacing accesses
        end else  if (ActiveSet && ~CacheSetMiss) begin
            rep_begin <= 0;
            for (i = 0; i < E; i = i + 1) begin
                if (~matched_block[i] && valid_bits[i] && lru_bits[i] < last_lru_status) begin
                    lru_bits[i] <= lru_bits[i] + 1;
                end else if (matched_block[i]) begin
                    lru_bits[i] <= 0;
                end
            end
        end else if (rep_complete) begin
            rep_begin <= 0;
        end
    end
    
    assign rep_complete = rep_counter == (words/2)-1;
    
    //Replacement logic
    always @(posedge clk_i) begin
        if (rep_active) begin
            set_data[(removed_block*words/2) + rep_counter] <= rep_word_i;
            //Replace tag and reset_i counter when replacement complete
            if (rep_complete) begin
                rep_counter <= 0;
                block_tags[removed_block] <= tag_i;
            end else begin
                rep_counter <= rep_counter + 1;
            end
        end else begin
            rep_counter <= 0;
        end
    end
    
    //Output logic
    always @(*) begin
        if (matched_block != 0) begin
            for (i = 0; i < E; i = i + 1) begin
                if (matched_block[i]) out_set = i;
            end 
        end else begin
            out_set = 0;
        end

    end

    assign block_offset = block_i[b-1:3];
    assign Data = block_i[2] ? set_data[(out_set*words)/2 + block_offset][63:32] : set_data[(out_set*words)/2 + block_offset][31:0];
    
endmodule