`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2025 04:24:58 PM
// Design Name: 
// Module Name: BranchingBuffer_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module branching_buffer_tb();
    `include "tb_macros.sv"


    logic clk, reset;
    logic [31:0] PCTargetE;
    logic [9:0] PCF, PCE;
    logic [1:0] LocalSrc, BranchOpE;
    logic PCSrcResE, TargetMatch;
    logic PCSrcPredF;
    logic [31:0] PredPCTargetF;

    int error_cnt;

    branching_buffer u_DUT (.clk(clk),
                        .reset(reset),
                        .PCTargetE(PCTargetE),
                        .PCF(PCF),
                        .PCE(PCE),
                        .LocalSrc(LocalSrc),
                        .PCSrcResE(PCSrcResE),
                        .TargetMatch(TargetMatch),
                        .BranchOpE(BranchOpE),
                        .PCSrcPredF(PCSrcPredF),
                        .PredPCTargetF(PredPCTargetF));

    always begin
        clk = ~clk; #5;
    end
    
    initial begin

        dump_setup;
        error_cnt = 0;
        
        //Initialize
        clk = 0; reset = 1; PCTargetE = 0; PCF = 0; PCE = 0; LocalSrc = 0;
        PCSrcResE = 0; TargetMatch = 0; BranchOpE = 0;
        
        #100;
        reset = 0;

        #100;
        BranchOpE[0] = 1;
        
        //Start by populating entries with target addresses
        for (int i = 0; i < 1024; i++) begin
            PCE = i;
            PCTargetE = i;
            #10;
        end
        
        BranchOpE[0] = 0;
        TargetMatch = 1;
        
        //Check if correct address is fetched by PCF
        for (int i = 0; i < 1024; i = i + 1) begin
            PCF = i;
            #10;
            `CHECK(PredPCTargetF === i, "[%t] Incorrect target address", $time)
        end
        
        //Check to see if branch updates work correctly (Should be in WU)
        PCE = 0; PCF = 0; LocalSrc = 0; BranchOpE[0] = 1; PCSrcResE = 1;
        #10;
        `CHECK(PCSrcPredF === 1, "[%t] Local predictor transition failed (first)", $time)
        
        //Put back into WU
        PCSrcResE = 0;
        #10;
        `CHECK(PCSrcPredF === 0, "[%t] Local predictor transition failed (third)", $time)
        
        //Put 1st index into strongly taken state
        PCSrcResE = 1;
        #20;
        
        //Put scond index local predictor into WT
        PCE = 1;
        #21; 
        
        //Trigger reset of first indexed local predictor
        PCE = 0; TargetMatch = 0; PCTargetE = 1000; PCSrcResE = 0;
        #10;
        `CHECK(PCSrcPredF === 0 && PredPCTargetF == 1000, "[%t] Local reset failed (first)", $time)

        
        //Ensure no other predictors changes
        PCF = 1;
        #10;
        `CHECK(PCSrcPredF === 1, "[%t] Local reset failed (second)", $time)
        
        //Ensure taking correct local predictor based on LocalSrc
        PCE = 100; PCTargetE = 1001; LocalSrc = 1; TargetMatch = 0; PCSrcResE = 1;
        #10;
        `CHECK(PCSrcPredF === 0 && PredPCTargetF == 1, "[%t] LocalSrc indexed incorrectly", $time)
        
        //Test to see if replacement for PCE100 worked correctly, and if local predictor updated properly
        //
        TargetMatch = 1; PCF = 100;
        #20;
        `CHECK(PCSrcPredF === 1 && PredPCTargetF === 1001, "[%t] Incorrect local branch update on change (first)", $time)

        //Ensure other local predictors not changed
        LocalSrc = 0; PCSrcResE = 0;
        #10;
        `CHECK(PCSrcPredF === 0 && PredPCTargetF === 1001, "[%t] Incorrect local branch update on change (second)", $time)
        
        PCSrcResE = 1;
        #20; //Wait two cycles for local predictor to be in weakly taken
        `CHECK(PCSrcPredF === 1 && PredPCTargetF === 1001, "[%t] Incorrect local branch update on change (second)", $time)
        
        if (error_cnt == 0) $display("TEST PASSED");
        else $display("TEST FAILED");
        $finish;
        
    end

endmodule
