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
`include "control_macros.sv"
`include "instr_macros.sv"

module alu_decoder (
    // Instruction decode inputs
    input  logic [2:0] funct3_i,
    input  logic [1:0] alu_op_i,
    input  logic [6:0] op,
    input  logic [6:0] funct7_i,

    // Decode outputs
    output logic [3:0] alu_control_o
);
                  
    always @(*) begin
        case(alu_op_i)
        `ALU_OP_ADD: alu_control_o = `ALU_ADD; //S-type Instructions and I-type loads
        `ALU_OP_SUB: alu_control_o = `ALU_SUB; //B-type Instructions
        
        //R- and I-Type instructions
        `ALU_OP_PROCESS: begin
            
            //Different op depending on funct3_i
            case(funct3_i)
                `F3_SLT:  alu_control_o = `ALU_SLT;
                `F3_SLTU: alu_control_o = `ALU_SLTU;
                `F3_OR:   alu_control_o = `ALU_OR;
                `F3_XOR:  alu_control_o = `ALU_XOR;
                `F3_AND:  alu_control_o = `ALU_AND;
                `F3_SLL:  alu_control_o = `ALU_SLL;

                `F3_ADD_SUB: begin
                    if (op[5] & funct7_i[5]) alu_control_o = `ALU_SUB;
                    else                     alu_control_o = `ALU_ADD;
                end

                `F3_SRL_SRA: begin
                    if (~funct7_i[5]) alu_control_o = `ALU_SRL;
                    else              alu_control_o = `ALU_SRA;
                end

                default: alu_control_o = 4'b0;
            endcase
        end

        default: alu_control_o = 4'b0;
        
        endcase
    end

endmodule
