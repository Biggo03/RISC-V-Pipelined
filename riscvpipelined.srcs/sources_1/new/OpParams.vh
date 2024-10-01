//This file will define localparameters for opCodes

`ifndef OPCODE_SIGNALS_VH
`define OPCODE_SIGNALS_VH

localparam [7:0] OP_R_TYPE = 7'b0110011;
localparam [7:0] OP_I_TYPE_ALU = 7'b0010011;
localparam [7:0] OP_I_TYPE_LOADS = 7'b0000011;
localparam [7:0] OP_S_TYPE = 7'b0100011;
localparam [7:0] OP_B_TYPE = 7'b1100011;
localparam [7:0] OP_JAL = 7'b1101111;
localparam [7:0] OP_JALR = 7'b1100111;
localparam [7:0] OP_LUI = 7'b0110111;
localparam [7:0] OP_AUIPC = 7'b0010111;

`endif