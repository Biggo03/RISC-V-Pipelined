`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2024 08:39:02 PM
// Design Name: 
// Module Name: mux5_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for the mux5 module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux5_TB();
    
    //generate signals used for testing
    logic [31:0] d0, d1, d2, d3, d4, y;
    logic [2:0] s;
    
    mux5 DUT(d0, d1, d2, d3, d4, s, y);
    
    initial begin

        dump_setup;
    
        d0 = 1; d1 = 2; d2 = 4; d3 = 8; d4 = 16; 
        
        //Test all valid values of s
        s = 3'b000; #10;
        assert (y == d0) else $display("Error (s = 0)");
        
        s = 3'b001; #10;
        assert (y == d1) else $display("Error (s = 1)");
        
        s = 3'b010; #10;
        assert (y == d2) else $display("Error (s = 2)");
        
        s = 3'b011; #10;
        assert (y == d3) else $display("Error (s = 3)");
        
        s = 3'b100; #10;
        assert (y == d4) else $display("Error (s = 4)");
        
        //Ensure changing a value propogates
        d4 = 32; #10;
        assert (y == d4) else $display("Error (input change)");
        
        //Value should remain unchanged as s goes to invalid values
        s = 3'b101; #10;
        assert (y == d4) else $display("Error (select invalid, output change)");
        
        s = 3'b110; #10;
        assert (y == d4) else $display("Error (select invalid, output change)");
         
        s = 3'b111; #10;
        assert (y == d4) else $display("Error (select invalid, output change)");
        
    end

endmodule
