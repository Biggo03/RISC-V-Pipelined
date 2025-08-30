`timescale 1ns / 1ps
//==============================================================//
//  Module:       branch_control_unit
//  File:         branch_control_unit.sv
//  Description:  Part of control unit handelling branching operations
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module branch_control_unit (
    // Control inputs
    input  logic [1:0] OpF,
    input  logic       PCSrcPredF,
    input  logic       PCSrcPredE,
    input  logic       BranchOpEb0,
    input  logic       TargetMatchE,
    input  logic       PCSrcResE,

    // Control outputs
    output logic [1:0] PCSrc
);

    // ----- Branch resolution select encodings -----
    localparam PCPlus4F     = 2'b00;
    localparam PredPCTargetF = 2'b01;
    localparam PCPlus4E     = 2'b10;
    localparam PCTargetE    = 2'b11;

    // ----- Branch resolution intermediates -----
    logic [1:0] FirstStageOut;
    logic [3:0] SecondStageIn;
    
    assign SecondStageIn = {TargetMatchE, BranchOpEb0, PCSrcPredE, PCSrcResE};
    
    //Prediction logic
    always @(*) begin
        
        if (OpF == 2'b11 & PCSrcPredF) FirstStageOut = PredPCTargetF;
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
