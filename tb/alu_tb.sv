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
    
    //Stimulus and expected results
    logic [31:0] A, B, ALUResult, ALUResultExpected;
    logic [3:0] ALUControl;
    logic N, Z, C, V, NExpected, ZExpected, CExpected, VExpected;
    
    //File reading signals
    int file;
    int read;
    
    //DUT instantiation
    alu DUT(ALUControl, A, B, ALUResult, N, Z, C, V);
    
    initial begin

        dump_setup;
    
        //Open file
        file = $fopen("ALU_test_vectors.txt", "r");

        if (file == 0) begin
            $fatal(1, "ERROR: Could not open test vector file");
        end
        
        while (!$feof(file)) begin
            read = $fscanf(file, "%b %b %b %b %b %b %b %b\n", 
                           ALUControl, A, B, ALUResultExpected, NExpected, ZExpected, CExpected, VExpected);
            
            if (read == 8) begin
                #5;
                assert (ALUResult == ALUResultExpected & NExpected == N & ZExpected == Z & CExpected == C & VExpected == V) else begin
                    $fatal(1, "Error: ALUControl = %b\nA = %b\nB = %b\nExpected Result: %b\nActual Result:   %b\nExpect Flags: N = %b Z = %b C = %b V = %b\nActual Flags: N = %b Z = %b C = %b V = %b", 
                           ALUControl, A, B, ALUResultExpected, ALUResult, NExpected, ZExpected, CExpected, VExpected, N, Z, C, V);
                end
            
            end else begin
                
                $fatal(1, "Incorrect number of arguments read");

            end
            
        end
        
        $display("TEST PASSED");
        $finish;
        
    end
    

endmodule
