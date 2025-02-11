`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 01/19/2025 12:13:32 PM
// Module Name: BranchingBuffer
// Project Name: riscvpipelined
// Description: Contains Predicted branch target addresses, as well as the local predictors predictions for
//              branches indexed by the 10 LSB's of PC.
// 
// Dependencies:
// Additional Comments: Uses PCE for corrections, and local predictor updates, uses PCF for fetching predictions
//                      
//
//////////////////////////////////////////////////////////////////////////////////



module BranchingBuffer(input clk, reset,
                       input [31:0] PCTargetE,
                       input [9:0] PCF, PCE,
                       input [1:0] LocalSrc,
                       input PCSrcResE,
                       input TargetMatch,
                       input BranchOpEb0, 
                       output PCSrcPredF,
                       output [31:0] PredPCTargetF);


    (* ram_style = "block" *) reg [31:0] BufferEntry [1023:0];
    wire [3:0] LPOutputs [1023:0];
    
    //Local predictor inputs
    wire [4095:0] Enable; 
    reg [1023:0] LocalReset;
    
    genvar i;
    
    
    //Every group of 4 bits corrosponds to a given PCE index
    assign Enable = BranchOpEb0 ? 1'b1 << {PCE, LocalSrc} : 0;
    
    generate
        for (i = 0; i < 4096; i = i + 1) begin
            
            // i/4 so have group of 4, i%4 to increment internal entry
            LocalPredictor LP(.clk(clk),
                              .reset(LocalReset[i/4]),
                              .PCSrcResE(PCSrcResE),
                              .Enable(Enable[i]),
                              .PCSrcPred(LPOutputs[i/4][i % 4]));
        end
    endgenerate
    
    //Execute stage and reset logic
    //Posedge on reset so clock gating doesn't affect reset behaviour
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            LocalReset <= {4096{1'b1}};
        end else if (~TargetMatch && BranchOpEb0) begin
            BufferEntry[PCE][31:0] <= PCTargetE;
            LocalReset <= 0; //Initizlize to 0 to ensure only current branch stays reset
            LocalReset[PCE] <= 1'b1;
        end else begin
            LocalReset <= 0; //Ensures all local predictors are ready after a reset
        end
    end
    
    //Fetch stage logic
    assign PCSrcPredF = LPOutputs[PCF][LocalSrc];
    assign PredPCTargetF = BufferEntry[PCF][31:0];
    
endmodule
