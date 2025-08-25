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


module writedecoder_TB();

    logic [4:0] A;
    logic [31:0] en;
    int enExpected;
    
    writedecoder DUT(A, en);
    
    
    initial begin
    
        for (int i = 0; i < 32; i++) begin
            A = i; 
            enExpected = 2**(i);
            
            #10;
            
            assert (enExpected == en) else $fatal("Error");
            
        end
        
        $display("Simulation Succesful!");
    
    end

endmodule
