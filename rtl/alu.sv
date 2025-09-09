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

module alu #(
    parameter int WIDTH = 32
) (
    // Control inputs
    input  logic [3:0]         alu_control_i,

    // Data inputs
    input  logic [WIDTH-1:0]   A,
    input  logic [WIDTH-1:0]   B,

    // Data outputs
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
            4'b1000: {carry_out, alu_result_o} = A + B; //Addition
            4'b1001: {carry_out, alu_result_o} = A - B; //Subtraction
            4'b0010: alu_result_o = A & B; //AND
            4'b0011: alu_result_o = A | B; //OR
            4'b0100: alu_result_o = A ^ B; //XOR
            4'b0111: alu_result_o = A << B; //Shift Left Logical
            4'b0000: alu_result_o = A >> B; //Shift Right Logical
            4'b0001: alu_result_o = $signed(A) >>> B; //Shift Right Arithmetic
                
            //SLT
            4'b0101: begin
                    alu_result_o = A - B;
                    v_control = ~(alu_control_i[0] ^ A[WIDTH-1] ^ B[WIDTH-1]) & (A[WIDTH-1] ^ alu_result_o[WIDTH-1]);
                    
                    
                    //LT comparison for sgined numbers determined by V and N flags (V ^ N)
                    if (v_control ^ alu_result_o[WIDTH-1]) alu_result_o = 1;
                    else alu_result_o = 0;
                
            end
            
            //SLTU
            4'b0110: begin
                
                //Assumed unsigned representation
                if (A < B) alu_result_o = 1;
                else alu_result_o = 0;
                
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
            v_flag_o = 1'b0;
        end
        
    end
    
    //Flag Assignment
        
    //Negative Flag
    assign neg_flag_o = alu_result_o[WIDTH-1];
    
    //Zero Flag
    assign zero_flag_o = &(~alu_result_o);

endmodule
