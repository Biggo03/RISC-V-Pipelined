`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Viggo Wozniak
//
// Create Date: 10/02/2024 03:44:50 PM
// Module Name: hazardcontrol
// Project Name: riscvpipelined
// Description: Generates signals to control hazard handelling within the pipeline.
// 
// Dependencies: None
// Additional Comments: This module takes inputs from multiple stages, and sends outputs to multiple stages.
//
//////////////////////////////////////////////////////////////////////////////////


module hazardcontrol(input InstrMissF,                   //Fetch stage input
                     input [4:0] Rs1D, Rs2D,            //Decode stage inputs
                     input [4:0] Rs1E, Rs2E, RdE,       //Execute stage inputs
                     input ResultSrcEb2, PCSrcb1,    
                     input [4:0] RdM,                   //Memory stage inputs
                     input RegWriteM, 
                     input [4:0] RdW,                   //Write stage inputs
                     input RegWriteW,
                     input [1:0] PCSrcReg,               //Branch pred/cache inputs
                     input CacheRepActive,
                     output StallF, StallD, StallE,      // Stall outputs
                     output FlushD, FlushE,              //Flush outputs
                     output [1:0] ForwardAE, ForwardBE); //Forward outputs
    
    //Parameters to make forward multiplexer values more clear
    localparam [1:0] NO_FORWARD = 2'b00;
    localparam [1:0] WB_FORWARD = 2'b01;
    localparam [1:0] MEM_FORWARD = 2'b10;
    
    //Intermediate value used to determine some stalls and flushes
    wire LoadStall;
    
    reg [1:0] Temp_ForwardAE, Temp_ForwardBE;
    
    //Forward logic
    always @(*) begin
        
        //ForwardAE
        if (((Rs1E == RdM) & RegWriteM) & (Rs1E != 0)) Temp_ForwardAE = MEM_FORWARD;
        else if (((Rs1E == RdW) & RegWriteW) & (Rs1E != 0)) Temp_ForwardAE = WB_FORWARD;
        else Temp_ForwardAE = NO_FORWARD;
        
        //ForwardBE
        if (((Rs2E == RdM) & RegWriteM) & (Rs2E != 0)) Temp_ForwardBE = MEM_FORWARD;
        else if (((Rs2E == RdW) & RegWriteW) & (Rs2E != 0)) Temp_ForwardBE = WB_FORWARD;
        else Temp_ForwardBE = NO_FORWARD;
    
    end
    
    //Assign outputs to temp signals
    assign ForwardAE = Temp_ForwardAE;
    assign ForwardBE = Temp_ForwardBE;
    
    
    //Stall and flush logic
    assign LoadStall = ResultSrcEb2 & ((Rs1D == RdE) | (Rs2D == RdE));
    
    //Stalls
    assign StallF = (LoadStall | InstrMissF) & ~PCSrcReg[1];
    assign StallD = LoadStall | InstrMissF;
    assign StallE = InstrMissF;
    
    //Flushes
    assign FlushE = (PCSrcb1 & (CacheRepActive | PCSrcReg[1])) | LoadStall;
    assign FlushD = PCSrcb1;
    
    

endmodule
