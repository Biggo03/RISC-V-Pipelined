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
                    
    reg [2:0] TempWidthSrc;
    
    always @(*) begin
        
        if (~WidthOp) TempWidthSrc = 3'b000; //Non-load/store instructions
        else begin
            
            //Width dependant on funct3
            case(funct3)
                3'b010: TempWidthSrc = 3'b000;  //lw, sw
                3'b001: TempWidthSrc = 3'b010;  //lh, sh
                3'b000: TempWidthSrc = 3'b001;  //lb, sb
                3'b101: TempWidthSrc = 3'b110;  //lhu
                3'b100: TempWidthSrc = 3'b101;  //lbu
                default: TempWidthSrc = 3'bxxx; //Unknown
            endcase
            
        end
    
    end
    
    //Assignment of temp value to proper signal
    assign WidthSrc = TempWidthSrc;

endmodule