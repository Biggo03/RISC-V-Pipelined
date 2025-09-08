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
    // Clock & reset_i
    input  logic             clk_i,
    input  logic             reset_i,

    // Register addresses
    input  logic [4:0]       a1_i,
    input  logic [4:0]       a2_i,
    input  logic [4:0]       a3_i,

    // Write port
    input  logic [WIDTH-1:0] wd3_i,
    input  logic             we3_i,

    // Read ports
    output logic [WIDTH-1:0] rd1_o,
    output logic [WIDTH-1:0] rd2_o
);
    
    // ----- Register file storage -----
    logic [WIDTH-1:0] RegisterArray [31:0];

    // ----- Write enables -----
    logic [31:0] en;
    
    flop u_zero_reg (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .en                             (1'b0),
        .reset                          (reset_i),

        // Data input
        .D                              (32'b0),

        // Data output
        .Q                              (RegisterArray[0])
    );

    genvar i;
    generate
        for (i = 1; i < 32; i = i+1) begin
            flop u_reg (
            // Clock & reset_i
            .clk_i                          (clk_i),
            .en                             (en[i]),
            .reset                          (reset_i),

            // Data input
            .D                              (wd3_i),

            // Data output
            .Q                              (RegisterArray[i])
            );
        end
    endgenerate
    
    always @(*) begin
        if (a1_i == a3_i & we3_i & a1_i != 0) rd1_o = wd3_i;
        else rd1_o = RegisterArray[a1_i];
        
        if (a2_i == a3_i & we3_i & a2_i != 0) rd2_o = wd3_i;
        else rd2_o = RegisterArray[a2_i]; 
    end
    
    write_decoder u_write_decoder (
        // Register address input
        .A                              (a3_i),

        // Control input
        .WE                             (we3_i),

        // Decoder output
        .en                             (en)
    );  
          
endmodule
