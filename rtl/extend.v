`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2024 08:38:32 PM
// Design Name: 
// Module Name: extend
// Project Name: riscvsingle
// Target Devices: 
// Tool Versions: 
// Description: This is an extension unit used to extend immediates.
//              The extension performed is based on the type of instruction, and controlled by ImmSrc.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Only use Instr[31:7], as this is the only range in which immediates are encoded
//                      Can find truth table for this extension unit in git README
// 
//////////////////////////////////////////////////////////////////////////////////


module extend(input [31:7] Instr,
              input [2:0] ImmSrc,
              output [31:0] ImmExt);
        
    reg [31:0] TempImmExt;
    
    always @(*) begin
        case(ImmSrc)
            //I-Type
            3'b000: TempImmExt = {{20{Instr[31]}}, Instr[31:20]};
            
            //S-Type
            3'b001: TempImmExt = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};
            
            //B-Type
            3'b010: TempImmExt = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0};
            
            //J-Type
            3'b011: TempImmExt = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0};
            
            //U-Type
            3'b100: TempImmExt = {Instr[31:12], 12'b0};
            
            //Undefined
            default: TempImmExt = 32'bx; 
        endcase
    end
    
    assign ImmExt = TempImmExt;
    
endmodule
