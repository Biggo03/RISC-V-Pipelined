`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2024 09:34:13 PM
// Design Name: 
// Module Name: rf_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for rf (register file) module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module reg_file_tb();
    
    //Stimulus
    logic clk, reset, WE3;
    logic [4:0] A1, A2, A3;
    logic [31:0] RD1, RD2, WD3;
    
    //File reading signals
    int file;
    int read;
    
    //DUT instantiation
    reg_file DUT(clk, reset, A1, A2, A3, WD3, WE3, RD1, RD2);
    
    always begin
        clk = ~clk; #5;
    end
    
    initial begin

        dump_setup;
        
        //initialize clock registers, and set WE3
        clk = 0; WE3 = 0; reset = 1; #10; reset = 0;
        
        
        //Ensure reset worked properly, test both read ports
        for (int i = 0; i < 32; i++) begin
            A1 = i; A2 = i; #10;
            
            assert (RD1 == 0 & RD2 == 0) else $fatal("Error: Initialization failed");
            
        end
        
        //Populate registers with unique values
        for (int i = 0; i < 2; i++) begin
        
            //Check register Writing
            if (i == 0) begin
                
                WE3 = 1;
                
                for (int i = 0; i < 32; i++) begin
                    A1 = i; A2 = i; A3 = i; WD3 = i; #10;
            
                    assert (RD1 == i & RD2 == i) else $fatal("Error: Writing error");
            
                end
                
            end else begin
                
                WE3 = 0;
                
                for (int i = 0; i < 32; i++) begin
                    A1 = i; A2 = i; A3 = i; WD3 = 100; #10;

                    assert (RD1 == i & RD2 == i) else $display("Error: Register written when WE3 = 0");
            
                end
            
            end
            
        end
        
        //Ensure writing to 0 register not possible
        WE3 = 1; A1 = 0; A2 = 0; A3 = 0; WD3 = 1; #10;
        assert (RD1 == 0 & RD2 == 0) else $fatal("Error: Zero register updated");
        
        $display("Simulation Succesful!");
        
    end
    
endmodule
