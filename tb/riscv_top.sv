`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2024 09:34:38 PM
// Design Name: 
// Module Name: top_level_TB
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

 module riscv_top_tb();
    
    logic clk, reset, MemWrite;
    logic [31:0] WriteData, DataAdr;
    
    riscv_top DUT(clk, reset, WriteData, DataAdr, MemWrite);
    
    initial begin

        dump_setup;

        MemWrite = 0;
        clk = 0; reset = 1; #20; reset = 0;
    end
    
    always begin
        clk = ~clk; #5;
    end
    
    always @(negedge clk) begin
        
        if (MemWrite & DataAdr > 90 & DataAdr < 120) begin
            if (DataAdr === 100 & WriteData === 25) begin
                $display("Success!");
                $stop;
            end else if (DataAdr !== 96) begin
            $display("Failed.");
            $stop;
            
            end
        end
   
    end
    
endmodule
