`timescale 1ns / 1ps
//==============================================================//
//  Module:       branch_resolution_unit
//  File:         branch_resolution_unit.sv
//  Description:  Resolves branch predictions. Determines if a branch occured.
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module branch_resolution_unit (
    // Instruction decode inputs
    input  logic [2:0] funct3,
    input  logic [1:0] BranchOp,

    // Status flag inputs
    input  logic       N,
    input  logic       Z,
    input  logic       C,
    input  logic       V,

    // Resolution output
    output logic       PCSrcRes
);

    //Branch signal computation
    always @(*) begin
        
        case(BranchOp)
            
            2'b00: PCSrcRes = 1'b0; //Non-branching instructions
            2'b01: PCSrcRes = 1'b1; //Jumping instructions
            
            //B-type instructions
            2'b11: begin
                
                //Type of branch dependant on funct3
                case(funct3)
                    
                    3'b000: PCSrcRes = Z;      //beq
                    3'b001: PCSrcRes = ~Z;     //bne
                    3'b101: PCSrcRes = ~(N^V); //bge
                    3'b111: PCSrcRes = C;      //bgeu
                    3'b100: PCSrcRes = N^V;    //blt
                    3'b110: PCSrcRes = ~C;     //bltu
                    default: PCSrcRes = 1'bx;   //Unknown branch condition
                
                endcase
                
            end
            
            default: PCSrcRes = 1'bx; //Unknown BranchOp
            
        endcase
    
    end

endmodule
