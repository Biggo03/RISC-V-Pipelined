`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2024 08:52:13 PM
// Design Name: 
// Module Name: reduce
// Project Name: riscvsingle
// Target Devices: 
// Tool Versions: 
// Description: This is an extension unit used to reduce the effective width of data retrieved from memory.
//
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module reduce (input [31:0] BaseResult,
               input [2:0] WidthSrc,
               output [31:0] Result);
    
    `include "ControlParams.vh"
    
    reg [31:0] TempResult;
    
    always @(*) begin
        case(WidthSrc)
        
            //32-bit
            WIDTH_WORD: TempResult = BaseResult;
        
            //16-bit signed
            WIDTH_HW_S: TempResult = {{16{BaseResult[15]}}, BaseResult[15:0]};
        
            //16-bit unsigned
            WIDTH_HW_U: TempResult = {16'b0, BaseResult[15:0]};
        
            //8-bit signed
            WIDTH_BYTE_S: TempResult = {{24{BaseResult[7]}}, BaseResult[7:0]};
        
            //8-bit unsigned
            WIDTH_BYTE_U: TempResult = {24'b0, BaseResult[7:0]};
        
            //Undefined
            default: TempResult = 32'bx;
        
        endcase
    
    end
    
    assign Result = TempResult;
    
    
endmodule
