`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2024 01:55:15 PM
// Design Name: 
// Module Name: imem_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for instrmem module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instr_mem_tb();
    
    // Stimulus, output
    logic [31:0] pc_f;
    logic [31:0] instr_f;

    // Copy of memory to compare against
    logic [31:0] RAM [127:0];

    // Instantiate DUT
    instr_mem u_DUT (
        // Address & data inputs
        .addr                         (pc_f),

        // Data outputs
        .rd_o                         (instr_f),

        // Status outputs
        .instr_miss_f_o               (instr_miss_f),
        .instr_cache_rep_en_o         (instr_cache_rep_en)
    );
    
    initial begin

        dump_setup;
        
        //Read file containing expected contents
        $readmemh("test_inputs/riscvprograms/riscvprogram_7.txt", RAM);
        
        for (int i = 0; i < 64; i++) begin
            pc_f = (i * 4); #10;
            
            assert (instr_f === RAM[i]) else $fatal(1, "Error");
            assert (instr_miss_f === 1'b0) else $fatal(1, "Error");
            assert (instr_cache_rep_en === 1'b1) else $fatal(1, "Error");
            
        end
        
        $display("TEST PASSED");
        $finish;
        
    end
    
endmodule
