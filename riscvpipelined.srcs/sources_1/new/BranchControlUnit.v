`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 01/23/2025 06:54:14 PM
// Module Name: BranchControlUnit
// Project Name: riscvpipelined
// Description: Part of control unit responsible for handelling branching operations
// 
// Dependencies:
// Additional Comments: 
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module BranchControlUnit(input [1:0] Op,
                         input PCSrcPredF, PCSrcPredE,
                         input BranchOpEb0,
                         input TargetMatchE,
                         input PCSrcResE,
                         output reg [1:0] PCSrc);

    localparam PCPlus4F = 2'b00;
    localparam PredPCTargetF = 2'b01;
    localparam PCTargetE = 2'b11;
    localparam PCPlus4E = 2'b10;
    
    //Holds output of first stage logic
    reg [1:0] FirstStageOut;
    
    //Turns second stage inputs into 4-bit signals
    wire [3:0] SecondStageIn;
    assign SecondStageIn = {TargetMatchE, BranchOpEb0, PCSrcPredE, PCSrcResE};
    
    //Prediction logic
    always @(*) begin
        
        if (Op == 2'b11 & PCSrcPredF) FirstStageOut = PredPCTargetF;
        else FirstStageOut = PCPlus4F;
        
    end
    
    //Rollback logic
    always @(*) begin
        
        casez (SecondStageIn)
        
            4'b0111: PCSrc = PCTargetE;
            4'b?110: PCSrc = PCPlus4E;
            4'b?101: PCSrc = PCTargetE;
            default: PCSrc = FirstStageOut;
        
        endcase
        
    end

endmodule
