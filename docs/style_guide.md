# RTL Style Guide

## File and Module naming

- File names: Use snake_case
  - Ex: branch_predictor.sv
- Module names: Match the file name (snake_case)
- Testbenches: RTL module name + _tb
  - Ex: branch_predictor_tb.sv

## Ports

- ANSI-style port declarations
- All ports use logic
- One port per line
- Group ports with section comments
  - Ex: //Clock & Reset

### Example:

    module branch_predictor (
        // Clock & Reset
        input  logic        clk,
        input  logic        reset,

        // Pipeline control inputs
        input  logic        StallE,

        // PC inputs
        input  logic [9:0]  PCF,
        input  logic [9:0]  PCE,
        input  logic [31:0] PCTargetE,

        // Branch resolution inputs
        input  logic        PCSrcResE,
        input  logic        TargetMatchE,
        input  logic        BranchOpEb0,

        // Predictor outputs
        output logic        PCSrcPredF,
        output logic [31:0] PredPCTargetF
    );

## Module Instantiations

- Fully named port mapping (not positional)
- Instance name: prefixed with "u_", and a descriptive name
- Parmaters listed first, in their own block
- Ports grouped with section comments
  - Mirrors module declaration
- One signal per line, aligned

### Example:

    flop #(
        .WIDTH (REG_WIDTH)
    ) u_execute_reg (
        // Clock & Reset
        .clk    (clk),
        .en     (~StallE),
        .reset  (EReset),

        // Data input
        .D      (EInputs),

        // Data output
        .Q      (EOutputs)
    );

## Parameters:

- Use UPPER_CASE_SNAKE
- Placed in the parameter block directly after the module name

## Testbenches

- File names: <module_name>_tb.sv