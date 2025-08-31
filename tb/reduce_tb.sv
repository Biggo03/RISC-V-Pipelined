`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2024 03:08:14 PM
// Design Name: 
// Module Name: reduce_TB
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


module reduce_tb();

    logic [31:0] BaseResult;
    logic [2:0] WidthSrc;
    logic [31:0] Result, ResultExpected;
    
    int file;
    int read;
    int test_num;
    
    reduce DUT(BaseResult, WidthSrc, Result);
    
    initial begin

        dump_setup;
        
        read = 0;
        
        file = $fopen("test_inputs/vectors/reduce_test_vectors.txt", "r");

        if (file == 0) begin
            $fatal(1, "ERROR: Could not open test vector file");
        end else begin
            $display("Vector file opened succesfully");
        end
        
        
        //Iterate through file
        while (!$feof(file)) begin
            read = $fscanf(file, "%b %b %b\n", BaseResult, WidthSrc, ResultExpected);
            
            //Ensure file reads correct number of elements
            if (read == 3) begin
                #1;
                assert (Result == ResultExpected) else begin
                    $fatal(1, "Error: WidthSrc = %b, BaseResult = %b\nExpected output: %b\nActual output:   %b", 
                       WidthSrc, BaseResult, ResultExpected, Result);
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
