`timescale 1ns / 1ps
//==============================================================//
//  Module:       reduce
//  File:         reduce.sv
//  Description:  Reduction unit to reduce the effective width of data retrieved from memory.
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module reduce (
    // Data inputs
    input  logic [31:0] BaseResult,

    // Control inputs
    input  logic [2:0]  width_src_i,

    // Data outputs
    output logic [31:0] result_o
);
    
    always @(*) begin
        case(width_src_i)
        
            //32-bit
            3'b000: result_o = BaseResult;
        
            //16-bit signed
            3'b010: result_o = {{16{BaseResult[15]}}, BaseResult[15:0]};
        
            //16-bit unsigned
            3'b110: result_o = {16'b0, BaseResult[15:0]};
        
            //8-bit signed
            3'b001: result_o = {{24{BaseResult[7]}}, BaseResult[7:0]};
        
            //8-bit unsigned
            3'b101: result_o = {24'b0, BaseResult[7:0]};
        
            //Undefined
            default: result_o = 32'bx;
        
        endcase
    
    end
    
endmodule