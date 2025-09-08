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
    // Clock & reset_i
    input  logic        clk_i,
    input  logic        reset_i,

    // Control inputs
    input  logic        RepReady,
    input  logic [1:0]  pc_src_reg_i,
    input  logic [1:0]  branch_op_e_i,

    // Address & data inputs
    input  logic [31:0] pc_f_i,
    input  logic [63:0] RepWord,

    // Data outputs
    output logic [31:0] instr_f_o,

    // Status outputs
    output logic        instr_miss_f_o,
    output logic        instr_cache_rep_active_o
);
    
    // ----- Parameters -----
    localparam b          = $clog2(B);
    localparam s          = $clog2(S);
    localparam NumTagBits = 32 - s - b;

    // ----- Address fields -----
    logic [b-1:0]        block;
    logic [s-1:0]        set;
    logic [NumTagBits-1:0] tag;

    // ----- set information -----
    logic [S-1:0]  active_array;
    logic [S-1:0]  miss_array;
    logic [31:0]   data_array [S-1:0];

    // ----- Replacement control -----
    logic rep_enable;

    assign block = pc_f_i[b-1:0];
    assign set = pc_f_i[s+b-1:b]; 
    assign tag = pc_f_i[31:s+b]; 
    
    assign rep_enable = instr_cache_rep_active_o & RepReady;
    
    //Generate Sets
    genvar i;
    generate 
        for (i = 0; i < S; i = i + 1) begin
            instr_cache_set_multi #( // u_instr_cache_set_multi (
                .B                              (B),
                .NumTagBits                     (NumTagBits),
                .E                              (E)
            ) u_instr_cache_set_multi (
                // Clock & reset_i
                .clk_i                          (clk_i),
                .reset_i                        (reset_i),

                // Control inputs
                .ActiveSet                      (active_array[i]),
                .rep_enable_i                   (rep_enable),

                // Address inputs
                .block_i                        (block),
                .tag_i                          (tag),

                // Replacement data input
                .RepWord                        (RepWord),

                // Data outputs
                .Data                           (data_array[i]),

                // Status output
                .CacheSetMiss                   (miss_array[i])
            );
        end
    endgenerate
    
    //Cache Controller
    instr_cache_ctlr #( // u_instr_cache_ctlr ()
        .S                              (S)
    ) u_instr_cache_ctlr (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Control inputs
        .set_i                          (set),
        .miss_array_i                   (miss_array),
        .pc_src_reg_i                   (pc_src_reg_i),
        .branch_op_e_i                  (branch_op_e_i),

        // Control outputs
        .active_array_o                 (active_array),
        .instr_miss_f_o                 (instr_miss_f_o),
        .instr_cache_rep_active_o       (instr_cache_rep_active_o)
    );
    
    
    //Assign output
    assign instr_f_o = data_array[set];

endmodule
