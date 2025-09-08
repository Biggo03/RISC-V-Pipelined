`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2024 03:49:44 PM
// Design Name: 
// Module Name: writedecoder_TB
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


module write_decoder_tb();

    logic [4:0]  A;
    logic        WE;
    logic [31:0] en;
    int          enExpected;

    write_decoder u_DUT (
        .A                              (A),
        .WE                             (WE),
        .en                             (en)
    );
    
    
    initial begin

        dump_setup;
        WE = 1;
    
        for (int i = 0; i < 32; i++) begin
            A = i; 
            enExpected = 2**(i);
            
            #10;
            
            assert (enExpected == en) else $fatal(1, "Error");
            
        end
        
        $display("TEST PASSED");
        $finish;

    end

endmodule
