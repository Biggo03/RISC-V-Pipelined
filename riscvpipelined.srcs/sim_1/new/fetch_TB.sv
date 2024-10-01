`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2024 02:03:39 PM
// Design Name: 
// Module Name: fetch_TB
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


module fetch_TB();
    
    //Signals to apply stimulus and check result
    logic clk, reset, PCSrcE, StallF;
    logic [31:0] PCTargetE, InstrF, PCF, PCPlus4F;
    
    logic [31:0] TestInstr [127:0];
    
    fetchstage DUT(clk, reset, PCTargetE, PCSrcE, StallF, InstrF, PCF, PCPlus4F);
    
    always begin
        clk = ~clk; #5;
    end
    
    
    initial begin
        
        //Initialize the system
        clk = 0; reset = 1; PCSrcE = 0; StallF = 0; PCTargetE = 0;
        $readmemh("riscvprogram_6.txt", TestInstr); 
        #1; reset = 0; #1;
        
        //Check to ensure that base reading from memory, calculation of PC, and PCPlus 4 works correctly
        for (int i = 0; i < 32; i++) begin
            assert (InstrF === TestInstr[i] & PCF === (i*4) & PCPlus4F === (i*4 + 4) ) else $fatal("Error: Base functionality");
            #10;
        end
        
        StallF = 1;
        //Check to ensure that stalling works correctly:
        //Note currently on instruction 32
        for (int i = 0; i < 32; i++) begin
             assert (InstrF === TestInstr[32] & PCF === (128) & PCPlus4F === 132) else $fatal("Error: Stall Error");
             #10;
        end
        
        StallF = 0; PCSrcE = 1; #10;
        //Check to ensure jumping results in correct output
        for (int i = 0; i < 32; i++) begin
            PCSrcE = 0;
            assert (InstrF === TestInstr[i] & PCF === (i*4) & PCPlus4F === (i*4 + 4) ) else $fatal("Error: Branch Error");
            #10;
        end
        
        $display("Simulation Succesful!");
        
        
    
    end
    

endmodule
