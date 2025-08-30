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
    // Clock & Reset
    input  logic       clk,
    input  logic       reset,

    // Control inputs
    input  logic       StallE,
    input  logic       BranchOpEb0,
    input  logic       PCSrcResE,

    // Control outputs
    output logic [1:0] LocalSrc
);

    // ----- State encoding -----
    localparam UU = 2'b00;
    localparam UT = 2'b01;
    localparam TU = 2'b10;
    localparam TT = 2'b11;

    // ----- State registers -----
    logic [1:0] PresentState;
    logic [1:0] NextState;

    //State transition logic
    always @(posedge clk, posedge reset) begin
        
        if (reset) begin
        PresentState <= UT; // Arbitrary reset state
        NextState <= UT; //Default stay in initialized state
        LocalSrc <= UT;
        end else begin
            PresentState <= NextState;
            LocalSrc <= NextState;
        end
        
    end

    //Next state logic
    always @(*) begin
        
        if (BranchOpEb0 & ~StallE) begin

            case (PresentState)
                
                UU: begin
                    if (PCSrcResE) NextState <= UT;
                    else NextState <= UU;
                end
                UT: begin
                    if (PCSrcResE) NextState <= TT;
                    else NextState <= TU;
                end
                TU: begin
                    if (PCSrcResE) NextState <= UT;
                    else NextState <= UU;
                end
                TT: begin
                    if (PCSrcResE) NextState <= TT;
                    else NextState <= TU;
                end
            
            endcase
        
        end
        
    end

endmodule
