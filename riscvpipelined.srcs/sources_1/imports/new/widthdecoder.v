`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2024 06:15:16 PM
// Design Name: 
// Module Name: widthdecoder
// Project Name: riscvsingle
// Target Devices: 
// Tool Versions: 
// Description: Uses WidthOp and funct3 in order to determine the control signal WidthSrc.
//              This signal controls the width of stored instructions, and all data passed through result multiplexer.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module widthdecoder(input [2:0] funct3,
                    input WidthOp,
                    output [2:0] WidthSrc);
    
    `include "ControlParams.vh"
    
    reg [2:0] TempWidthSrc;
    
    always @(*) begin
        
        if (~WidthOp) TempWidthSrc = 3'b000; //Non-load/store instructions
        else begin
            
            //Width dependant on funct3
            case(funct3)
                3'b010: TempWidthSrc = WIDTH_WORD;  //lw, sw
                3'b001: TempWidthSrc = WIDTH_HW_S;  //lh, sh
                3'b000: TempWidthSrc = WIDTH_BYTE_S;  //lb, sb
                3'b101: TempWidthSrc = WIDTH_HW_U;  //lhu
                3'b100: TempWidthSrc = WIDTH_BYTE_U;  //lbu
                default: TempWidthSrc = 3'bxxx; //Unknown
            endcase
            
        end
    
    end
    
    //Assignment of temp value to proper signal
    assign WidthSrc = TempWidthSrc;

endmodule
