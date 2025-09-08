`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2025 10:13:14 PM
// Design Name: 
// Module Name: DirL1InstrCache_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:Already tested more complex functionality at set level, will leave at ensuring basic functions work
//
//////////////////////////////////////////////////////////////////////////////////

module icache_l1_dir_tb();
    `include "tb_macros.sv"
    
    // Test cache parameters
    localparam S         = 32;
    localparam E         = 4;
    localparam B         = 64;
    localparam words     = B/4;
    localparam RepCycles = words/2;

    localparam s          = $clog2(S);
    localparam b          = $clog2(B);
    localparam NumTagBits = 32-s-b;

    // DUT signals
    logic        clk;
    logic        reset;
    logic        RepReady;
    logic [31:0] pc_f;
    logic [31:0] instr_f;
    logic [63:0] RepWord;
    logic [1:0]  pc_src_reg;
    logic [1:0]  branch_op_e;
    logic        instr_miss_f;
    logic        instr_cache_rep_active;

    // Signals to make addressing more intuitive
    logic [b-1:0] ByteAddr;
    logic [s-1:0] SetNum;

    // Store blocks
    logic [(B*8)-1:0] RepBlocks [S-1:0][E-1:0];

    // Stores tag of each block
    logic [NumTagBits-1:0] Tags [S-1:0][E-1:0];

    int error_cnt;

    icache_l1 #( //u_icache_l1 (
        .S                              (S),
        .E                              (E),
        .B                              (B)
    ) u_DUT (
        .clk_i                          (clk),
        .reset_i                        (reset),
        .RepReady                       (RepReady),
        .pc_f_i                         (pc_f),
        .RepWord                        (RepWord),
        .pc_src_reg_i                   (pc_src_reg),
        .branch_op_e_i                  (branch_op_e),
        .instr_f_o                      (instr_f),
        .instr_miss_f_o                 (instr_miss_f),
        .instr_cache_rep_active_o       (instr_cache_rep_active)
    );

    always begin
        clk = ~clk; #5;
    end
    
    initial begin

        dump_setup;

        reset = 1; clk = 0; branch_op_e = 0; pc_src_reg = 0; #100; reset = 0; 
        
        //Fill up cache and check initial reads
        for (int i = 0; i < S; i = i + 1) begin
            SetNum = i;
            ByteAddr = 0;
            pc_f[b-1:0] = ByteAddr;
            pc_f[s+b-1:b] = SetNum;
            for (int n = 0; n < E; n = n + 1) begin
                //set and store unique tag for block
                pc_f[31:s+b] = (i * 8) + n**3;
                Tags[i][n] = pc_f[31:s+b];
                #10;
                RepReady = 1;
                
                //Do replacement
                for (int k = 0; k < RepCycles; k = k + 1) begin
                    if (i == 0) begin
                        RepWord[31:0] = k;
                        RepWord[63:32] = k**2;
                    end else begin
                        RepWord[31:0] = (i * 1111) * k**2 + i**2;
                        RepWord[63:32] = (i * 2222) * k**2 + i**2;
                    end 
                    
                    RepBlocks[i][n][k*64 +: 64] = RepWord;
                    #10;
                end
                RepReady = 0;
                
                //Check 
                for (int k = 0; k < words; k = k + 1) begin
                    ByteAddr = k * 4;
                    pc_f[b-1:0] = ByteAddr;
                    #10;
                    `CHECK(instr_f === RepBlocks[i][n][k*32 +: 32] && instr_miss_f === 0, "[%t] Population Read Error", $time)
                end
            end
        end
        
        //Reread
        for (int i = 0; i < S; i = i + 1) begin
            SetNum = i;
            pc_f[s+b-1:b] = SetNum;
            pc_f[31:s+b] = Tags[i][0];
            #10;
            for (int n = 0; n < E; n = n + 1) begin
                for (int k = 0; k < words; k = k + 1) begin
                    ByteAddr = k * 4;
                    pc_f[b-1:0] = ByteAddr;
                    #10;
                    `CHECK(instr_f === RepBlocks[i][n][k*32 +: 32] && instr_miss_f === 0, "[%t] Reread Read Error", $time)
                end
            end
            
        end
        
        if (error_cnt == 0) $display("TEST PASSED");
        else $display("TEST FAILED");
        $finish;
    end
              

endmodule
