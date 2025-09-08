`timescale 1ns / 1ps
//==============================================================//
//  Module:       write_decoder
//  File:         write_decoder.sv
//  Description:  Generates a one-hot encoded signal based on a given address.
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//


module write_decoder (
    // Address & control inputs
    input  logic [4:0]  A,
    input  logic        WE,

    // Enable outputs
    output logic [31:0] en
);
    
    assign en = WE ? 1'b1 << A : 0;

endmodule
