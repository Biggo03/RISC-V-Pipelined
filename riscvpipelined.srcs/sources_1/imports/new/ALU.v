`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/27/2024 05:31:28 PM
// Design Name: 
// Module Name: ALU
// Project Name: riscvsingle
// Target Devices: 
// Tool Versions: 
// Description: Take control signal ALUControl, and does the corrosponding operation.
//              C and V flags are only updated on addition or subtraction. N and Z flags always updated.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: This module supports: addition, subtraction, AND, OR, XOR, SLT, SLTU, Logical shift left, Logical shift right, and Arithmetic shift right
// 
//////////////////////////////////////////////////////////////////////////////////

module ALU #(parameter WIDTH = 32)
            (input [3:0] ALUControl,
             input [WIDTH-1:0] A, B,
             output [WIDTH-1:0] ALUResult,
             output N, Z, C, V);
    
    `include "ControlParams.vh"

    //Intermediate signals for use in always statement
    reg [WIDTH-1:0] TempResult;
    reg Cout;
    reg TempC, TempV; 
    
    //VControl is used to determine if the overflow flag would be set
    reg VControl;
    
    always @(*) begin
        
        //Set default value for Cout
        Cout = 1'b0;
        
        //Operation Logic
        case(ALUControl)
            CTRL_ALU_ADD: {Cout, TempResult} = A + B; //Addition
            CTRL_ALU_SUB: {Cout, TempResult} = A - B; //Subtraction
            CTRL_ALU_AND: TempResult = A & B; //AND
            CTRL_ALU_OR: TempResult = A | B; //OR
            CTRL_ALU_XOR: TempResult = A ^ B; //XOR
            CTRL_ALU_SLL: TempResult = A << B; //Shift Left Logical
            CTRL_ALU_SRL: TempResult = A >> B; //Shift Right Logical
            CTRL_ALU_SRA: TempResult = $signed(A) >>> B; //Shift Right Arithmetic
                
            //SLT
            CTRL_ALU_SLT: begin
                    TempResult = A - B;
                    VControl = ~(ALUControl[0] ^ A[WIDTH-1] ^ B[WIDTH-1]) & (A[WIDTH-1] ^ TempResult[WIDTH-1]);
                    
                    
                    //LT comparison for sgined numbers determined by V and N flags (V ^ N)
                    if (VControl ^ TempResult[WIDTH-1]) TempResult = 1;
                    else TempResult = 0;
                
            end
            
            //SLTU
            CTRL_ALU_SLTU: begin
                
                //Assumed unsigned representation
                if (A < B) TempResult = 1;
                else TempResult = 0;
                
            end
            
            default: TempResult = {(WIDTH + 1){1'bx}}; //Undefined case
        
        endcase
        
        //Overflow and Carry Flag logic
        if (ALUControl[3] == 1'b1) begin
                      
            //Carry flag is inverse of Cout if Subtracting
            TempC = ALUControl[0] ? ~Cout : Cout;
            
            TempV = ~(ALUControl[0] ^ A[WIDTH-1] ^ B[WIDTH-1]) & (A[WIDTH-1] ^ TempResult[WIDTH-1]);
            
        end else begin
            //Default values of TemoC and TempV
            TempC = 1'b0;
            TempV = 1'b0;
        end
        
    end
    
    //Flag Assignment
        
    //Negative Flag
    assign N = TempResult[WIDTH-1];
    
    //Zero Flag
    assign Z = &(~TempResult);

    //Carry Flag
    assign C = TempC;
    
    //Overflow Flag
    assign V = TempV;
    
    //Final Result Assignment
    assign ALUResult = TempResult;

endmodule
