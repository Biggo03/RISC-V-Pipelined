`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/18/2025 07:26:21 PM
// Design Name: 
// Module Name: GHR_TB
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


module ghr_tb();

// Local parameters for state bits. Output matches state bits
localparam UU = 2'b00;
localparam UT = 2'b01;
localparam TU = 2'b10;
localparam TT = 2'b11;

logic clk, reset, BranchOpEb0, PCSrcResE;
logic [1:0] LocalSrc, LocalSrcExp;

ghr DUT(clk, reset, stallE, BranchOpEb0, PCSrcResE, LocalSrc);

always begin
    clk = ~clk; #5;
end

initial begin

    dump_setup;
    
    //Initialize System
    clk = 0; reset = 1; BranchOpEb0 = 0; PCSrcResE = 0; LocalSrcExp = UT;
    
    #10;
    
    reset = 0;
    
    #10;
    
    assert(LocalSrc === UT) else $fatal(1, "Initialization Failed");
    
    BranchOpEb0 = 1;
    
    //Check switching states works correctly
    for (int i = 0; i < 32; i = i + 1) begin
        if (i % 4 == 0) begin
            PCSrcResE = ~PCSrcResE;
        end
        
        if (PCSrcResE == 1) begin
            if (LocalSrcExp == UU || LocalSrcExp == TU) LocalSrcExp = UT;
            else if (LocalSrcExp == UT || LocalSrcExp == TT) LocalSrcExp = TT;
        end else begin
            if (LocalSrcExp == UU || LocalSrcExp == TU) LocalSrcExp = UU;
            else if (LocalSrcExp == UT || LocalSrcExp == TT) LocalSrcExp = TU;
        end
        
        #10;
        
        assert (LocalSrc === LocalSrcExp) else $fatal(1, "State change error when LocalSrc in %b", LocalSrc);
        
    end
    
    BranchOpEb0 = 0;
    
    //Check enable works correctly
    for (int i = 0; i < 32; i = i + 1) begin
        if (i % 4 == 0) begin
            PCSrcResE = ~PCSrcResE;
        end
        
        #10;
        
        assert (LocalSrc === LocalSrcExp) else $fatal(1, "Enable Error");
        
    end
    
    $display("TEST PASSED");
    $finish;

end

endmodule
