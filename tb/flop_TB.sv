`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2024 09:56:32 PM
// Design Name: 
// Module Name: flop_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for the flop module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module flop_TB();

    logic clk, en, reset;
    logic [31:0] D, Q;
    
    flop DUT(clk, en, reset, D, Q);
    
    initial begin

        dump_setup;

        //Initialize clock
        clk = 0;
        
        //Initialize register and base values
        reset = 1; en = 0; D = 1; #10; reset = 0; #10;
        
        //Enable register
        en = 1; #10;
        
        //Ensure Q changes with D accordingly
        assert (Q == 1) else $display("Propogation Error");
        
        D = 2; #10;
        assert (Q == 2) else $display("Propogation Error");
        
        //Ensure Q does not change when register not enabled
        en = 0; #10;
        
        D = 4; #10;
        assert (Q == 2) else $display("Enable Error");
        
        //Ensure Reset works properly (asynchronous)
        reset = 1; #5; 
        assert (Q == 0) else $display("Reset Error");
        
        
        $display("Simulation Complete");
    end
    
    
    //Generate clock signal
    always begin
        #5; clk = ~clk;
    end

endmodule
