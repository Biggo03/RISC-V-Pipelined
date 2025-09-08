`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/18/2025 07:26:21 PM
// Design Name: 
// Module Name: GHR_TB
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


module ghr_tb();
    `include "tb_macros.sv"

    // Local parameters for state bits. Output matches state bits
    localparam UU = 2'b00;
    localparam UT = 2'b01;
    localparam TU = 2'b10;
    localparam TT = 2'b11;

    logic        clk;
    logic        reset;
    logic [1:0]  branch_op_e;
    logic        pc_src_res_e;
    logic        stall_e;

    logic [1:0]  local_src;
    logic [1:0]  LocalSrcExp;

    int          error_cnt;

    ghr u_DUT (
        .clk_i                          (clk),
        .reset_i                        (reset),
        .stall_e_i                      (stall_e),
        .branch_op_e_i                  (branch_op_e),
        .pc_src_res_e_i                 (pc_src_res_e),
        .local_src_o                    (local_src)
    );

    always begin
        clk = ~clk; #5;
    end

    initial begin

        dump_setup;
        error_cnt = 0;
        
        //Initialize System
        clk = 0; reset = 1; branch_op_e = 0; pc_src_res_e = 0; stall_e = 0; LocalSrcExp = UT;
        
        #10;
        
        reset = 0;
        
        #10;
        
        `CHECK(local_src === UT, "[%t] Initialization Failed", $time)
        
        branch_op_e[0] = 1;
        
        //Check switching states works correctly
        for (int i = 0; i < 32; i = i + 1) begin
            if (i % 4 == 0) begin
                pc_src_res_e = ~pc_src_res_e;
            end
            
            if (pc_src_res_e == 1) begin
                if (LocalSrcExp == UU || LocalSrcExp == TU) LocalSrcExp = UT;
                else if (LocalSrcExp == UT || LocalSrcExp == TT) LocalSrcExp = TT;
            end else begin
                if (LocalSrcExp == UU || LocalSrcExp == TU) LocalSrcExp = UU;
                else if (LocalSrcExp == UT || LocalSrcExp == TT) LocalSrcExp = TU;
            end
            
            #10;
            
            `CHECK(local_src === LocalSrcExp, "[%t] State change error when local_src in %b", $time, local_src)
            
        end
        
        branch_op_e[0] = 0;
        
        //Check enable works correctly
        for (int i = 0; i < 32; i = i + 1) begin
            if (i % 4 == 0) begin
                pc_src_res_e = ~pc_src_res_e;
            end
            
            #10;
            
            `CHECK(local_src === LocalSrcExp, "[%t] enable Error", $time)
            
        end
        
        if (error_cnt == 0) $display("TEST PASSED");
        else $display("TEST FAILED");
        $finish;

    end

endmodule
