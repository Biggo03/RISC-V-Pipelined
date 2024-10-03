`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2024 04:04:23 PM
// Design Name: 
// Module Name: hazardcontrol_TB
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


module hazardcontrol_TB();

    //Stimulus signals
    logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW;
    logic ResultSrcEb2, PCSrcE, RegWriteM, RegWriteW;
    logic StallF, StallD, FlushD, FlushE;
    logic [1:0] ForwardAE, ForwardBE;
    
    //signals for holding expected results.
    logic [1:0] ForwardExpectedA;
    logic [1:0] ForwardExpectedB;
    
    //Signals for holding expectd values of stall and flush signals
    logic StallFExpected, StallDExpected, FlushEExpected, FlushDExpected;
    
    //DUT instantiation
    hazardcontrol DUT(.Rs1D (Rs1D),
                      .Rs2D (Rs2D),
                      .Rs1E (Rs1E),
                      .Rs2E (Rs2E),
                      .RdE (RdE),
                      .ResultSrcEb2 (ResultSrcEb2),
                      .PCSrcE (PCSrcE),
                      .RdM (RdM),
                      .RegWriteM (RegWriteM),
                      .RdW (RdW),
                      .RegWriteW (RegWriteW),
                      .StallF (StallF),
                      .StallD (StallD),
                      .FlushD (FlushD),
                      .FlushE (FlushE),
                      .ForwardAE (ForwardAE),
                      .ForwardBE (ForwardBE));
    
    //Parameters to consolidate signal values
    localparam [1:0] NO_FORWARD = 2'b00;
    localparam [1:0] WB_FORWARD = 2'b01;
    localparam [1:0] MEM_FORWARD = 2'b10;

    //Asserts correct outputs when checking functionality of ForwardAE
    task AssertForwardA();
        
        assert (ForwardExpectedA === ForwardAE) else $fatal("Error: ForwardingAE doesn't match expected\
                                                              \nRs1E: %b, RdM: %b, RdW: %b, RegWriteM: %b RegWriteW: %b\
                                                              \nExpected Output: %b\
                                                              \nActual Output:   %b",
                                                              Rs1E, RdM, RdW, RegWriteM, RegWriteW, ForwardExpectedA, ForwardAE);
    
    endtask

    //Asserts correct outputs when checking functionality of ForwardBE
    task AssertForwardB();
        
        assert (ForwardExpectedB === ForwardAE) else $fatal("Error: ForwardingAE doesn't match expected\
                                                              \nRs1E: %b, RdM: %b, RdW: %b, RegWriteM: %b RegWriteW: %b\
                                                              \nExpected Output: %b\
                                                              \nActual Output:   %b",
                                                              Rs1E, RdM, RdW, RegWriteM, RegWriteW, ForwardExpectedB, ForwardBE);
    
    endtask
    
    //Assert correct outputs for stall and flush outputs
    task AssertStallFlush();
        
        assert (StallF === StallFExpected & StallD === StallDExpected & FlushE === FlushEExpected & FlushD === FlushDExpected) else
        $fatal("Error: Stall or flush incorrect.\
        \nResultSrcE[2]: %b, Rs1D: %b, Rs2D: %b, RdE: %b\
        \nStallFExpected: %b, StallDExpected: %b, FlushEExpected: %b, FlushDExpected: %b\
        \nStallF:         %b, StallD:         %b, FlushE:         %b, FlushD:         %b",
        ResultSrcEb2, Rs1D, Rs2D, RdE, StallFExpected, StallDExpected, FlushEExpected, FlushDExpected,
        StallF, StallD, FlushE, FlushD);
        
        
    endtask
    
    initial begin
        
        //Test all register combinations for ForwrdAE and ForwardBE
        for (int i = 0; i < 64; i++) begin
            
            //Do this so can test both types of forwarding
            if (i < 32) RdM = i;
            else RdW = i-32;
        
            for (int j = 0; j < 32; j++) begin
            
                Rs1E = j;
                Rs2E = j;
                
                //Test ForwardExpectedAE
                if (Rs1E === 0) ForwardExpectedA = NO_FORWARD;
                else if (Rs1E === RdM & RegWriteM) ForwardExpectedA = MEM_FORWARD; 
                else if (Rs1E === RdW & RegWriteW) ForwardExpectedA = WB_FORWARD;
                else ForwardExpectedA = NO_FORWARD;
                
                #10;
                
                AssertForwardA();
                
                //Test ForwardExpectedBE
                if (Rs2E === 0) ForwardExpectedB = NO_FORWARD;
                else if (Rs2E === RdM & RegWriteM) ForwardExpectedB = MEM_FORWARD; 
                else if (Rs2E === RdW & RegWriteW) ForwardExpectedB = WB_FORWARD;
                else ForwardExpectedB = NO_FORWARD;
                
                #10;
                
                AssertForwardB();
                
            end
            
        end
        
        $display("Forwarding Successful!");
        
        for (int i = 0; i < 32; i++) begin
            
            RdE = i;
            
            for (int j = 0; j < 64; j++) begin
            
            //Create different ranges of Rs1D and Rs2D
            if (j < 16 | j > 48) begin
                if (j < 16) Rs1D = j;
                else Rs1D = j - 32;
            end else begin
                if (j < 32) Rs2D = j;
                else Rs2D = j - 32;
            end
            
            //Check Flush calculation under various connditions
            if (j < 16 | j > 48) PCSrcE = 0;
            else PCSrcE = 1;
            
            //Check loadStall calculation under various conditions
            if (j > 16 | j < 32 | j > 48) ResultSrcEb2 = 0;
            else ResultSrcEb2 = 1;
            
            end
            
            //Store expected results
            if (ResultSrcEb2 & ((Rs1D === RdE) | (Rs2D === RdE))) begin
            
                StallFExpected = 1;
                StallDExpected = 1;
                
                if (PCSrcE === 1) FlushE = 1;
                else FlushE = 0;
                
            end else begin
                StallFExpected = 0;
                StallDExpected = 0;
            end
            
            if (PCSrcE) begin
                FlushDExpected = 1;
                FlushEExpected = 1;
            end
            else begin
                FlushDExpected = 0;
                FlushEExpected = 0;
            end
            
            #10;
            
            AssertStallFlush();
            
        end
        
        $display("Simulation Succesful!");
        $stop;
        
    end
    

endmodule
