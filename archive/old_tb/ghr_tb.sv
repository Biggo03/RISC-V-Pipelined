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
    logic [1:0]  BranchOpE;
    logic        PCSrcResE;
    logic        StallE;

    logic [1:0]  LocalSrc;
    logic [1:0]  LocalSrcExp;

    int          error_cnt;

    ghr u_DUT (
        .clk        (clk),
        .reset      (reset),
        .StallE     (StallE),
        .BranchOpE  (BranchOpE),
        .PCSrcResE  (PCSrcResE),
        .LocalSrc   (LocalSrc)
    );

    always begin
        clk = ~clk; #5;
    end

    initial begin

        dump_setup;
        error_cnt = 0;
        
        //Initialize System
        clk = 0; reset = 1; BranchOpE = 0; PCSrcResE = 0; StallE = 0; LocalSrcExp = UT;
        
        #10;
        
        reset = 0;
        
        #10;
        
        `CHECK(LocalSrc === UT, "[%t] Initialization Failed", $time)
        
        BranchOpE[0] = 1;
        
        //Check switching states works correctly
        for (int i = 0; i < 32; i = i + 1) begin
            if (i % 4 == 0) begin
                PCSrcResE = ~PCSrcResE;
            end
            
            if (PCSrcResE == 1) begin
                if (LocalSrcExp == UU || LocalSrcExp == TU) LocalSrcExp = UT;
                else if (LocalSrcExp == UT || LocalSrcExp == TT) LocalSrcExp = TT;
            end else begin
                if (LocalSrcExp == UU || LocalSrcExp == TU) LocalSrcExp = UU;
                else if (LocalSrcExp == UT || LocalSrcExp == TT) LocalSrcExp = TU;
            end
            
            #10;
            
            `CHECK(LocalSrc === LocalSrcExp, "[%t] State change error when LocalSrc in %b", $time, LocalSrc)
            
        end
        
        BranchOpE[0] = 0;
        
        //Check enable works correctly
        for (int i = 0; i < 32; i = i + 1) begin
            if (i % 4 == 0) begin
                PCSrcResE = ~PCSrcResE;
            end
            
            #10;
            
            `CHECK(LocalSrc === LocalSrcExp, "[%t] Enable Error", $time)
            
        end
        
        if (error_cnt == 0) $display("TEST PASSED");
        else $display("TEST FAILED");
        $finish;

    end

endmodule
