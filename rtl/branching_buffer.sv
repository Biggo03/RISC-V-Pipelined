`timescale 1ns / 1ps
//==============================================================//
//  Module:       branching_buffer
//  File:         branching_buffer.sv
//  Description:  Contains and controls local branch predictors
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        Uses PCE for corrections, and local predictor updates, uses PCF for fetching predictions
//==============================================================//

module branching_buffer (
    // Clock & Reset
    input  logic        clk,
    input  logic        reset,

    // PC inputs
    input  logic [31:0] PCTargetE,
    input  logic [9:0]  PCF,
    input  logic [9:0]  PCE,

    // Control inputs
    input  logic [1:0]  LocalSrc,
    input  logic        PCSrcResE,
    input  logic        TargetMatch,
    input  logic [1:0]  BranchOpE,

    // Branch predictor outputs
    output logic        PCSrcPredF,
    output logic [31:0] PredPCTargetF
);

    // ----- Memories -----
    (* ram_style = "distributed" *) reg [31:0] BufferEntry [1023:0];
    logic [3:0] LPOutputs [1023:0];
    
    // ----- Control inputs -----
    logic [4095:0] Enable; 
    logic [1023:0] LocalReset;
    
    // ----- Generate indices -----
    genvar i;
    
    //Every group of 4 bits corrosponds to a given PCE index
    assign Enable = BranchOpE[0] ? 1'b1 << {PCE, LocalSrc} : 0;
    
    generate
        for (i = 0; i < 4096; i = i + 1) begin
            
            // i/4 so have group of 4, i%4 to increment internal entry
            local_predictor u_local_predictor (
                // Clock & Reset
                .clk        (clk),
                .reset      (LocalReset[i/4]),

                // Control inputs
                .PCSrcResE  (PCSrcResE),
                .Enable     (Enable[i]),

                // Predictor output
                .PCSrcPred  (LPOutputs[i/4][i % 4])
            );
        end
    endgenerate
    
    //Execute stage and reset logic
    always @(posedge clk) begin
        if (reset) begin
            LocalReset <= {4096{1'b1}};
        end else if (~TargetMatch && BranchOpE[0]) begin
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
