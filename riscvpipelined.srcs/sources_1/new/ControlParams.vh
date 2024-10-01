//This File will define control signal parameters
//This will only be done for control signals more 1-bit long

`ifndef CONTROL_SIGNAL_VH
`define CONTROL_SIGNAL_VH

//ALUControl parameters
localparam [3:0] CTRL_ALU_SRL    = 4'b0000;
localparam [3:0] CTRL_ALU_SRA    = 4'b0001;
localparam [3:0] CTRL_ALU_AND    = 4'b0010;
localparam [3:0] CTRL_ALU_OR     = 4'b0011;
localparam [3:0] CTRL_ALU_XOR    = 4'b0100;
localparam [3:0] CTRL_ALU_SLT    = 4'b0101;
localparam [3:0] CTRL_ALU_SLTU   = 4'b0110;
localparam [3:0] CTRL_ALU_SLL    = 4'b0111;
localparam [3:0] CTRL_ALU_ADD    = 4'b1000;
localparam [3:0] CTRL_ALU_SUB    = 4'b1001;

//Width modulation parameters
localparam [2:0] WIDTH_WORD       = 3'b000;
localparam [2:0] WIDTH_HW_S       = 3'b010;
localparam [2:0] WIDTH_HW_U       = 3'b110;
localparam [2:0] WIDTH_BYTE_S     = 3'b001;
localparam [2:0] WIDTH_BYTE_U     = 3'b101;

//Result mux parameters
localparam [2:0] RESULT_MUX_ALU       = 3'b000;
localparam [2:0] RESULT_MUX_PCTARGET  = 3'b001;
localparam [2:0] RESULT_MUX_PCPLUS4   = 3'b010;
localparam [2:0] RESULT_MUX_IMMEXT    = 3'b011;
localparam [2:0] RESULT_MUX_DATAMEM   = 3'b100;
localparam [2:0] RESULT_MUX_DONTCARE  = 3'b0xx;



`endif