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


module BranchingBuffer_TB();


    logic clk, reset;
    logic [31:0] PCTargetE;
    logic [9:0] PCF, PCE;
    logic [1:0] LocalSrc;
    logic PCSrcResE, TargetMatch, BranchOpEb0;
    logic PCSrcPredF;
    logic [31:0] PredPCTargetF;

    BranchingBuffer DUT(.clk(clk),
                        .reset(reset),
                        .PCTargetE(PCTargetE),
                        .PCF(PCF),
                        .PCE(PCE),
                        .LocalSrc(LocalSrc),
                        .PCSrcResE,
                        .TargetMatch(TargetMatch),
                        .BranchOpEb0(BranchOpEb0),
                        .PCSrcPredF(PCSrcPredF),
                        .PredPCTargetF(PredPCTargetF));

    always begin
        clk = ~clk; #5;
    end
    
    initial begin
        
        //Initialize
        clk = 0; reset = 1; PCTargetE = 0; PCF = 0; PCE = 0; LocalSrc = 0;
        PCSrcResE = 0; TargetMatch = 0; BranchOpEb0 = 0;
        
        #5;
        
        reset = 0;
        BranchOpEb0 = 1;
        
        //Start by populating entries with target addresses 
        for (int i = 0; i < 1024; i++) begin
            PCE = i;
            PCTargetE = i;
            #10;
        end
        
        BranchOpEb0 = 0;
        TargetMatch = 1;
        
        //Check if correct address is fetched by PCF
        for (int i = 0; i < 1024; i = i + 1) begin
            PCF = i;
            #10;
            assert(PredPCTargetF === i) else $fatal("Incorrect target address");
        end
        
        //Check to see if branch updates work correctly (should be in WT)
        PCE = 0; PCF = 0; LocalSrc = 0; BranchOpEb0 = 1; PCSrcResE = 1;
        #11;
        assert (PCSrcPredF === 1) else $fatal("Local predictor transition failed (first)");
        
        //Put back into WU
        PCSrcResE = 0;
        #10;
        assert (PCSrcPredF === 0) else $fatal("Local predictor transition failed (second)");
        
        //Put 1st index into strongly taken state
        PCSrcResE = 1;
        #20;
        
        //Put scond index local predictor into non-initialized state
        PCE = 1;
        #10; 
        
        //Trigger reset of first indexed local predictor
        PCE = 0; TargetMatch = 0; PCTargetE = 1000;
        #10;
        assert (PCSrcPredF === 0 && PredPCTargetF == 1000) else $fatal("Local reset failed (first)");
        
        //Ensure no other predictors changes
        PCF = 1;
        #10;
        assert (PCSrcPredF === 1) else $fatal("Local reset failed (second)");
        
        //Ensure taking correct local predictor based on LocalSrc
        PCE = 100; PCTargetE = 1001; LocalSrc = 1; TargetMatch = 0;
        #10;
        assert (PCSrcPredF === 0 && PredPCTargetF == 1) else $fatal("LocalSrc indexed incorrectly");
        
        //Test to see if replacement for PCE100 worked correctly, and if local predictor updated properly
        //Need to wait two cycles, as reset needs to be deasserted
        TargetMatch = 1; PCF = 100;
        #20;
        assert (PCSrcPredF === 1 && PredPCTargetF === 1001) else $fatal("Incorrect local branch update on change");
        
        $display("Simulation Succesful!");
        $stop;
        
    end

endmodule
