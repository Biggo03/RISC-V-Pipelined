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


    reg [14:0] controls;
    
    assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
            ResultSrc, BranchOp, ALUOp, WidthOp, PCBaseSrc} = controls;
                   
    always @(*) begin
    
        case(op)
        //RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_BranchOp_ALUOp_WidthOp_PCBaseSrc
            
            7'b0110011: controls = 15'b1_xxx_0_0_000_00_10_0_x; //R-Type Instructions
            7'b0010011: controls = 15'b1_000_1_0_000_00_10_0_x; //I-Type ALU Instructions
            7'b0000011: controls = 15'b1_000_1_0_001_00_00_1_x; //I-Type Load Instructions
            7'b0100011: controls = 15'b0_001_1_1_xxx_00_00_1_x; //S-Type Instructions
            7'b1100011: controls = 15'b0_010_0_0_xxx_10_01_x_0; //B-Type Instructions
            7'b1101111: controls = 15'b1_011_x_0_010_01_xx_0_0; //jal
            7'b1100111: controls = 15'b1_000_x_0_010_01_xx_0_1; //jalr
            7'b0110111: controls = 15'b1_100_x_0_011_00_xx_0_x; //lui
            7'b0010111: controls = 15'b1_100_x_0_100_00_xx_0_0; //auipc
            default: controls = 15'bx; //Unknown opcode
            
        endcase
    
    end                   

endmodule
