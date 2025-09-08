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
    logic        N;
    logic        Z;
    logic        C;
    logic        V;
    logic        NExpected;
    logic        ZExpected;
    logic        CExpected;
    logic        VExpected;

    // File reading signals
    int file;
    int read;

    // u_DUT instantiation
    alu u_DUT (
        .alu_control_i                  (alu_control),
        .A                              (A),
        .B                              (B),
        .alu_result_o                   (alu_result),
        .N                              (N),
        .Z                              (Z),
        .C                              (C),
        .V                              (V)
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
                           alu_control, A, B, ALUResultExpected, NExpected, ZExpected, CExpected, VExpected);
            
            if (read == 8) begin
                #5;
                assert (alu_result == ALUResultExpected & NExpected == N & ZExpected == Z & CExpected == C & VExpected == V) else begin
                    $fatal(1, "Error: alu_control = %b\nA = %b\nB = %b\nExpected Result: %b\nActual Result:   %b\nExpect Flags: N = %b Z = %b C = %b V = %b\nActual Flags: N = %b Z = %b C = %b V = %b", 
                           alu_control, A, B, ALUResultExpected, alu_result, NExpected, ZExpected, CExpected, VExpected, N, Z, C, V);
                end
            
            end else begin
                
                $fatal(1, "Incorrect number of arguments read");

            end
            
        end
        
        $display("TEST PASSED");
        $finish;
        
    end
    

endmodule
