`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2024 04:12:05 PM
// Design Name: 
// Module Name: maindecoder
// Project Name: riscvsingle
// Target Devices: 
// Tool Versions: 
// Description: Deocodes the given opcode and outputs a majority of control signals
//              additional decoding done by the ALUdecoder
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module maindecoder(input [6:0] op,
                   output [2:0] ImmSrc, ResultSrc,
                   output [1:0] ALUOp, BranchOp,
                   output WidthOp,
                   output ALUSrc, PCBaseSrc,
                   output RegWrite, MemWrite);
    
    `include "OpParams.vh"
    `include "ControlParams.vh"

    reg [14:0] controls;
    
    assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
            ResultSrc, BranchOp, ALUOp, WidthOp, PCBaseSrc} = controls;
                   
    always @(*) begin
    
        case(op)
        //RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_BranchOp_ALUOp_WidthOp_PCBaseSrc
                                 
            OP_R_TYPE:       controls = {1'b1, 3'bxxx, 1'b0, 1'b0, RESULT_MUX_ALU,      2'b00, 2'b10, 1'b0, 1'bx}; //R-Type Instructions
            OP_I_TYPE_ALU:   controls = {1'b1, 3'b000, 1'b1, 1'b0, RESULT_MUX_ALU,      2'b00, 2'b10, 1'b0, 1'bx}; //I-Type ALU Instructions
            OP_I_TYPE_LOADS: controls = {1'b1, 3'b000, 1'b1, 1'b0, RESULT_MUX_DATAMEM,  2'b00, 2'b00, 1'b1, 1'bx}; //I-Type Load Instructions
            OP_S_TYPE:       controls = {1'b0, 3'b001, 1'b1, 1'b1, RESULT_MUX_DONTCARE, 2'b00, 2'b00, 1'b1, 1'bx}; //S-Type Instructions
            OP_B_TYPE:       controls = {1'b0, 3'b010, 1'b0, 1'b0, RESULT_MUX_DONTCARE, 2'b10, 2'b01,1'bx, 1'b0};//B-Type Instructions
            OP_JAL:          controls = {1'b1, 3'b011, 1'bx, 1'b0, RESULT_MUX_PCPLUS4,  2'b01, 2'bxx, 1'b0, 1'b0}; //jal
            OP_JALR:         controls = {1'b1, 3'b000, 1'bx, 1'b0, RESULT_MUX_PCPLUS4,  2'b01, 2'bxx, 1'b0, 1'b1}; //jalr
            OP_LUI:          controls = {1'b1, 3'b100, 1'bx, 1'b0, RESULT_MUX_IMMEXT,   2'b00, 2'bxx, 1'b0, 1'bx}; //lui
            OP_AUIPC:        controls = {1'b1, 3'b100, 1'bx, 1'b0, RESULT_MUX_PCTARGET, 2'b00, 2'bxx, 1'b0, 1'b0}; //auipc
            default:         controls = 15'bx; //Unknown opcode
            
        endcase
    
    end                   

endmodule
