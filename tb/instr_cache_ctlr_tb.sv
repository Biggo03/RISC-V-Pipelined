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


module instr_cache_ctlr_tb();

    logic [5:0] Set;
    logic [63:0] MissArray, ActiveArray;
    logic CacheMiss;
    logic Stall;
    
    logic clk, reset;
    logic [1:0] PCSrcReg, BranchOpE;
    logic CacheRepActive;
    
    instr_cache_ctlr u_DUT (.clk(clk),
                             .reset(reset),
                             .Set(Set),
                             .MissArray(MissArray),
                             .PCSrcReg(PCSrcReg),
                             .BranchOpE(BranchOpE),
                             .ActiveArray(ActiveArray),
                             .CacheMiss(CacheMiss),
                             .CacheRepActive(CacheRepActive));
    
    always begin
        clk = ~clk; #5;
    end
    
    initial begin

        dump_setup;
    
        MissArray = 64'h0123456789ABCDEF; clk = 0; reset = 1;
    
        //Combinational output test
        for (int i = 0; i < 63; i = i + 1) begin
        
            Set = i;
            #5;
            assert(ActiveArray[i] === 1'b1) else $fatal(1, "Incorrect active array");
            assert(CacheMiss === MissArray[i]) else $fatal(1, "Incorrect cache miss value");
            
        end
        
        //FSM test
        reset = 0; BranchOpE[1] = 0; PCSrcReg[0] = 0;
        
        //Normal operation hit
        BranchOpE[0] = 0; MissArray = 0; PCSrcReg[1] = 0;
        #10;
        assert(u_DUT.DelayApplied === 0 & CacheRepActive === 1) else $fatal(1, "Normal operation hit fail");
        
        //Normal operation miss
        MissArray = '1;
        #10;
        assert(u_DUT.DelayApplied === 0 & CacheRepActive === 1) else $fatal(1, "Normal operation miss fail");
        
        //Correct branch hit
        MissArray = 0; BranchOpE[0] = 1;
        #10;
        assert(u_DUT.DelayApplied === 0 & CacheRepActive === 1) else $fatal(1, "Correct branch hit step 1 failed");
        
        BranchOpE[0] = 0;
        #10;
        
        //Correct branch miss
        MissArray = {64{1'b1}} ; BranchOpE[0] = 1;
        #5;
        //CacheRepActive goes low
        assert(CacheRepActive === 0 && u_DUT.DelayApplied === 0) else $fatal(1, "Correct branch miss CacheRepActive error");
        #6;
        BranchOpE[0] = 0;
        //CacheRepActive goes high based on DelayApplied
        assert(u_DUT.DelayApplied === 1 && CacheRepActive === 1) else $fatal(1, "Correct branch miss state transition failed");
        #9;
        
        //Misprediction hit
        MissArray = 0; BranchOpE[0] = 1;
        #10;
        assert(u_DUT.DelayApplied === 0 && CacheRepActive === 1) else $fatal(1, "Misprediction hit error");
        #10;
        
        //Misprediction miss;
        MissArray = {64{1'b1}}; BranchOpE[0] = 1;
        #5;
        assert(CacheRepActive === 0 && u_DUT.DelayApplied === 0) else $fatal(1, "Misprediction miss CacheRepActive error");
        #5;
        
        //At clk edge, indicate a miss
        PCSrcReg[1] = 1;
        #1;
        
        assert(CacheRepActive === 0 && u_DUT.DelayApplied === 1) else $fatal(1, "Misprediction miss state transition error");
        
        #9;
        BranchOpE[0] = 0; 
        
        //Allow PCSrcReg to update appropriately (after clock edge, not before)
        #1;
        PCSrcReg[1] = 0;
        #1;
        assert(CacheRepActive === 1 && u_DUT.DelayApplied === 0) else $fatal(1, "Misprediction miss state transition error (2)");
        
        $display("TEST PASSED");
        $finish;
        
    end
    
endmodule
