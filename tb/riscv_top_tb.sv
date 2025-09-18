`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2024 09:34:38 PM
// Design Name: 
// Module Name: top_level_TB
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

 module riscv_top_tb();
    
    logic        clk;
    logic        reset;

    logic [31:0] write_data_m;
    logic [31:0] alu_result_m;
    logic        mem_write_m;

    int cycle_cnt;
    
    
    riscv_top u_riscv_top (
        // Clock & reset
        .clk_i                          (clk),
        .reset_i                        (reset),

        // Memory outputs
        .write_data_m_o                 (write_data_m),
        .alu_result_m_o                 (alu_result_m),
        .mem_write_m_o                  (mem_write_m)
    );
    
    initial begin

        dump_setup;

        cycle_cnt = 0;
        clk = 0; 
        reset = 1; #20; reset = 0;

    end
    
    always begin
        clk = ~clk; 
        #5;
        cycle_cnt = cycle_cnt + 1;
    end
    
    always @(negedge clk) begin

        if (cycle_cnt > 10000) $finish;
        
        if (mem_write_m & alu_result_m > 90 & alu_result_m < 120) begin
            if (alu_result_m === 100 & write_data_m === 25) begin
                $display("TEST PASSED");
                $finish;
            end else if (alu_result_m !== 96) begin
            $display("Failed.");
            $finish;
            end
        end
   
    end
    
endmodule
