`timescale 1ns / 1ps
//==============================================================//
//  Module:       imm_extend
//  File:         imm_extend.sv
//  Description:  Extension unit used to extend immediates
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module imm_extend (
    // Instruction input
    input  logic [31:7] Instr,

    // Control input
    input  logic [2:0]  ImmSrc,

    // Data output
    output logic [31:0] ImmExt
);
    
    always @(*) begin
        case(ImmSrc)
            //I-Type
            3'b000: ImmExt = {{20{Instr[31]}}, Instr[31:20]};
            
            //S-Type
            3'b001: ImmExt = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};
            
            //B-Type
            3'b010: ImmExt = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0};
            
            //J-Type
            3'b011: ImmExt = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0};
            
            //U-Type
            3'b100: ImmExt = {Instr[31:12], 12'b0};
            
            //Undefined
            default: ImmExt = 32'bx; 
        endcase
    end
    
endmodule
