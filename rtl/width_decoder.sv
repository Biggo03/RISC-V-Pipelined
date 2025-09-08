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
    input  logic [2:0] funct3_i,
    input  logic       width_op_i,

    // Decode outputs
    output logic [2:0] width_src_o
);
    
    always @(*) begin
        
        if (~width_op_i) width_src_o = 3'b000; //Non-load/store instructions
        else begin
            
            //Width dependant on funct3_i
            case(funct3_i)
                3'b010: width_src_o = 3'b000;  //lw, sw
                3'b001: width_src_o = 3'b010;  //lh, sh
                3'b000: width_src_o = 3'b001;  //lb, sb
                3'b101: width_src_o = 3'b110;  //lhu
                3'b100: width_src_o = 3'b101;  //lbu
                default: width_src_o = 3'bxxx; //Unknown
            endcase
            
        end
    
    end

endmodule