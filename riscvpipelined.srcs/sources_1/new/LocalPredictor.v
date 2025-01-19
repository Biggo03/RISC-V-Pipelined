`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 01/18/2025 09:49:05 PM
// Module Name: LocalPredictor
// Project Name: riscvpipelined
// Description: State machine that updates based on if a branch is taken or untaken
// 
// Dependencies:
// Additional Comments: Signal intended to be active only if the branch index is active
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module LocalPredictor(input clk, reset,
                      input PCSrcResE,
                      input Enable,
                      output reg PCSrcPred);

    localparam ST = 2'b11;
    localparam WT = 2'b10;
    localparam WU = 2'b01;
    localparam SU = 2'b00;
    
    reg [1:0] PresentState, NextState;
    
    //State transition logic
    always @(posedge clk, posedge reset) begin
        
        if (reset) begin
            PresentState <= WU;
            NextState <= WU;
            PCSrcPred <= 0;
        end else begin
            PresentState <= NextState;
            PCSrcPred <= NextState[1];
        end
        
    end             
    
    //Next state logic
    always @(*) begin
        
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
