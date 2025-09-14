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
`include "control_macros.sv"

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

    // ----- Delay FSM states -----
    typedef enum logic [0:0] {
        READY_TO_DELAY = 1'b0,
        DELAYING       = 1'b1
    } delay_state_t;

    // ----- State registers -----
    delay_state_t present_state;
    delay_state_t next_state;

    // Decode input set
    assign active_array_o = 1'b1 << set_i;
    assign instr_miss_f_o = miss_array_i[set_i];
    
    // Determines if signal active
    assign instr_cache_rep_active_o = ((branch_op_e_i == `NON_BRANCH) | ~instr_miss_f_o | present_state) & ~pc_src_reg_i[1];
    
    // State update logic
    always_ff @(posedge clk_i) begin
        if (reset_i) present_state <= READY_TO_DELAY;
        else         present_state <= next_state;
    end

    // Next state logic
    always_comb begin
        next_state = present_state;
        case (present_state)
            READY_TO_DELAY: if (~instr_cache_rep_active_o)         next_state = DELAYING;
            DELAYING: if (~instr_miss_f_o | pc_src_reg_i[1])       next_state = READY_TO_DELAY;
        endcase
    end
  
endmodule
