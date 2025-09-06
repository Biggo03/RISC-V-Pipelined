`timescale 1ns / 1ps
//==============================================================//
//  Module:       icache_l1
//  File:         icache_l1.sv
//  Description:  Paramaterized L1 instruction cache, uses a multi-cycle LRU replacement policy
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   Sets expect replacement data takes at least 1 cycle to reach it
//                Must be at least 2-way associative
//
//  Notes:        N/A
//==============================================================//

module icache_l1 #(
    parameter int S = 32,
    parameter int E = 4,
    parameter int B = 64
) (
    // Clock & Reset
    input  logic        clk,
    input  logic        reset,

    // Control inputs
    input  logic        RepReady,
    input  logic [1:0]  PCSrcReg,
    input  logic [1:0]  BranchOpE,

    // Address & data inputs
    input  logic [31:0] Address,
    input  logic [63:0] RepWord,

    // Data outputs
    output logic [31:0] RD,

    // Status outputs
    output logic        L1IMiss,
    output logic        CacheRepActive
);
    
    // ----- Parameters -----
    localparam b          = $clog2(B);
    localparam s          = $clog2(S);
    localparam NumTagBits = 32 - s - b;

    // ----- Address fields -----
    logic [b-1:0]        Block;
    logic [s-1:0]        Set;
    logic [NumTagBits-1:0] Tag;

    // ----- Set information -----
    logic [S-1:0]  ActiveArray;
    logic [S-1:0]  MissArray;
    logic [31:0]   DataArray [S-1:0];

    // ----- Replacement control -----
    logic RepEnable;

    assign Block = Address[b-1:0];
    assign Set = Address[s+b-1:b]; 
    assign Tag = Address[31:s+b]; 
    
    assign RepEnable = CacheRepActive & RepReady;
    
    //Generate Sets
    genvar i;
    generate 
        for (i = 0; i < S; i = i + 1) begin
            instr_cache_set_multi #( // u_instr_cache_set_multi (
                .B          (B),
                .NumTagBits (NumTagBits),
                .E          (E)
            ) u_instr_cache_set_multi (
                // Clock & Reset
                .clk        (clk),
                .reset      (reset),

                // Control inputs
                .ActiveSet  (ActiveArray[i]),
                .RepEnable  (RepEnable),

                // Address inputs
                .Block      (Block),
                .Tag        (Tag),

                // Replacement data input
                .RepWord    (RepWord),

                // Data outputs
                .Data       (DataArray[i]),

                // Status output
                .CacheMiss  (MissArray[i])
            );
        end
    endgenerate
    
    //Cache Controller
    instr_cache_ctlr #( // u_instr_cache_ctlr ()
        .S (S)
    ) u_instr_cache_ctlr (
        // Clock & Reset
        .clk            (clk),
        .reset          (reset),

        // Control inputs
        .Set            (Set),
        .MissArray      (MissArray),
        .PCSrcReg       (PCSrcReg),
        .BranchOpE      (BranchOpE),

        // Control outputs
        .ActiveArray    (ActiveArray),
        .CacheMiss      (L1IMiss),
        .CacheRepActive (CacheRepActive)
    );
    
    
    //Assign output
    assign RD = DataArray[Set];

endmodule
