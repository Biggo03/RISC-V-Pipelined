`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2024 04:25:42 PM
// Design Name: 
// Module Name: decodestage_TB
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


module decodestage_TB();

    //signals for stimulus:
    logic clk, reset;
    logic [31:0] InstrF, PCF, PCPlus4F;
    logic [2:0] ImmSrcD;
    logic StallD, FlushD;
    
    //output signals
    logic [31:0] ImmExtD, PCD, PCPlus4D;
    logic [4:0] RdD, Rs1D, Rs2D;
    logic [6:0] OpD;
    logic [2:0] funct3D;
    logic funct7b5D;
    
    //Signals for holding expected values: (wont test ImmExtD, as that is entirely due to extension unit
    logic [31:0] PCD_TB, PCPlus4D_TB;
    logic [4:0] RdD_TB, Rs1D_TB, Rs2D_TB;
    logic [6:0] OpD_TB;
    logic [2:0] funct3D_TB;
    logic funct7b5D_TB;
    
    decodestage DUT(clk, reset, InstrF, PCF, PCPlus4F, ImmSrcD, StallD, FlushD, ImmExtD, PCD, PCPlus4D,
                    RdD, Rs1D, Rs2D, OpD, funct3D, funct7b5D);
    
    
    initial begin
        
    end
    
endmodule
