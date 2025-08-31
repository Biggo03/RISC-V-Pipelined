`timescale 1ns / 1ps
//==============================================================//
//  Module:       reg_file
//  File:         reg_file.sv
//  Description:  Register file containing 32 registers
//                Capable of reading from two registers, and writing to one register in one cycle
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   WIDTH  - data width
//
//  Notes:        N/A
//==============================================================//

module reg_file #(
    parameter int WIDTH = 32
) (
    // Clock & Reset
    input  logic             clk,
    input  logic             reset,

    // Register addresses
    input  logic [4:0]       A1,
    input  logic [4:0]       A2,
    input  logic [4:0]       A3,

    // Write port
    input  logic [WIDTH-1:0] WD3,
    input  logic             WE3,

    // Read ports
    output logic [WIDTH-1:0] RD1,
    output logic [WIDTH-1:0] RD2
);
    
    // ----- Register file storage -----
    logic [WIDTH-1:0] RegisterArray [31:0];

    // ----- Write enables -----
    logic [31:0] en;
    
    flop u_zero_reg (
        // Clock & Reset
        .clk   (clk),
        .en    (1'b0),
        .reset (reset),

        // Data input
        .D     (32'b0),

        // Data output
        .Q     (RegisterArray[0])
    );

    genvar i;
    generate
        for (i = 1; i < 32; i = i+1) begin
            flop u_reg (
            // Clock & Reset
            .clk   (clk),
            .en    (en[i]),
            .reset (reset),

            // Data input
            .D     (WD3),

            // Data output
            .Q     (RegisterArray[i])
            );
        end
    endgenerate
    
    always @(*) begin
        if (A1 == A3 & WE3 & A1 != 0) RD1 = WD3;
        else RD1 = RegisterArray[A1];
        
        if (A2 == A3 & WE3 & A2 != 0) RD2 = WD3;
        else RD2 = RegisterArray[A2]; 
    end
    
    write_decoder u_write_decoder (
        // Register address input
        .A  (A3),

        // Control input
        .WE (WE3),

        // Decoder output
        .en (en)
    );  
          
endmodule
