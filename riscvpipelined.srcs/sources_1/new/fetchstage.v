`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 09/29/2024 08:23:43 PM
// Module Name: fetchstage
// Project Name: riscvpipelined
// Description: All logic contained within the fetch pipeline stage.
//              Note this is the only stage with it's pipeline register contained within its module.
// 
// Dependencies: flop (flop.v), adder (adder.v), mux2 (mux2.v) instrmem (instrmem.v)
// Additional Comments: This is intended to interface with outputs being linked to the decode
//                      stages pipeline register.
//
//////////////////////////////////////////////////////////////////////////////////


module Fstage(input clk, reset,
                  input [31:0] PCTargetE,
                  input PCSrcE, StallF,
                  output [31:0] InstrF,
                  output [31:0] PCF, PCPlus4F);

    //Intermedoate PC value
    wire [31:0] PCNextF;
    
    //PC Register logic
    mux2 PCmux(
               .d0 (PCPlus4F),
               .d1 (PCTargetE),
               .s (PCSrcE), 
               .y (PCNextF));
    
    flop PCreg(
               .clk (clk),
               .en (~StallF), 
               .reset (reset),
               .D (PCNextF),
               .Q (PCF));

    adder PCPlus4Adder(
                       .a (PCF),
                       .b (4),
                       .y (PCPlus4F));
    
    //Instruction Memory
    instrmem Imem(
                  .A (PCF),
                  .RD (InstrF));

endmodule
