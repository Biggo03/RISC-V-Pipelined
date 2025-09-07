`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2024 07:37:50 PM
// Design Name: 
// Module Name: datamem_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for datamem module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module data_mem_tb();
    
    // Stimulus and device outputs
    logic        clk;
    logic        WE;
    logic [1:0]  WidthSrc;
    logic [31:0] A;
    logic [31:0] WD;
    logic [31:0] RD;

    // Array for expected values of each storage type
    logic [31:0] RDWExp   [63:0];
    logic [15:0] RDHWExp  [127:0];
    logic [7:0]  RDByteExp[255:0];

    // Instantiate DUT
    data_mem u_DUT (
        .clk      (clk),
        .WE       (WE),
        .WidthSrc (WidthSrc),
        .A        (A),
        .WD       (WD),
        .RD       (RD)
    );
    
    //Clock generation
    always begin
        clk = ~clk; #5;
    end
    
    initial begin

        dump_setup;
        
        //Initialize input signals 
        clk = 0; WE = 1; WidthSrc = 2'b00;
        
        //Populate memory with values using word storage
        for (int i = 0; i < 64; i++) begin
        
            A = (i * 4); WD = i; RDWExp[i] = i; #10;
            
            assert (RD === RDWExp[i]) 
            else $fatal(1, "Error: WidthSrc: %b.\nAddress: %d\nExpected value: %b\nActual value:   %b", 
                        WidthSrc, A, RDWExp[i], RD);
            
        end
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        //Set storage mode to HW
        WidthSrc = 2'b10;
        
        //Populate halfword intervals with unique values
        for (int i = 0; i < 128; i++) begin
            
            A = (i * 2); WD = i; RDHWExp[i] = i; #10;
            
        end
        
        //Disable WE, and set intial low and high indices
        WE = 0;
        
       
        //Ensure values are as expected
        for (int i = 0; i < 128; i++) begin
            
            A = (i * 2); #20;
            
            assert (RD[15:0] === RDHWExp[i]) 
            else $fatal(1, "Error: WidthSrc: %b.\nAddress: %d\nExpected value: %b\nActual value:   %b", 
                     WidthSrc, A, RDHWExp[i], RD[15:0]);
            
        end
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        //Set storage mode to byte, enable writing
        WidthSrc = 2'b01; WE = 1;
        
        //Populate byte intervals with unique values
        for (int i = 0; i < 256; i++) begin
            
            A = i; WD = i; RDByteExp[i] = i; #10;
            
        end
        
        //Disable WE, and set intial byte indices
        WE = 0;
        
        for (int i = 0; i < 256; i++) begin
        
            A = i; #20;
            
            assert(RD[7:0] === RDByteExp[i])
            else $fatal(1, "Error: WidthSrc: %b.\nAddress: %d\nExpected byte: %b\nActual byte:   %b",
                         WidthSrc, A, RDByteExp[i], RD[7:0]);
        
         
        end
        
        $display("TEST PASSED");
        $finish;
        
    end
    

endmodule
