`timescale 1ns / 1ps
//==============================================================//
//  Module:       alu_decoder
//  File:         alu_decoder.sv
//  Description:  Generates control signals related to the ALU
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module alu_decoder (
    // Instruction decode inputs
    input  logic [2:0] funct3,
    input  logic [1:0] ALUOp,
    input  logic [6:0] op,
    input  logic [6:0] funct7,

    // Decode outputs
    output logic [3:0] ALUControl
);
                  
    always @(*) begin
        
        case(ALUOp)
        2'b00: ALUControl = 4'b1000; //S-type Instructions and I-type loads
        2'b01: ALUControl = 4'b1001; //B-type Instructions
        
        //R- and I-Type instructions
        2'b10: begin
            
            //Different op depending on funct3
            case(funct3)
            
                3'b010: ALUControl = 4'b0101; //SLT
                3'b011: ALUControl = 4'b0110; //SLTU
                3'b110: ALUControl = 4'b0011; //OR
                3'b100: ALUControl = 4'b0100; //XOR
                3'b111: ALUControl = 4'b0010; //AND
                3'b001: ALUControl = 4'b0111; //Shift Left Logical
                
                //addition or subtraction
                3'b000: begin
                
                    //Sub if op[5] and funct7[5] = 1
                    if (op[5] & funct7[5]) ALUControl = 4'b1001; //Sub
                    else ALUControl = 4'b1000; //Add
                
                end
            
                //Shift Right Logical/Arithmetic
                3'b101: begin
                
                    // Logical, {op[5], funct7[5]} = 00, 10
                    if (~funct7[5]) ALUControl = 4'b0000; //SRL
                    //Arithmetic {op[5], funct7[5]} = 11, 01
                    else ALUControl = 4'b0001; //SRA
            
                end
            
                //Unknown funct3 operation
                default: ALUControl = 4'bx;
  
            endcase
        end
        
        //Unknown ALUOpcode
        default: ALUControl = 4'bx;
        
        endcase
    end

endmodule
