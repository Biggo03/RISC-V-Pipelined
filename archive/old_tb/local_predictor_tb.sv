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
    `include "tb_macros.sv"

    localparam ST = 2'b11;
    localparam WT = 2'b10;
    localparam WU = 2'b01;
    localparam SU = 2'b00;

    logic       clk;
    logic       reset;
    logic       PCSrcResE;
    logic       Enable;
    logic       PCSrcPred;
    logic [1:0] PCSrcPredExp;

    int error_cnt;

    local_predictor u_DUT (
        .clk        (clk),
        .reset      (reset),
        .PCSrcResE  (PCSrcResE),
        .Enable     (Enable),
        .PCSrcPred  (PCSrcPred)
    );
    
    always begin
        clk = ~clk; #5;
    end
    
    
    initial begin

        dump_setup;
        error_cnt = 0;

        clk = 0; reset = 1; PCSrcResE = 0; Enable = 0; PCSrcPredExp = WU;
        
        #10;
    
        reset = 0;
    
        #10;
    
        `CHECK(PCSrcPred === 0, "[%t] Initialization Failed", $time)
        
        #10;
        
        Enable = 1;
    
         //Check switching states works correctly
        for (int i = 0; i < 32; i = i + 1) begin
            `CHECK(PCSrcPred === PCSrcPredExp[1], "[%t] State change error", $time)
            
            if (i % 4 == 0) begin
                PCSrcResE = ~PCSrcResE;
            end
            
            #10;

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
        
            `CHECK(PCSrcPred === PCSrcPredExp, "[%t] Enable Error", $time)
        end
        
        Enable = 1; reset = 1;
        
        #50;
        
        `CHECK(PCSrcPred === 0, "[%t] Taken Reset failed", $time)
        
        if (error_cnt == 0) $display("TEST PASSED");
        else $display("TEST FAILED");
        $finish;
        
    end
    
    


endmodule
