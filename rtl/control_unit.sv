`timescale 1ns / 1ps
//==============================================================//
//  Module:       control_unit
//  File:         control_unit.sv
//  Description:  Control unit for pipelined riscv processor
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module control_unit (
    // Instruction decode inputs
    input  logic [6:0] OpD,
    input  logic [2:0] funct3D,
    input  logic       funct7b5D,

    // Main decoder outputs
    output logic [2:0] ImmSrcD,
    output logic [2:0] ResultSrcD,
    output logic [1:0] BranchOpD,
    output logic       ALUSrcD,
    output logic       PCBaseSrcD,
    output logic       RegWriteD,
    output logic       MemWriteD,

    // ALU decoder output
    output logic [3:0] ALUControlD,

    // Width decoder output
    output logic [2:0] WidthSrcD
);
        
    
    // ----- Control signals -----
    logic [1:0] ALUOp;
    logic WidthOp;
    
    main_decoder u_main_decoder (
        // Instruction decode input
        .op        (OpD),

        // Control outputs
        .ImmSrc    (ImmSrcD),
        .ResultSrc (ResultSrcD),
        .ALUOp     (ALUOp),
        .BranchOp  (BranchOpD),
        .WidthOp   (WidthOp),
        .ALUSrc    (ALUSrcD),
        .PCBaseSrc (PCBaseSrcD),
        .RegWrite  (RegWriteD),
        .MemWrite  (MemWriteD)
    );
    
    alu_decoder u_alu_decoder (
        // Instruction decode inputs
        .funct3     (funct3D),
        .ALUOp      (ALUOp),
        .op5        (OpD[5]),
        .funct7b5   (funct7b5D),

        // Control output
        .ALUControl (ALUControlD)
    );
        
    width_decoder u_width_decoder (
        // Instruction decode inputs
        .funct3   (funct3D),
        .WidthOp  (WidthOp),

        // Control output
        .WidthSrc (WidthSrcD)
    );
        
        
endmodule   
