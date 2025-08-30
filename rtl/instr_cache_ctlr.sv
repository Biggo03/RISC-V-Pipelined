`timescale 1ns / 1ps
//==============================================================//
//  Module:       instr_cache_ctlr
//  File:         instr_cache_ctlr.sv
//  Description:  Controls operations of the l1_icache
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   S - Number of sets
//
//  Notes:        N/A
//==============================================================//


module instr_cache_ctlr #(
    parameter int S = 64
) (
    // Clock & Reset
    input  logic                  clk,
    input  logic                  reset,

    // Control inputs
    input  logic [$clog2(S)-1:0]  Set,
    input  logic [S-1:0]          MissArray,
    input  logic [1:0]            PCSrcReg,
    input  logic [1:0]            BranchOpE,

    // Control outputs
    output logic [S-1:0]          ActiveArray,
    output logic                  CacheMiss,
    output logic                  CacheRepActive
);
    
    // ---- Control signal ----
    logic DelayApplied;
    
    //Decoding input set
    assign ActiveArray = 1'b1 << Set;
    assign CacheMiss = MissArray[Set];
    
    //Signal determining if replacement active
    assign CacheRepActive = ~(BranchOpE[0] & CacheMiss & (~DelayApplied)) & ~PCSrcReg[1];
    
    //Replacement state machine logic
    //DelayApplied = 0 indicates in ReadyToDelay state
    always @(posedge clk) begin
        if (reset) begin
            DelayApplied <= 0; 
        end else if (~DelayApplied & ~CacheRepActive) begin
            DelayApplied <= 1'b1;
        end else if (DelayApplied & (~CacheMiss | PCSrcReg[1])) begin
            DelayApplied <= 0;
        end
    end
  
endmodule
