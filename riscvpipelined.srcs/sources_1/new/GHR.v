`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 01/18/2025 06:52:48 PM
// Module Name: GHR
// Project Name: riscvpipelined
// Description: State machine that updates based on if a branch is taken or untaken
// 
// Dependencies:
// Additional Comments: 
//                      
//
//////////////////////////////////////////////////////////////////////////////////

module GHR(input clk, reset,
           input BranchOpEb0,
           input PCSrcResE,
           output [1:0] LocalSrc);

// Local parameters for state bits. Output matches state bits
localparam UU = 2'b00;
localparam UT = 2'b01;
localparam TU = 2'b10;
localparam TT = 2'b11;

reg [1:0] PresentState, NextState;

//State transition logic
always @(posedge clk, posedge reset) begin
    
    if (reset) begin
    PresentState <= UT; // Arbitrary reset state
    NextState <= UT; //Default stay in initialized state
    end else begin
        PresentState <= NextState;
    end
    
end


//Next state logic
always @(*) begin
    
    if (BranchOpEb0) begin

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

assign LocalSrc = PresentState;

endmodule
