`timescale 1ns / 1ps
//==============================================================//
//  Module:       fetch_stage
//  File:         fetch_stage.sv
//  Description:  All logic contained within the fetch pipeline stage, along with its pipeline register
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module fetch_stage (
    // Clock & reset_i
    input  logic        clk_i,
    input  logic        reset_i,

    // Control inputs
    input  logic [1:0]  pc_src_i,
    input  logic        stall_f_i,

    // pc inputs
    input  logic [31:0] pc_target_e_i,
    input  logic [31:0] pc_plus4_e_i,
    input  logic [31:0] pred_pc_target_f_i,

    // pc outputs
    output logic [31:0] pc_f_o,
    output logic [31:0] pc_plus4_f_o
);

    // ---- Intermediate signal ----
    logic [31:0] PCNextF;
    
    //pc Register logic
    mux4 u_mux4_pc (
        // Data inputs
        .d0                             (pc_plus4_f_o),
        .d1                             (pred_pc_target_f_i),
        .d2                             (pc_plus4_e_i),
        .d3                             (pc_target_e_i),

        // Select input
        .s                              (pc_src_i),

        // Data output
        .y                              (PCNextF)
    );
        
    flop u_pc_reg (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset                          (reset_i),
        .en                             (~stall_f_i),

        // Data input
        .D                              (PCNextF),

        // Data output
        .Q                              (pc_f_o)
    );

    adder u_adder_pc_plus4 (
        // Data inputs
        .a                              (pc_f_o),
        .b                              (4),

        // Data output
        .y                              (pc_plus4_f_o)
    );

endmodule
