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
    input  logic [3:0]         ALUControl,

    // Data inputs
    input  logic [WIDTH-1:0]   A,
    input  logic [WIDTH-1:0]   B,

    // Data outputs
    output logic [WIDTH-1:0]   ALUResult,

    // Status flag outputs
    output logic               N,
    output logic               Z,
    output logic               C,
    output logic               V
);

    // ----- Intermediate signals -----
    logic Cout;
    logic VControl;
    
    always @(*) begin
        
        //Set default value for Cout
        Cout = 1'b0;
        
        //Operation Logic
        case(ALUControl)
            4'b1000: {Cout, ALUResult} = A + B; //Addition
            4'b1001: {Cout, ALUResult} = A - B; //Subtraction
            4'b0010: ALUResult = A & B; //AND
            4'b0011: ALUResult = A | B; //OR
            4'b0100: ALUResult = A ^ B; //XOR
            4'b0111: ALUResult = A << B; //Shift Left Logical
            4'b0000: ALUResult = A >> B; //Shift Right Logical
            4'b0001: ALUResult = $signed(A) >>> B; //Shift Right Arithmetic
                
            //SLT
            4'b0101: begin
                    ALUResult = A - B;
                    VControl = ~(ALUControl[0] ^ A[WIDTH-1] ^ B[WIDTH-1]) & (A[WIDTH-1] ^ ALUResult[WIDTH-1]);
                    
                    
                    //LT comparison for sgined numbers determined by V and N flags (V ^ N)
                    if (VControl ^ ALUResult[WIDTH-1]) ALUResult = 1;
                    else ALUResult = 0;
                
            end
            
            //SLTU
            4'b0110: begin
                
                //Assumed unsigned representation
                if (A < B) ALUResult = 1;
                else ALUResult = 0;
                
            end
            
            default: ALUResult = {(WIDTH + 1){1'bx}}; //Undefined case
        
        endcase
        
        //Overflow and Carry Flag logic
        if (ALUControl[3] == 1'b1) begin
                      
            //Carry flag is inverse of Cout if Subtracting
            C = ALUControl[0] ? ~Cout : Cout;
            
            V = ~(ALUControl[0] ^ A[WIDTH-1] ^ B[WIDTH-1]) & (A[WIDTH-1] ^ ALUResult[WIDTH-1]);
            
        end else begin
            //Default values of C and V
            C = 1'b0;
            V = 1'b0;
        end
        
    end
    
    //Flag Assignment
        
    //Negative Flag
    assign N = ALUResult[WIDTH-1];
    
    //Zero Flag
    assign Z = &(~ALUResult);

endmodule
