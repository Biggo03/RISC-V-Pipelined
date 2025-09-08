`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2024 09:34:13 PM
// Design Name: 
// Module Name: rf_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for rf (register file) module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module reg_file_tb();
    
    // Stimulus
    logic        clk;
    logic        reset;
    logic        we3;
    logic [4:0]  a1;
    logic [4:0]  a2;
    logic [4:0]  a3;
    logic [31:0] rd1;
    logic [31:0] rd2;
    logic [31:0] wd3;

    // File reading signals
    int file;
    int read;

    // u_DUT instantiation
    reg_file u_DUT (
        .clk_i                          (clk),
        .reset_i                        (reset),
        .a1_i                           (a1),
        .a2_i                           (a2),
        .a3_i                           (a3),
        .wd3_i                          (wd3),
        .we3_i                          (we3),
        .rd1_o                          (rd1),
        .rd2_o                          (rd2)
    );
    
    always begin
        clk = ~clk; #5;
    end
    
    initial begin

        dump_setup;
        
        //initialize clock registers, and set we3
        clk = 0; we3 = 0; reset = 1; #10; reset = 0;
        
        
        //Ensure reset worked properly, test both read ports
        for (int i = 0; i < 32; i++) begin
            a1 = i; a2 = i; #10;
            
            assert (rd1 == 0 & rd2 == 0) else $fatal(1, "Error: Initialization failed");
            
        end
        
        //Populate registers with unique values
        for (int i = 0; i < 2; i++) begin
        
            //Check register Writing
            if (i == 0) begin
                
                we3 = 1;
                
                for (int i = 0; i < 32; i++) begin
                    a1 = i; a2 = i; a3 = i; wd3 = i; #10;
            
                    assert (rd1 == i & rd2 == i) else $fatal(1, "Error: Writing error");
            
                end
                
            end else begin
                
                we3 = 0;
                
                for (int i = 0; i < 32; i++) begin
                    a1 = i; a2 = i; a3 = i; wd3 = 100; #10;

                    assert (rd1 == i & rd2 == i) else $display("Error: Register written when we3 = 0");
            
                end
            
            end
            
        end
        
        //Ensure writing to 0 register not possible
        we3 = 1; a1 = 0; a2 = 0; a3 = 0; wd3 = 1; #10;
        assert (rd1 == 0 & rd2 == 0) else $fatal(1, "Error: Zero register updated");
        
        $display("TEST PASSED");
        $finish;
        
    end
    
endmodule
