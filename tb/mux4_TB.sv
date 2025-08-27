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


module mux4_TB();


    logic [31:0] d0, d1, d2, d3, y;
    logic [1:0] s;
    
    
    mux4 DUT(d0, d1, d2, d3, s, y);
    
    initial begin

        dump_setup;
        
        d0 = 1; d1 = 2; d2 = 4; d3 = 8;
        
        //Ensure data propagates properly for each select signal
        s = 2'b00; #10;
        assert (y === d0) else $fatal("Error (s = 0)");

        s = 2'b01; #10;    
        assert (y === d1) else $fatal("Error (s = 1)");
        
        s = 2'b10; #10;    
        assert (y === d2) else $fatal("Error (s = 2)");
        
        s = 2'b11; #10;    
        assert (y === d3) else $fatal("Error (s = 3)");
        
        //Ensure changing data results in the proper change in output
        d3 = 16; #10;
        assert (y === d3) else $fatal("Error: Input change");
        
        $display("Simulation Successful!");

    end

endmodule
