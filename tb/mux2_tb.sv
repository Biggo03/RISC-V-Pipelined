`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2024 04:34:33 PM
// Design Name: 
// Module Name: mux2_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for the mux2 module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux2_tb();
    
    //Generate signals for testing
    logic [31:0] d0, d1, y;
    logic s;
    
    mux2 u_DUT (d0, d1, s, y);

    initial begin
        
        dump_setup;

        //Set initial values of inputs
        d0 = 4; d1 = 1;
        
        //Test all valid values of s
        s = 0; #10;    
        assert (y == d0) else $display("Error");
        
        s = 1; #10;
        assert (y == d1) else $display("Error");
        
        //Ensure changing a value propogates
        d1 = 40; #10;
        assert (y == d1) else $display("Error");

        $display("TEST PASSED");
        $finish;
        
    end


endmodule
