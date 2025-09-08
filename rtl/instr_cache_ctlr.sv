`timescale 1ns / 1ps
//==============================================================//
//  Module:       instr_cache_ctlr
//  File:         instr_cache_ctlr.sv
//  Description:  Controls operations of the l1_icache
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   S - Number of sets
//
//  Notes:        N/A
//==============================================================//


module instr_cache_ctlr #(
    parameter int S = 64
) (
    // Clock & reset_i
    input  logic                  clk_i,
    input  logic                  reset_i,

    // Control inputs
    input  logic [$clog2(S)-1:0]  set_i,
    input  logic [S-1:0]          miss_array_i,
    input  logic [1:0]            pc_src_reg_i,
    input  logic [1:0]            branch_op_e_i,

    // Control outputs
    output logic [S-1:0]          active_array_o,
    output logic                  instr_miss_f_o,
    output logic                  instr_cache_rep_active_o
);
    
    // ---- Control signal ----
    logic delay_applied;
    
    //Decoding input set
    assign active_array_o = 1'b1 << set_i;
    assign instr_miss_f_o = miss_array_i[set_i];
    
    //Signal determining if replacement active
    assign instr_cache_rep_active_o = ~(branch_op_e_i[0] & instr_miss_f_o & (~delay_applied)) & ~pc_src_reg_i[1];
    
    //Replacement state machine logic
    //delay_applied = 0 indicates in ReadyToDelay state
    always @(posedge clk_i) begin
        if (reset_i) begin
            delay_applied <= 0; 
        end else if (~delay_applied & ~instr_cache_rep_active_o) begin
            delay_applied <= 1'b1;
        end else if (delay_applied & (~instr_miss_f_o | pc_src_reg_i[1])) begin
            delay_applied <= 0;
        end
    end
  
endmodule
