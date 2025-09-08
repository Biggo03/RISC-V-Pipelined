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
    
    logic        clk;
    logic        reset;

    logic RepReady;
    logic [63:0] RepWord;
    

    logic [31:0] WriteDataM;
    logic [31:0] ALUResultM;
    logic        MemWriteM;
    
    
    riscv_top u_riscv_top (
        // Clock & Reset
        .clk        (clk),
        .reset      (reset),

        // Temporary L1 instruction cache inputs
        .RepReady   (RepReady),
        .RepWord    (RepWord),

        // Memory outputs
        .WriteDataM (WriteDataM),
        .ALUResultM (ALUResultM),
        .MemWriteM  (MemWriteM)
    );
    
    initial begin

        dump_setup;

        clk = 0; reset = 1; #20; reset = 0;

        $finish;
    end
    
    always begin
        clk = ~clk; #5;
    end
    
    always @(negedge clk) begin
        
        if (MemWriteM & ALUResultM > 90 & ALUResultM < 120) begin
            if (ALUResultM === 100 & WriteDataM === 25) begin
                $display("TEST PASSED");
                $finish;
            end else if (ALUResultM !== 96) begin
            $display("Failed.");
            $finish;
            
            end
        end
   
    end
    
endmodule
