`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2024 02:48:27 PM
// Design Name: 
// Module Name: extend_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for the extend module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module imm_extend_tb();

    logic [31:7] instr;
    logic [2:0] ImmSrc;
    logic [31:0] ImmExt, ImmExtExpected;
    
    int file;
    int read;
    int test_num;
    
    imm_extend u_DUT (instr, ImmSrc, ImmExt);
    
    initial begin
        
        dump_setup;

        read = 0;
        
        file = $fopen("test_inputs/vectors/ext_unit_test_vectors.txt", "r");

        if (file == 0) begin
            $fatal(1, "ERROR: Could not open test vector file");
        end else begin
            $display("Vector file opened succesfully");
        end
        
        
        //Iterate through file
        while (!$feof(file)) begin
            read = $fscanf(file, "%b %b %b\n", instr, ImmSrc, ImmExtExpected);
            
            //Ensure file reads correct number of elements
            if (read == 3) begin
                #1;
                assert (ImmExt == ImmExtExpected) else begin
                    $fatal(1, "Error: ImmSrc = %b, instr = %b\nExpected output: %b\nActual output:   %b", 
                       ImmSrc, instr, ImmExtExpected,ImmExt);
                end
                
            end else begin
                $fatal(1, "Incorrect number of elements read");
            end
            
        end
        
        $display("TEST PASSED");
        $fclose(file);
        $finish;
        
    end


endmodule
