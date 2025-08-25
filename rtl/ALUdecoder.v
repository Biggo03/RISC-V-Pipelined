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
                  
    reg [3:0] TempALUControl;
                  
    always @(*) begin
        
        case(ALUOp)
        2'b00: TempALUControl = 4'b1000; //S-type Instructions and I-type loads
        2'b01: TempALUControl = 4'b1001; //B-type Instructions
        
        //R- and I-Type instructions
        2'b10: begin
            
            //Different op depending on funct3
            case(funct3)
            
                3'b010: TempALUControl = 4'b0101; //SLT
                3'b011: TempALUControl = 4'b0110; //SLTU
                3'b110: TempALUControl = 4'b0011; //OR
                3'b100: TempALUControl = 4'b0100; //XOR
                3'b111: TempALUControl = 4'b0010; //AND
                3'b001: TempALUControl = 4'b0111; //Shift Left Logical
                
                //addition or subtraction
                3'b000: begin
                
                    //Sub if op[5] and funct7[5] = 1
                    if (op5 & funct7b5) TempALUControl = 4'b1001; //Sub
                    else TempALUControl = 4'b1000; //Add
                
                end
            
                //Shift Right Logical/Arithmetic
                3'b101: begin
                
                    // Logical, {op[5], funct7[5]} = 00, 10
                    if (~funct7b5) TempALUControl = 4'b0000; //SRL
                    //Arithmetic {op[5], funct7[5]} = 11, 01
                    else TempALUControl = 4'b0001; //SRA
            
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