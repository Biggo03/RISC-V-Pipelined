`timescale 1ns / 1ps
//==============================================================//
//  Module:       mux5
//  File:         mux5.sv
//  Description:  Five-input mux
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//


module mux5 #(
    parameter int WIDTH = 32
) (
    // Data inputs
    input  logic [WIDTH-1:0] d0,
    input  logic [WIDTH-1:0] d1,
    input  logic [WIDTH-1:0] d2,
    input  logic [WIDTH-1:0] d3,
    input  logic [WIDTH-1:0] d4,

    // Select input
    input  logic [2:0]       s,

    // Data output
    output logic [WIDTH-1:0] y
);
         
    assign y = s[2] ? d4 : (s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1 : d0));
         
         
endmodule
