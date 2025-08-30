`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2025 11:17:37 AM
// Design Name: 
// Module Name: LocalPredictor_TB
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


module local_predictor_tb();

    localparam ST = 2'b11;
    localparam WT = 2'b10;
    localparam WU = 2'b01;
    localparam SU = 2'b00;
    
    logic clk, reset, PCSrcResE, Enable, PCSrcPred;
    logic [1:0] PCSrcPredExp;
    
    local_predictor DUT(clk, reset, PCSrcResE, Enable, PCSrcPred);
    
    always begin
        clk = ~clk; #5;
    end
    
    
    initial begin

        dump_setup;

        clk = 0; reset = 1; PCSrcResE = 0; Enable = 0; PCSrcPredExp = WU;
        
        #10;
    
        reset = 0;
    
        #10;
    
        assert(PCSrcPred === 0) else $fatal(1, "Initialization Failed");
        
        #5;
        
        Enable = 1;
    
         //Check switching states works correctly
        for (int i = 0; i < 32; i = i + 1) begin
            if (i % 4 == 0) begin
                PCSrcResE = ~PCSrcResE;
            end
            
            #10;
            
            assert(PCSrcPred === PCSrcPredExp[1]) else $fatal(1, "State change error");
            
            //Change expected after assertion, as transition occurs on next clock edge
            if (PCSrcResE == 1 && PCSrcPredExp < 3) PCSrcPredExp = PCSrcPredExp + 1;
            else if (PCSrcResE == 0 && PCSrcPredExp > 0) PCSrcPredExp = PCSrcPredExp - 1;
            
        end
        
        Enable = 0;
        
        for (int i = 0; i < 32; i = i + 1) begin
            if (i % 4 == 0) begin
                PCSrcResE = ~PCSrcResE;
            end
                    
            #10;
        
            assert (PCSrcPred === PCSrcPredExp) else $fatal(1, "Enable Error");
        end
        
        Enable = 1; reset = 1;
        
        #50;
        
        assert (PCSrcPred === 0) else $fatal(1, "Taken Reset failed");
        
        
        $display("TEST PASSED");
        $finish;
        
    end
    
    


endmodule
