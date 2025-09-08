`timescale 1ns / 1ps
//==============================================================//
//  Module:       execute_stage
//  File:         execute_stage.sv
//  Description:  All logic contained within the Execute pipeline stage, along with its pipeline register.
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module execute_stage (
    // Clock & Reset
    input  logic        clk,
    input  logic        reset,

    // Data inputs
    input  logic [31:0] RD1D,
    input  logic [31:0] RD2D,
    input  logic [31:0] ResultW,
    input  logic [31:0] ForwardDataM,
    input  logic [31:0] PCD,
    input  logic [31:0] PCPlus4D,
    input  logic [31:0] ImmExtD,
    input  logic [31:0] PredPCTargetD,
    input  logic [2:0]  funct3D,
    input  logic [4:0]  RdD,
    input  logic [4:0]  Rs1D,
    input  logic [4:0]  Rs2D,

    // Control inputs
    input  logic [3:0]  ALUControlD,
    input  logic [2:0]  WidthSrcD,
    input  logic [2:0]  ResultSrcD,
    input  logic [1:0]  BranchOpD,
    input  logic        RegWriteD,
    input  logic        MemWriteD,
    input  logic        PCBaseSrcD,
    input  logic        ALUSrcD,
    input  logic [1:0]  ForwardAE,
    input  logic [1:0]  ForwardBE,
    input  logic        FlushE,
    input  logic        StallE,
    input  logic        PCSrcPredD,

    // Data outputs
    output logic [31:0] ALUResultE,
    output logic [31:0] WriteDataE,
    output logic [31:0] PCTargetE,
    output logic [31:0] PCPlus4E,
    output logic [31:0] ImmExtE,
    output logic [31:0] PCE,
    output logic [4:0]  Rs1E,
    output logic [4:0]  Rs2E,
    output logic [4:0]  RdE,
    output logic [2:0]  funct3E,
    output logic        N,
    output logic        Z,
    output logic        C,
    output logic        V,

    // Control outputs
    output logic [2:0]  WidthSrcE,
    output logic [2:0]  ResultSrcE,
    output logic [1:0]  BranchOpE,
    output logic        MemWriteE,
    output logic        RegWriteE,
    output logic        PCSrcPredE,
    output logic        TargetMatchE
);
     
    localparam REG_WIDTH = 227;
                    
    // ----- Execute pipeline register -----
    logic [REG_WIDTH-1:0] InputsE;
    logic [REG_WIDTH-1:0] OutputsE;
    logic                 ResetE;

    // ----- Execute stage outputs -----
    logic [31:0] RD1E;
    logic [31:0] RD2E;
    logic [31:0] PredPCTargetE;
    logic [3:0]  ALUControlE;
    logic        PCBaseSrcE;
    logic        ALUSrcE;

    // ----- Execute stage intermediates -----
    logic [31:0] SrcAE;
    logic [31:0] SrcBE;
    logic [31:0] PCBaseE;

    assign InputsE = {BranchOpD, WidthSrcD, ResultSrcD, MemWriteD, ALUControlD, PCBaseSrcD, ALUSrcD, RegWriteD,
                      funct3D, RD1D, RD2D, PCD, RdD, ImmExtD, Rs1D, Rs2D, PCPlus4D, PredPCTargetD, PCSrcPredD};
                      
    assign ResetE = (reset | FlushE);
    
    flop #(
        .WIDTH (REG_WIDTH)
    ) u_execute_reg (
        // Clock & Reset
        .clk    (clk),
        .en     (~StallE),
        .reset  (ResetE),

        // Data input
        .D      (InputsE),

        // Data output
        .Q      (OutputsE)
    );
    
    assign {BranchOpE, WidthSrcE, ResultSrcE, MemWriteE, ALUControlE, PCBaseSrcE, ALUSrcE, RegWriteE, 
            funct3E, RD1E, RD2E, PCE, RdE, ImmExtE, Rs1E, Rs2E, PCPlus4E, PredPCTargetE, PCSrcPredE} = OutputsE;
   
   //Test Branch Prediction
    always @(*) begin
        if (PCTargetE == PredPCTargetE) TargetMatchE = 1;
        else TargetMatchE = 0;
    end
   
    //Stage multiplexers:
    mux3 u_forward_mux_a (
        // Data inputs
        .d0 (RD1E),
        .d1 (ResultW),
        .d2 (ForwardDataM),

        // Select input
        .s  (ForwardAE),

        // Data output
        .y  (SrcAE)
    );
        
    mux3 u_forward_mux_b (
        // Data inputs
        .d0 (RD2E),
        .d1 (ResultW),
        .d2 (ForwardDataM),

        // Select input
        .s  (ForwardBE),

        // Data output
        .y  (WriteDataE)
    );
        
    mux2 u_src_b_mux (
        // Data inputs
        .d0 (WriteDataE),
        .d1 (ImmExtE),

        // Select input
        .s  (ALUSrcE),

        // Data output
        .y  (SrcBE)
    );
        
    mux2 u_pc_target_mux (
        // Data inputs
        .d0 (PCE),
        .d1 (SrcAE),

        // Select input
        .s  (PCBaseSrcE),

        // Data output
        .y  (PCBaseE)
    );
        
    //Arithmetic units:
    alu u_alu (
        // Control inputs
        .ALUControl (ALUControlE),

        // Data inputs
        .A          (SrcAE),
        .B          (SrcBE),

        // Data outputs
        .ALUResult  (ALUResultE),

        // Status flag outputs
        .N          (N),
        .Z          (Z),
        .C          (C),
        .V          (V)
    );
                
    adder u_pc_target_adder (
        // Data inputs
        .a (PCBaseE),
        .b (ImmExtE),

        // Data output
        .y (PCTargetE)
    );

endmodule
