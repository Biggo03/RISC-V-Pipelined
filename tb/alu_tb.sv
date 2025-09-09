`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2024 10:34:44 AM
// Design Name: 
// Module Name: ALU_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for ALU module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_tb();
    
    // Stimulus and expected results
    logic [31:0] A;
    logic [31:0] B;
    logic [31:0] alu_result;
    logic [31:0] ALUResultExpected;
    logic [3:0]  alu_control;
    logic        neg_flag;
    logic        zero_flag;
    logic        carry_flag;
    logic        v_flag;
    logic        neg_flagExpected;
    logic        zero_flagExpected;
    logic        carry_flagExpected;
    logic        v_flagExpected;

    // File reading signals
    int file;
    int read;

    // u_DUT instantiation
    alu u_DUT (
        .alu_control_i                  (alu_control),
        .A                              (A),
        .B                              (B),
        .alu_result_o                   (alu_result),
        .neg_flag_o                     (neg_flag),
        .zero_flag_o                    (zero_flag),
        .carry_flag_o                   (carry_flag),
        .v_flag_o                       (v_flag)
    );
    
    initial begin

        dump_setup;
    
        //Open file
        file = $fopen("test_inputs/vectors/ALU_test_vectors.txt", "r");

        if (file == 0) begin
            $fatal(1, "ERROR: Could not open test vector file");
        end else begin
            $display("Vector file opened succesfully");
        end
        
        
        while (!$feof(file)) begin
            read = $fscanf(file, "%b %b %b %b %b %b %b %b\n", 
                           alu_control, A, B, ALUResultExpected, neg_flagExpected, zero_flagExpected, carry_flagExpected, v_flagExpected);
            
            if (read == 8) begin
                #5;
                assert (alu_result == ALUResultExpected & neg_flagExpected == neg_flag & zero_flagExpected == zero_flag & carry_flagExpected == carry_flag & v_flagExpected == v_flag) else begin
                    $fatal(1, "Error: alu_control = %b\nA = %b\nB = %b\nExpected result: %b\nActual result:   %b\nExpect Flags: neg_flag = %b zero_flag = %b carry_flag = %b v_flag = %b\nActual Flags: neg_flag = %b zero_flag = %b carry_flag = %b v_flag = %b", 
                           alu_control, A, B, ALUResultExpected, alu_result, neg_flagExpected, zero_flagExpected, carry_flagExpected, v_flagExpected, neg_flag, zero_flag, carry_flag, v_flag);
                end
            
            end else begin
                
                $fatal(1, "Incorrect number of arguments read");

            end
            
        end
        
        $display("TEST PASSED");
        $finish;
        
    end
    

endmodule
