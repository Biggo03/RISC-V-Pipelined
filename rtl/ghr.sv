`timescale 1ns / 1ps
//==============================================================//
//  Module:       ghr
//  File:         ghr.sv
//  Description:  Global state machine that updates based on if a branch is taken or untaken
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module ghr (
    // Clock & reset_i
    input  logic       clk_i,
    input  logic       reset_i,

    // Control inputs
    input  logic       stall_e_i,
    input  logic [1:0] branch_op_e_i,
    input  logic       pc_src_res_e_i,

    // Control outputs
    output logic [1:0] local_src_o
);

    // ----- State encoding -----
    localparam UU = 2'b00;
    localparam UT = 2'b01;
    localparam TU = 2'b10;
    localparam TT = 2'b11;

    // ----- State registers -----
    logic [1:0] present_state;
    logic [1:0] next_state;

    //State transition logic
    always @(posedge clk_i, posedge reset_i) begin
        
        if (reset_i) begin
        present_state <= UT; // Arbitrary reset_i state
        next_state <= UT; //Default stay in initialized state
        local_src_o <= UT;
        end else begin
            present_state <= next_state;
            local_src_o <= next_state;
        end
        
    end

    //Next state logic
    always @(*) begin
        
        if (branch_op_e_i[0] & ~stall_e_i) begin

            case (present_state)
                
                UU: begin
                    if (pc_src_res_e_i) next_state <= UT;
                    else next_state <= UU;
                end
                UT: begin
                    if (pc_src_res_e_i) next_state <= TT;
                    else next_state <= TU;
                end
                TU: begin
                    if (pc_src_res_e_i) next_state <= UT;
                    else next_state <= UU;
                end
                TT: begin
                    if (pc_src_res_e_i) next_state <= TT;
                    else next_state <= TU;
                end
            
            endcase
        
        end
        
    end

endmodule
