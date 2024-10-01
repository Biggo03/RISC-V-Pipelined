`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2024 04:36:34 PM
// Design Name: 
// Module Name: ALUdecoder
// Project Name: riscvsingle
// Target Devices: 
// Tool Versions: 
// Description: Outputs a control signal that determines the operation the ALU is to perform.
//              This is based on an intermediary control signal from the main decoder, ALUOp, and the instructions funct3 and funct7[5] fields
// 
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALUdecoder(input [2:0] funct3,
                  input [1:0] ALUOp,
                  input op5, funct7b5,
                  output [3:0] ALUControl);
    
    `include "ControlParams.vh"
                  
    reg [3:0] TempALUControl;
                  
    always @(*) begin
        
        case(ALUOp) 
        2'b00: TempALUControl = CTRL_ALU_ADD; //S-type Instructions and I-type loads
        2'b01: TempALUControl = CTRL_ALU_SUB; //B-type Instructions
        
        //R- and I-Type instructions
        2'b10: begin
            
            //Different op depending on funct3
            case(funct3)
            
                3'b010: TempALUControl = CTRL_ALU_SLT; //SLT
                3'b011: TempALUControl = CTRL_ALU_SLTU; //SLTU
                3'b110: TempALUControl = CTRL_ALU_OR; //OR
                3'b100: TempALUControl = CTRL_ALU_XOR; //XOR
                3'b111: TempALUControl = CTRL_ALU_AND; //AND
                3'b001: TempALUControl = CTRL_ALU_SLL; //Shift Left Logical
                
                //addition or subtraction
                3'b000: begin
                
                    //Sub if op[5] and funct7[5] = 1
                    if (op5 & funct7b5) TempALUControl = CTRL_ALU_SUB; //Sub
                    else TempALUControl = CTRL_ALU_ADD; //Add
                
                end
            
                //Shift Right Logical/Arithmetic
                3'b101: begin
                
                    // Logical, {op[5], funct7[5]} = 00, 10
                    if (~funct7b5) TempALUControl = CTRL_ALU_SRL; //SRL
                    //Arithmetic {op[5], funct7[5]} = 11, 01
                    else TempALUControl = CTRL_ALU_SRA; //SRA
            
                end
            
                //Unknown funct3 operation
                default: TempALUControl = 4'bx;
  
            endcase
        end
        
        //Unknown ALUOpcode
        default: TempALUControl = 4'bx;
        
        endcase
    end
    
    assign ALUControl = TempALUControl;

endmodule
