`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2024 05:33:46 PM
// Design Name: 
// Module Name: mux4_TB
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


module mux4_tb();


    logic [31:0] d0;
    logic [31:0] d1;
    logic [31:0] d2;
    logic [31:0] d3;
    logic [31:0] y;
    logic [1:0]  s;

    mux4 u_DUT (
        .d0                             (d0),
        .d1                             (d1),
        .d2                             (d2),
        .d3                             (d3),
        .s                              (s),
        .y                              (y)
    );
    
    initial begin

        dump_setup;
        
        d0 = 1; d1 = 2; d2 = 4; d3 = 8;
        
        //Ensure data propagates properly for each select signal
        s = 2'b00; #10;
        assert (y === d0) else $fatal(1, "Error (s = 0)");

        s = 2'b01; #10;    
        assert (y === d1) else $fatal(1, "Error (s = 1)");
        
        s = 2'b10; #10;    
        assert (y === d2) else $fatal(1, "Error (s = 2)");
        
        s = 2'b11; #10;    
        assert (y === d3) else $fatal(1, "Error (s = 3)");
        
        //Ensure changing data results in the proper change in output
        d3 = 16; #10;
        assert (y === d3) else $fatal(1, "Error: Input change");
        
        $display("TEST PASSED");

    end

endmodule
