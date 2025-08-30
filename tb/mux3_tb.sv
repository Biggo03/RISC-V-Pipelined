`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2024 07:28:47 PM
// Design Name: 
// Module Name: mux3_TB
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


module mux3_tb();

    logic [31:0] d0, d1, d2, y;
    logic [1:0] s;
    
    
    mux3 DUT(d0, d1, d2, s, y);
    
    initial begin

        dump_setup;
        
        d0 = 1; d1 = 2; d2 = 4;
        
        //Ensure data propagates properly for each select signal
        s = 2'b00; #10;
        assert (y === d0) else $fatal("Error (s = 0)");

        s = 2'b01; #10;    
        assert (y === d1) else $fatal("Error (s = 1)");
        
        s = 2'b10; #10;    
        assert (y === d2) else $fatal("Error (s = 2)");
        
        //Ensure changing data results in the proper change in output
        d2 = 16; #10;
        assert (y === d2) else $fatal("Error: Input change");
        
        
        //Ensure value doesn't change when s goes to invalid value
        s = 2'b11; #10;
        assert (y === d2) else $fatal("Error: Invalid s lead to change");
        
        $display("Simulation Successful!");

    end

endmodule
