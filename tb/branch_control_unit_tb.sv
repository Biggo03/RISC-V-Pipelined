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

    logic [1:0] op;
    logic       pc_src_pred_f;
    logic       pc_src_pred_e;
    logic       target_match_e;
    logic       pc_src_res_e;
    logic [1:0] branch_op_e;
    logic [1:0] pc_src;

    logic [2:0] test;

    branch_control_unit u_DUT (
        .op_f_i                         (op),
        .pc_src_pred_f_i                (pc_src_pred_f),
        .pc_src_pred_e_i                (pc_src_pred_e),
        .branch_op_e_i                  (branch_op_e),
        .target_match_e_i               (target_match_e),
        .pc_src_res_e_i                 (pc_src_res_e),
        .pc_src_o                       (pc_src)
    );
    
    task RollbackAssertion(input logic [1:0] val);
                #10;
                assert (pc_src === val) else $fatal(1, "Rollback Error\nInputs: target_match_e: %b branch_op_e[0]: %b, pc_src_pred_e: %b, pc_src_res_e: %b\nOutput: pc_src: %b",target_match_e,branch_op_e[0] , pc_src_pred_e, pc_src_res_e, pc_src);
    endtask

    initial begin
        
        dump_setup;

        op = 0; pc_src_pred_f = 0; pc_src_pred_e = 0; 
        branch_op_e = 0; target_match_e = 0; pc_src_res_e = 0;
        
        //When branch_op_e[0] = 0, should only get output from prediction logic
        //Will use this to ensure first stage outputs are as expected.
        for (int i = 0; i < 3; i++) begin
            
            op = i;
            pc_src_pred_f = ~pc_src_pred_f; //Change PCSrsPredF to ensure no effect
            #10;
            assert (pc_src === 2'b00) else $fatal(1, "Non-branching prediction error");
            
        end
        
        //Check taken and untaken predictions
        op = 2'b11; pc_src_pred_f = 1;
        #10;
        assert (pc_src == 2'b01) else $fatal(1, "Branch taken prediction error");
        
        pc_src_pred_f = 0;
        #10;
        assert (pc_src == 2'b00) else $fatal(1, "Branch untaken prediction error");
        
        //Check each output for rollback logic
        target_match_e = 1; branch_op_e[0] = 1; pc_src_pred_e = 1; pc_src_res_e = 1;
        RollbackAssertion(2'b00); //1111
        
        target_match_e = 0;
        RollbackAssertion(2'b11); //0111
        
        //Check for both values of all dont care signal target_match_e for future tests
        pc_src_res_e = 0;
        RollbackAssertion(2'b10); //0110
        
        target_match_e = 1;
        RollbackAssertion(2'b10); //1110
        
        pc_src_res_e = 1; pc_src_pred_e = 0;
        RollbackAssertion(2'b11); //1101
        
        target_match_e = 0;
        RollbackAssertion(2'b11); //0101
        
        pc_src_res_e = 0;
        RollbackAssertion(2'b00); //0100
        
        target_match_e = 1;
        RollbackAssertion(2'b00); //1100
        
        branch_op_e[0] = 0;
        
        //All combinations tested for when branch_op_e[0] = 0, ensure stage 1 output goes through
        for (int i = 0; i < 8; i++) begin
            
            test = i;
            
            target_match_e = test[0];
            pc_src_pred_e = test[1];
            pc_src_res_e = test[2];
            RollbackAssertion(2'b00);
            
        end
        
        $display("TEST PASSED");
        $finish;
        
    end

endmodule
