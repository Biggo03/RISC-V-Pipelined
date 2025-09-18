`timescale 1ns / 1ps
//==============================================================//
//  Module:       flop
//  File:         flop.sv
//  Description:  Generic parameterized D flip-flop with reset
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   WIDTH  - width of stored value
//
//  Notes:        Active-high synchronous reset
//==============================================================//


module flop #(
    parameter int WIDTH = 32
) (
    // Clock & control inputs
    input  logic             clk_i,
    input  logic             en,
    input  logic             reset,

    // data_i input
    input  logic [WIDTH-1:0] D,

    // data_i output
    output logic [WIDTH-1:0] Q
);
    
    always @(posedge clk_i) begin
        if (reset) Q <= 0;
        else if (en) Q <= D;
    end
    
   
endmodule
