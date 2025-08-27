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


module extend_TB();

    logic [31:7] instr;
    logic [2:0] ImmSrc;
    logic [31:0] ImmExt, ImmExtExpected;
    
    int file;
    int read;
    int test_num;
    
    extend DUT(instr, ImmSrc, ImmExt);
    
    initial begin
        
        dump_setup;

        read = 0;
        
        file = $fopen("ext_unit_test_vectors.txt", "r");
        
        
        //Iterate through file
        while (!$feof(file)) begin
            read = $fscanf(file, "%b %b %b\n", instr, ImmSrc, ImmExtExpected);
            
            //Ensure file reads correct number of elements
            if (read == 3) begin
                #1;
                assert (ImmExt == ImmExtExpected) else begin
                    $fatal("Error: ImmSrc = %b, instr = %b\nExpected output: %b\nActual output:   %b", 
                       ImmSrc, instr, ImmExtExpected,ImmExt);
                end
                
            end else begin
                $fatal("Incorrect number of elements read");
            end
            
        end
        
        $display("Simulation Succesful!");
        
        $fclose(file);
        
    end;


endmodule
