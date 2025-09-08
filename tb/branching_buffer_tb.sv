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


    logic        clk;
    logic        reset;
    logic [31:0] pc_target_e;
    logic [9:0]  pc_f;
    logic [9:0]  pc_e;
    logic [1:0]  local_src;
    logic [1:0]  branch_op_e;
    logic        pc_src_res_e;
    logic        target_match;
    logic        pc_src_pred_f;
    logic [31:0] pred_pc_target_f;

    int error_cnt;

    branching_buffer u_DUT (
        .clk_i                          (clk),
        .reset_i                        (reset),
        .pc_target_e_i                  (pc_target_e),
        .pc_f_i                         (pc_f),
        .pc_e                           (pc_e),
        .local_src_i                    (local_src),
        .pc_src_res_e_i                 (pc_src_res_e),
        .target_match_i                 (target_match),
        .branch_op_e_i                  (branch_op_e),
        .pc_src_pred_f_o                (pc_src_pred_f),
        .pred_pc_target_f_o             (pred_pc_target_f)
    );

    always begin
        clk = ~clk; #5;
    end
    
    initial begin

        dump_setup;
        error_cnt = 0;
        
        //Initialize
        clk = 0; reset = 1; pc_target_e = 0; pc_f = 0; pc_e = 0; local_src = 0;
        pc_src_res_e = 0; target_match = 0; branch_op_e = 0;
        
        #100;
        reset = 0;

        #100;
        branch_op_e[0] = 1;
        
        //Start by populating entries with target addresses
        for (int i = 0; i < 1024; i++) begin
            pc_e = i;
            pc_target_e = i;
            #10;
        end
        
        branch_op_e[0] = 0;
        target_match = 1;
        
        //Check if correct address is fetched by pc_f
        for (int i = 0; i < 1024; i = i + 1) begin
            pc_f = i;
            #10;
            `CHECK(pred_pc_target_f === i, "[%t] Incorrect target address", $time)
        end
        
        //Check to see if branch updates work correctly (Should be in WU)
        pc_e = 0; pc_f = 0; local_src = 0; branch_op_e[0] = 1; pc_src_res_e = 1;
        #10;
        `CHECK(pc_src_pred_f === 1, "[%t] Local predictor transition failed (first)", $time)
        
        //Put back into WU
        pc_src_res_e = 0;
        #10;
        `CHECK(pc_src_pred_f === 0, "[%t] Local predictor transition failed (third)", $time)
        
        //Put 1st index into strongly taken state
        pc_src_res_e = 1;
        #20;
        
        //Put scond index local predictor into WT
        pc_e = 1;
        #21; 
        
        //Trigger reset of first indexed local predictor
        pc_e = 0; target_match = 0; pc_target_e = 1000; pc_src_res_e = 0;
        #10;
        `CHECK(pc_src_pred_f === 0 && pred_pc_target_f == 1000, "[%t] Local reset failed (first)", $time)

        
        //Ensure no other predictors changes
        pc_f = 1;
        #10;
        `CHECK(pc_src_pred_f === 1, "[%t] Local reset failed (second)", $time)
        
        //Ensure taking correct local predictor based on local_src
        pc_e = 100; pc_target_e = 1001; local_src = 1; target_match = 0; pc_src_res_e = 1;
        #10;
        `CHECK(pc_src_pred_f === 0 && pred_pc_target_f == 1, "[%t] local_src indexed incorrectly", $time)
        
        //Test to see if replacement for PCE100 worked correctly, and if local predictor updated properly
        //
        target_match = 1; pc_f = 100;
        #20;
        `CHECK(pc_src_pred_f === 1 && pred_pc_target_f === 1001, "[%t] Incorrect local branch update on change (first)", $time)

        //Ensure other local predictors not changed
        local_src = 0; pc_src_res_e = 0;
        #10;
        `CHECK(pc_src_pred_f === 0 && pred_pc_target_f === 1001, "[%t] Incorrect local branch update on change (second)", $time)
        
        pc_src_res_e = 1;
        #20; //Wait two cycles for local predictor to be in weakly taken
        `CHECK(pc_src_pred_f === 1 && pred_pc_target_f === 1001, "[%t] Incorrect local branch update on change (second)", $time)
        
        if (error_cnt == 0) $display("TEST PASSED");
        else $display("TEST FAILED");
        $finish;
        
    end

endmodule
