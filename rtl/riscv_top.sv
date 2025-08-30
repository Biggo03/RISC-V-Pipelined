`timescale 1ns / 1ps
//==============================================================//
//  Module:       riscv_top
//  File:         riscv_top.sv
//  Description:  Instantiation of all modules involved in the system
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module riscv_top (
    // Clock & Reset
    input  logic        clk,
    input  logic        reset,

    // Temporary L1 instruction cache inputs
    input  logic        RepReady,
    input  logic [63:0] RepWord,

    // Memory outputs
    output logic [31:0] WriteDataM,
    output logic [31:0] DataAdr,
    output logic        MemWriteM
);
    
    // ----- Pipeline signals -----
    logic [31:0] PCF;
    logic [31:0] InstrF;
    logic [31:0] ReadDataM;
    logic [1:0]  WidthSrcMOUT;

    // ----- Cache control -----
    logic        InstrMissF;
    logic        InstrCacheRepActive;

    // ----- Branch/control -----
    logic [1:0]  PCSrcReg;
    logic [1:0]  BranchOpE;
    
    
    pipelined_riscv_core u_pipelined_riscv_core (
        // Clock & Reset
        .clk                   (clk),
        .reset                 (reset),

        // Instruction fetch inputs
        .InstrF                (InstrF),
        .InstrMissF            (InstrMissF),
        .InstrCacheRepActive   (InstrCacheRepActive),

        // Memory inputs
        .ReadDataM             (ReadDataM),

        // PC outputs
        .PCF                   (PCF),

        // ALU & memory outputs
        .ALUResultM            (DataAdr),
        .WriteDataM            (WriteDataM),

        // Control outputs
        .WidthSrcMOUT          (WidthSrcMOUT),
        .BranchOpE             (BranchOpE),
        .PCSrcReg              (PCSrcReg),
        .MemWriteM             (MemWriteM)
    );

    icache_l1 #(
        .S (32),
        .E (4),
        .B (64)
    ) u_icache_l1 (
        // Clock & Reset
        .clk             (clk),
        .reset           (reset),

        // Control inputs
        .RepReady        (RepReady),
        .PCSrcReg        (PCSrcReg),
        .BranchOpE       (BranchOpE),

        // Address & data inputs
        .Address         (PCF),
        .RepWord         (RepWord),

        // Data outputs
        .RD              (InstrF),

        // Status outputs
        .L1IMiss         (InstrMissF),
        .CacheRepActive  (InstrCacheRepActive)
    );
        
    data_mem u_data_mem (
        // Clock & control inputs
        .clk      (clk),
        .WE       (MemWriteM),
        .WidthSrc (WidthSrcMOUT),

        // Address & write data inputs
        .A        (DataAdr),
        .WD       (WriteDataM),

        // Read data output
        .RD       (ReadDataM)
    );
    
endmodule
