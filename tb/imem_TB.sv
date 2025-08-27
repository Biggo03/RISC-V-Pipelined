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


module imem_TB();
    
    //Stimulus, output
    logic [31:0] A, RD;
    
    //Copy of memory to compare against
    logic [31:0] RAM [63:0];
    
    //Instantiate DUT
    instrmem DUT(A, RD);
    
    initial begin

        dump_setup;
        
        //Read file containing expected contents
        $readmemh("riscvprogram.txt", RAM);
        
        for (int i = 0; i < 64; i++) begin
            A = (i * 4); #10;
            
            assert (RD === RAM[i]) else $fatal("Error");
            
        end
        
        $display("Simulation Succesful!");
        
    end
    
endmodule
