`timescale 1ns / 1ps
//==============================================================//
//  Module:       alu
//  File:         alu.sv
//  Description:  Paramaterized ALU
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   WIDTH  - data width
//
//  Notes:        Supports addition, subtraction, AND, OR, XOR, SLT, SLTU, logical shift left, logical shift right, and arithmetic shift right
//==============================================================//
`include "control_macros.sv"

module alu #(
    parameter int WIDTH = 32
) (
    // Control inputs
    input  logic [3:0]         alu_control_i,

    // data inputs
    input  logic [WIDTH-1:0]   A,
    input  logic [WIDTH-1:0]   B,

    // data outputs
    output logic [WIDTH-1:0]   alu_result_o,

    // Status flag outputs
    output logic        neg_flag_o,
    output logic        zero_flag_o,
    output logic        carry_flag_o,
    output logic        v_flag_o
);

    // ----- Intermediate signals -----
    logic carry_out;
    logic v_control;
    
    always @(*) begin
        
        //set default value for carry_out
        carry_out = 1'b0;
        
        //Operation Logic
        case(alu_control_i)
            `ALU_ADD: {carry_out, alu_result_o} = A + B;
            `ALU_SUB: {carry_out, alu_result_o} = A - B;
            `ALU_AND: alu_result_o = A & B;
            `ALU_OR:  alu_result_o = A | B;
            `ALU_XOR: alu_result_o = A ^ B;
            `ALU_SLL: alu_result_o = A << B;
            `ALU_SRL: alu_result_o = A >> B;
            `ALU_SRA: alu_result_o = $signed(A) >>> B;
                
            `ALU_SLT: begin
                    alu_result_o = A - B;
                    v_control = ~(alu_control_i[0] ^ A[WIDTH-1] ^ B[WIDTH-1]) & (A[WIDTH-1] ^ alu_result_o[WIDTH-1]);
                    
                    //LT comparison for sgined numbers determined by V and N flags (V ^ N)
                    if (v_control ^ alu_result_o[WIDTH-1]) alu_result_o = 1'b1;
                    else                                   alu_result_o = 1'b0;
            end
            
            `ALU_SLTU: begin
                if (A < B) alu_result_o = 1;
                else       alu_result_o = 0;
            end
            
            default: alu_result_o = {(WIDTH + 1){1'bx}}; //Undefined case
        endcase
        
        //Overflow and Carry Flag logic
        if (alu_control_i[3] == 1'b1) begin
                      
            //Carry flag is inverse of carry_out if Subtracting
            carry_flag_o = alu_control_i[0] ? ~carry_out : carry_out;
            
            v_flag_o = ~(alu_control_i[0] ^ A[WIDTH-1] ^ B[WIDTH-1]) & (A[WIDTH-1] ^ alu_result_o[WIDTH-1]);
            
        end else begin
            //Default values of C and V
            carry_flag_o = 1'b0;
            v_flag_o     = 1'b0;
        end
        
    end
    
    //Flag Assignment
    assign neg_flag_o  = alu_result_o[WIDTH-1];
    assign zero_flag_o = &(~alu_result_o);

endmodule
