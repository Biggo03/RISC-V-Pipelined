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
    input  logic [2:0] funct3_i,
    input  logic [1:0] branch_op_i,

    // Status flag inputs
    input  logic       neg_flag_i,
    input  logic       zero_flag_i,
    input  logic       carry_flag_i,
    input  logic       v_flag_i,

    // Resolution output
    output logic       pc_src_res_o
);

    //Branch signal computation
    always @(*) begin
        
        case(branch_op_i)
            
            2'b00: pc_src_res_o = 1'b0; //Non-branching instructions
            2'b01: pc_src_res_o = 1'b1; //Jumping instructions
            
            //B-type instructions
            2'b11: begin
                
                //Type of branch dependant on funct3_i
                case(funct3_i)
                    
                    3'b000: pc_src_res_o = zero_flag_i;      //beq
                    3'b001: pc_src_res_o = ~zero_flag_i;     //bne
                    3'b101: pc_src_res_o = ~(neg_flag_i^v_flag_i); //bge
                    3'b111: pc_src_res_o = carry_flag_i;      //bgeu
                    3'b100: pc_src_res_o = neg_flag_i^v_flag_i;    //blt
                    3'b110: pc_src_res_o = ~carry_flag_i;     //bltu
                    default: pc_src_res_o = 1'bx;   //Unknown branch condition
                
                endcase
                
            end
            
            default: pc_src_res_o = 1'bx; //Unknown branch_op_i
            
        endcase
    
    end

endmodule
