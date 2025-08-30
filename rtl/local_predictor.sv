`timescale 1ns / 1ps
//==============================================================//
//  Module:       local_predictor
//  File:         local_predictor.sv
//  Description:  State machine that updates based on if a branch is taken or untaken
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        Signal intended to be active only if the branch index is active
//==============================================================//

module local_predictor (
    // Clock & Reset
    input  logic clk,
    input  logic reset,

    // Control inputs
    input  logic PCSrcResE,
    input  logic Enable,

    // Predictor output
    output logic PCSrcPred
);

    // ----- State encoding -----
    localparam ST = 2'b11;
    localparam WT = 2'b10;
    localparam WU = 2'b01;
    localparam SU = 2'b00;

    // ----- State registers -----
    logic [1:0] PresentState;
    logic [1:0] NextState;
    
    //State transition logic
    always @(posedge clk, posedge reset) begin
        
        if (reset) begin
            PCSrcPred <= 0;
            PresentState <= WU;
            NextState <= WU;
        end else begin
            PresentState <= NextState;
            PCSrcPred <= NextState[1];
        end
        
    end             
    
    //Next state logic
    always @(Enable, PresentState, PCSrcResE, clk) begin
        
        if (Enable) begin
            
            case (PresentState)
            
                ST: begin
                    if (PCSrcResE) NextState <= ST;
                    else NextState <= WT;
                end
                WT: begin
                    if (PCSrcResE) NextState <= ST;
                    else NextState <= WU;
                end
                WU: begin
                    if (PCSrcResE) NextState <= WT;
                    else NextState <= SU;
                end
                SU: begin
                    if (PCSrcResE) NextState <= WU;
                    else NextState <= SU;
                end
            
            endcase
            
        end
        
    end

endmodule
