`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 09:35:35 PM
// Design Name: 
// Module Name: InstrCacheController_TB
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


module InstrCacheController_TB();

    logic [5:0] Set;
    logic [63:0] MissArray, ActiveArray;
    logic CacheMiss;
    logic Stall;
    
    InstrCacheController DUT(.Stall(Stall),
                             .Set(Set),
                             .MissArray(MissArray),
                             .ActiveArray(ActiveArray),
                             .CacheMiss(CacheMiss));
    
    initial begin
    
        MissArray = 64'h0123456789ABCDEF;
        Stall = 0;
    
        for (int i = 0; i < 63; i = i + 1) begin
        
            Set = i;
            #5;
            assert(ActiveArray[i] === 1'b1) else $fatal("Incorrect active array");
            assert(CacheMiss === MissArray[i]) else $fatal("Incorrect cache miss value");
            
        end
        
        Stall = 1;
        for (int i = 0; i < 63; i = i + 1) begin
            Set = i;
            #5;
            assert(ActiveArray[i] === 1'b0) else $fatal("Stall Failed (ActiveArray)");
            assert(CacheMiss === 0) else $fatal("Stall Failed (CacheMiss)");
        end
    
        $display("Simulation Succesful!");
        
    end
    
endmodule
