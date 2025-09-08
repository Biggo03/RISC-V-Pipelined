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
    logic       pc_src_res_e;
    logic       enable;
    logic       pc_src_pred;
    logic [1:0] PCSrcPredExp;

    int error_cnt;

    local_predictor u_DUT (
        .clk_i                          (clk),
        .reset_i                        (reset),
        .pc_src_res_e_i                 (pc_src_res_e),
        .enable_i                       (enable),
        .pc_src_pred_o                  (pc_src_pred)
    );
    
    always begin
        clk = ~clk; #5;
    end
    
    
    initial begin

        dump_setup;
        error_cnt = 0;

        clk = 0; reset = 1; pc_src_res_e = 0; enable = 0; PCSrcPredExp = WU;
        
        #10;
    
        reset = 0;
    
        #10;
    
        `CHECK(pc_src_pred === 0, "[%t] Initialization Failed", $time)
        
        #10;
        
        enable = 1;
    
         //Check switching states works correctly
        for (int i = 0; i < 32; i = i + 1) begin
            `CHECK(pc_src_pred === PCSrcPredExp[1], "[%t] State change error", $time)
            
            if (i % 4 == 0) begin
                pc_src_res_e = ~pc_src_res_e;
            end
            
            #10;

            //Change expected after assertion, as transition occurs on next clock edge
            if (pc_src_res_e == 1 && PCSrcPredExp < 3) PCSrcPredExp = PCSrcPredExp + 1;
            else if (pc_src_res_e == 0 && PCSrcPredExp > 0) PCSrcPredExp = PCSrcPredExp - 1;
            
        end
        
        enable = 0;
        
        for (int i = 0; i < 32; i = i + 1) begin
            if (i % 4 == 0) begin
                pc_src_res_e = ~pc_src_res_e;
            end
                    
            #10;
        
            `CHECK(pc_src_pred === PCSrcPredExp, "[%t] enable Error", $time)
        end
        
        enable = 1; reset = 1;
        
        #50;
        
        `CHECK(pc_src_pred === 0, "[%t] Taken Reset failed", $time)
        
        if (error_cnt == 0) $display("TEST PASSED");
        else $display("TEST FAILED");
        $finish;
        
    end
    
    


endmodule
