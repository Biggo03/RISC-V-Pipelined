`timescale 1ns / 1ps
//==============================================================//
//  Module:       hazard_unit
//  File:         hazard_unit.sv
//  Description:  Generates signals to control hazard handelling within the pipeline
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//
`include "control_macros.sv"

module hazard_unit (
    // Fetch stage inputs
    input  logic        instr_miss_f_i,

    // Decode stage inputs
    input  logic [4:0]  rs1_d_i,
    input  logic [4:0]  rs2_d_i,

    // Execute stage inputs
    input  logic [4:0]  rs1_e_i,
    input  logic [4:0]  rs2_e_i,
    input  logic [4:0]  rd_e_i,
    input  logic [2:0]  result_src_e_i,
    input  logic [1:0]  pc_src_i,

    // Memory stage inputs
    input  logic [4:0]  rd_m_i,
    input  logic        reg_write_m_i,

    // Writeback stage inputs
    input  logic [4:0]  rd_w_i,
    input  logic        reg_write_w_i,

    // Branch predictor / cache inputs
    input  logic [1:0]  pc_src_reg_i,
    input  logic        instr_cache_rep_en_i,

    // stall outputs
    output logic        stall_f_o,
    output logic        stall_d_o,
    output logic        stall_e_o,
    output logic        stall_m_o,
    output logic        stall_w_o,

    // flush outputs
    output logic        flush_d_o,
    output logic        flush_e_o,

    // Forwarding outputs
    output logic [1:0]  forward_a_e_o,
    output logic [1:0]  forward_b_e_o
);
    
    // ----- Forwarding control -----
    localparam [1:0] NO_FORWARD  = 2'b00;
    localparam [1:0] WB_FORWARD  = 2'b01;
    localparam [1:0] MEM_FORWARD = 2'b10;

    // ----- Hazard detection -----
    logic LoadStall;
    
    //Forward logic
    always @(*) begin
        
        //forward_a_e_o
        if (((rs1_e_i == rd_m_i) & reg_write_m_i) & (rs1_e_i != 0)) forward_a_e_o = MEM_FORWARD;
        else if (((rs1_e_i == rd_w_i) & reg_write_w_i) & (rs1_e_i != 0)) forward_a_e_o = WB_FORWARD;
        else forward_a_e_o = NO_FORWARD;
        
        //forward_b_e_o
        if (((rs2_e_i == rd_m_i) & reg_write_m_i) & (rs2_e_i != 0)) forward_b_e_o = MEM_FORWARD;
        else if (((rs2_e_i == rd_w_i) & reg_write_w_i) & (rs2_e_i != 0)) forward_b_e_o = WB_FORWARD;
        else forward_b_e_o = NO_FORWARD;
    
    end  
    
    //stall and flush logic
    assign LoadStall = (result_src_e_i == `RESULT_MEM_DATA) & ((rs1_d_i == rd_e_i) | (rs2_d_i == rd_e_i));
    
    //Stalls
    assign stall_f_o = (LoadStall | instr_miss_f_i) & ~pc_src_reg_i[1];
    assign stall_d_o = LoadStall | instr_miss_f_i;
    assign stall_e_o = instr_miss_f_i;
    assign stall_m_o = instr_miss_f_i;
    assign stall_w_o = instr_miss_f_i;
    
    //Flushes
    assign flush_e_o = (pc_src_i[1] & (instr_cache_rep_en_i | pc_src_reg_i[1])) | LoadStall;
    assign flush_d_o = pc_src_i[1];

endmodule
