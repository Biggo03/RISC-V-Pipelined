`timescale 1ns / 1ps
//==============================================================//
//  Module:       local_predictor
//  File:         local_predictor.sv
//  Description:  State machine that updates based on if a branch is taken or untaken
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        Signal intended to be active only if the branch index is active
//==============================================================//

module local_predictor (
    // Clock & reset_i
    input  logic clk_i,
    input  logic reset_i,

    // Control inputs
    input  logic pc_src_res_e_i,
    input  logic enable_i,

    // Predictor output
    output logic pc_src_pred_o
);

    // ----- Branch predictor states -----
    typedef enum logic [1:0] {
        ST = 2'b11,
        WT = 2'b10,
        WU = 2'b01,
        SU = 2'b00
    } pred_state_t;

    // ----- State registers -----
    pred_state_t present_state;
    pred_state_t next_state;
    
    // State transition logic
    always @(posedge clk_i, posedge reset_i) begin
        if (reset_i) begin
            present_state <= WU;
        end else if (enable_i) begin
            present_state <= next_state;
        end
    end             
    
    // Next state logic
    always @(*) begin
        if (enable_i) begin
            case (present_state)
                ST: begin
                    if (pc_src_res_e_i) next_state <= ST;
                    else next_state <= WT;
                end
                WT: begin
                    if (pc_src_res_e_i) next_state <= ST;
                    else next_state <= WU;
                end
                WU: begin
                    if (pc_src_res_e_i) next_state <= WT;
                    else next_state <= SU;
                end
                SU: begin
                    if (pc_src_res_e_i) next_state <= WU;
                    else next_state <= SU;
                end
            endcase
        end
    end
    
    // Assign output
    assign pc_src_pred_o = present_state[1];

endmodule
