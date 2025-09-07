`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/23/2025 08:01:25 PM
// Design Name: 
// Module Name: BranchControlUnit_TB
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


module branch_control_unit_tb();

    logic [1:0] Op;
    logic       PCSrcPredF;
    logic       PCSrcPredE;
    logic       TargetMatchE;
    logic       PCSrcResE;
    logic [1:0] BranchOpE;
    logic [1:0] PCSrc;

    logic [2:0] test;

    branch_control_unit u_DUT (
        .OpF          (Op),
        .PCSrcPredF   (PCSrcPredF),
        .PCSrcPredE   (PCSrcPredE),
        .BranchOpE    (BranchOpE),
        .TargetMatchE (TargetMatchE),
        .PCSrcResE    (PCSrcResE),
        .PCSrc        (PCSrc)
    );
    
    task RollbackAssertion(input logic [1:0] val);
                #10;
                assert (PCSrc === val) else $fatal(1, "Rollback Error\nInputs: TargetMatchE: %b BranchOpE[0]: %b, PCSrcPredE: %b, PCSrcResE: %b\nOutput: PCSrc: %b",TargetMatchE,BranchOpE[0] , PCSrcPredE, PCSrcResE, PCSrc);
    endtask

    initial begin
        
        dump_setup;

        Op = 0; PCSrcPredF = 0; PCSrcPredE = 0; 
        BranchOpE = 0; TargetMatchE = 0; PCSrcResE = 0;
        
        //When BranchOpE[0] = 0, should only get output from prediction logic
        //Will use this to ensure first stage outputs are as expected.
        for (int i = 0; i < 3; i++) begin
            
            Op = i;
            PCSrcPredF = ~PCSrcPredF; //Change PCSrsPredF to ensure no effect
            #10;
            assert (PCSrc === 2'b00) else $fatal(1, "Non-branching prediction error");
            
        end
        
        //Check taken and untaken predictions
        Op = 2'b11; PCSrcPredF = 1;
        #10;
        assert (PCSrc == 2'b01) else $fatal(1, "Branch taken prediction error");
        
        PCSrcPredF = 0;
        #10;
        assert (PCSrc == 2'b00) else $fatal(1, "Branch untaken prediction error");
        
        //Check each output for rollback logic
        TargetMatchE = 1; BranchOpE[0] = 1; PCSrcPredE = 1; PCSrcResE = 1;
        RollbackAssertion(2'b00); //1111
        
        TargetMatchE = 0;
        RollbackAssertion(2'b11); //0111
        
        //Check for both values of all dont care signal TargetMatchE for future tests
        PCSrcResE = 0;
        RollbackAssertion(2'b10); //0110
        
        TargetMatchE = 1;
        RollbackAssertion(2'b10); //1110
        
        PCSrcResE = 1; PCSrcPredE = 0;
        RollbackAssertion(2'b11); //1101
        
        TargetMatchE = 0;
        RollbackAssertion(2'b11); //0101
        
        PCSrcResE = 0;
        RollbackAssertion(2'b00); //0100
        
        TargetMatchE = 1;
        RollbackAssertion(2'b00); //1100
        
        BranchOpE[0] = 0;
        
        //All combinations tested for when BranchOpE[0] = 0, ensure stage 1 output goes through
        for (int i = 0; i < 8; i++) begin
            
            test = i;
            
            TargetMatchE = test[0];
            PCSrcPredE = test[1];
            PCSrcResE = test[2];
            RollbackAssertion(2'b00);
            
        end
        
        $display("TEST PASSED");
        $finish;
        
    end

endmodule
