`timescale 1ns / 1ps
//==============================================================//
//  Module:       width_decoder
//  File:         width_decoder.sv
//  Description:  Generates a width control signal
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module width_decoder (
    // Instruction inputs
    input  logic [2:0] funct3,
    input  logic       WidthOp,

    // Decode outputs
    output logic [2:0] WidthSrc
);
    
    always @(*) begin
        
        if (~WidthOp) WidthSrc = 3'b000; //Non-load/store instructions
        else begin
            
            //Width dependant on funct3
            case(funct3)
                3'b010: WidthSrc = 3'b000;  //lw, sw
                3'b001: WidthSrc = 3'b010;  //lh, sh
                3'b000: WidthSrc = 3'b001;  //lb, sb
                3'b101: WidthSrc = 3'b110;  //lhu
                3'b100: WidthSrc = 3'b101;  //lbu
                default: WidthSrc = 3'bxxx; //Unknown
            endcase
            
        end
    
    end

endmodule