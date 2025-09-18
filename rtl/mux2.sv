`timescale 1ns / 1ps
//==============================================================//
//  Module:       mux2
//  File:         mux2.sv
//  Description:  Two-input mux
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module mux2 #(
    parameter int WIDTH = 32
) (
    // data inputs
    input  logic [WIDTH-1:0] d0,
    input  logic [WIDTH-1:0] d1,

    // Select input
    input  logic             s,

    // data output
    output logic [WIDTH-1:0] y
);
            
    assign y = s ? d1 : d0;
        
endmodule
