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

    // ----- ghr states -----
    typedef enum logic [1:0] {
        UU = 2'b00,
        UT = 2'b01,
        TU = 2'b10,
        TT = 2'b11
    } ghr_state_t;

    // ----- State registers -----
    ghr_state_t present_state;
    ghr_state_t next_state;

    // State transition logic
    always @(posedge clk_i, posedge reset_i) begin
        if (reset_i) begin
            present_state <= UT;
            next_state <= UT;
        end else begin
            present_state <= next_state;
        end
    end

    // Next state logic
    always_comb begin
        if (branch_op_e_i[0] & ~stall_e_i) begin
            case (present_state)
                UU: begin
                    if (pc_src_res_e_i) next_state = UT;
                    else                next_state = UU;
                end
                UT: begin
                    if (pc_src_res_e_i) next_state = TT;
                    else                next_state = TU;
                end
                TU: begin
                    if (pc_src_res_e_i) next_state = UT;
                    else                next_state = UU;
                end
                TT: begin
                    if (pc_src_res_e_i) next_state = TT;
                    else                next_state = TU;
                end
            endcase
        end
    end

    // Output assignment
    assign local_src_o = present_state;

endmodule
