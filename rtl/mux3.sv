`timescale 1ns / 1ps
//==============================================================//
//  Module:       mux3
//  File:         mux3.sv
//  Description:  Three-input mux
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module mux3 #(
    parameter int WIDTH = 32
) (
    // Data inputs
    input  logic [WIDTH-1:0] d0,
    input  logic [WIDTH-1:0] d1,
    input  logic [WIDTH-1:0] d2,

    // Select input
    input  logic [1:0]       s,

    // Data output
    output logic [WIDTH-1:0] y
);

    assign y = s[1] ? d2 : (s[0] ? d1 : d0);
    
endmodule
