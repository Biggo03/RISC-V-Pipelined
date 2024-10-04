`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 10/03/2024 11:36:49 AM
// Module Name: memorystage
// Project Name: riscvpipelined
// Description: All logic contained within the memory pipeline stage.
// 
// Dependencies: flop (flop.v), reduce (reduce.v)
// Additional Comments: 
//            Input sources: Execute stage, Hazard control unit
//            Output destinations: Writeback stage pipeline register, Hazard control unit, Register File
//                      
//
//////////////////////////////////////////////////////////////////////////////////


module writebackstage(input clk, reset,
                      //Input Data Signals
                      input [31:0] ALUResultM, ReducedDataM,
                      input [31:0] PCTargetM, PCPlus4M,
                      input [31:0] ImmExtM,
                      input [4:0] RdM,
                      //Input Control Signals
                      input [2:0] ResultSrcM,
                      input RegWriteM,
                      //Output Data Signals
                      output [31:0] ResultW,
                      output [4:0] RdW,
                      //Output Control Signals
                      output RegWriteW);

    localparam REG_WIDTH = 169;
    
    wire [REG_WIDTH-1:0] WInputs, WOutputs;
    
    assign WInputs = {ALUResultM, ReducedDataM, PCTargetM, PCPlus4M, ImmExtM, RdM, ResultSrcM, RegWriteM};
    
    flop #(.WIDTH (REG_WIDTH)) WritebackReg(.clk (clk),
                                            .en (1'b1),
                                            .reset (reset),
                                            .D (WInputs),
                                            .Q (WOutputs));
   
    assign {ALUResultW, ReducedDataW, PCTargetW, PCPlus4W, ImmExtW, RdW, ResultSrcW, RegWriteW} = WOutputs;
    
    
    mux5 ResultMux(.d0 (ALUResultW),
                   .d1 (PCTargetW),
                   .d2 (PCPlus4W),
                   .d3 (ImmExtW),
                   .d4 (ReducedDataW),
                   .s (ResultSrcW),
                   .y (ResultW));
    

endmodule
