`timescale 1ns / 1ps
//==============================================================//
//  Module:       hazard_unit
//  File:         hazard_unit.sv
//  Description:  Generates signals to control hazard handelling within the pipeline
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module hazard_unit (
    // Fetch stage inputs
    input  logic        InstrMissF,

    // Decode stage inputs
    input  logic [4:0]  Rs1D,
    input  logic [4:0]  Rs2D,

    // Execute stage inputs
    input  logic [4:0]  Rs1E,
    input  logic [4:0]  Rs2E,
    input  logic [4:0]  RdE,
    input  logic        ResultSrcEb2,
    input  logic        PCSrcb1,

    // Memory stage inputs
    input  logic [4:0]  RdM,
    input  logic        RegWriteM,

    // Writeback stage inputs
    input  logic [4:0]  RdW,
    input  logic        RegWriteW,

    // Branch predictor / cache inputs
    input  logic [1:0]  PCSrcReg,
    input  logic        InstrCacheRepActive,

    // Stall outputs
    output logic        StallF,
    output logic        StallD,
    output logic        StallE,
    output logic        StallM,
    output logic        StallW,

    // Flush outputs
    output logic        FlushD,
    output logic        FlushE,

    // Forwarding outputs
    output logic [1:0]  ForwardAE,
    output logic [1:0]  ForwardBE
);
    
    // ----- Forwarding control -----
    localparam [1:0] NO_FORWARD  = 2'b00;
    localparam [1:0] WB_FORWARD  = 2'b01;
    localparam [1:0] MEM_FORWARD = 2'b10;

    // ----- Hazard detection -----
    logic LoadStall;
    
    //Forward logic
    always @(*) begin
        
        //ForwardAE
        if (((Rs1E == RdM) & RegWriteM) & (Rs1E != 0)) ForwardAE = MEM_FORWARD;
        else if (((Rs1E == RdW) & RegWriteW) & (Rs1E != 0)) ForwardAE = WB_FORWARD;
        else ForwardAE = NO_FORWARD;
        
        //ForwardBE
        if (((Rs2E == RdM) & RegWriteM) & (Rs2E != 0)) ForwardBE = MEM_FORWARD;
        else if (((Rs2E == RdW) & RegWriteW) & (Rs2E != 0)) ForwardBE = WB_FORWARD;
        else ForwardBE = NO_FORWARD;
    
    end  
    
    //Stall and flush logic
    assign LoadStall = ResultSrcEb2 & ((Rs1D == RdE) | (Rs2D == RdE));
    
    //Stalls
    assign StallF = (LoadStall | InstrMissF) & ~PCSrcReg[1];
    assign StallD = LoadStall | InstrMissF;
    assign StallE = InstrMissF;
    assign StallM = InstrMissF;
    assign StallW = InstrMissF;
    
    //Flushes
    assign FlushE = (PCSrcb1 & (InstrCacheRepActive | PCSrcReg[1])) | LoadStall;
    assign FlushD = PCSrcb1;

endmodule
