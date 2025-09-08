`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/11/2024 10:28:25 AM
// Design Name: 
// Module Name: maindecoder_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for maindecoder module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module main_decoder_tb();

    //Stimulus signals
    logic [6:0] op;
    logic [2:0] imm_src;
    logic [2:0] result_src;
    logic [1:0] alu_op;
    logic [1:0] branch_op;
    logic       width_op;
    logic       alu_src;
    logic       pc_base_src;
    logic       reg_write;
    logic       mem_write;

    //Expected signals
    logic [2:0] ImmSrcExp;
    logic [2:0] ResultSrcExp;
    logic [1:0] ALUOpExp;
    logic [1:0] BranchOpExp;
    logic       WidthOpExp;
    logic       ALUSrcExp;
    logic       PCBaseSrcExp;
    logic       RegWriteExp;
    logic       MemWriteExp;

    main_decoder u_DUT (
        .op                             (op),
        .imm_src_o                      (imm_src),
        .result_src_o                   (result_src),
        .alu_op_o                       (alu_op),
        .branch_op_o                    (branch_op),
        .width_op_o                     (width_op),
        .alu_src_o                      (alu_src),
        .pc_base_src_o                  (pc_base_src),
        .reg_write_o                    (reg_write),
        .mem_write_o                    (mem_write)
    );
    

    //Repetitive assertions warrant a task
    task CheckOutput();
        string msg;
    
        assert(reg_write === RegWriteExp & width_op === WidthOpExp & alu_src === ALUSrcExp &
               pc_base_src === PCBaseSrcExp & mem_write === MemWriteExp &
               alu_op === ALUOpExp & branch_op === BranchOpExp & 
               imm_src === ImmSrcExp & result_src === ResultSrcExp)
               else $fatal(1, "Error: Incorrect output for operation %b\nExpected: reg_write: %b,imm_src: %b, alu_src: %b, mem_write: %b, result_src: %b, branch_op: %b, alu_op: %b, width_op: %b, pc_base_src: %b\nActual:   reg_write: %b,imm_src: %b, alu_src: %b, mem_write: %b, result_src: %b, branch_op: %b, alu_op: %b, width_op: %b, pc_base_src: %b", 
               op, RegWriteExp, ImmSrcExp, ALUSrcExp, MemWriteExp, ResultSrcExp, BranchOpExp, ALUOpExp, WidthOpExp, PCBaseSrcExp,
               reg_write, imm_src, alu_src, mem_write, result_src, branch_op, alu_op, width_op, pc_base_src);
    endtask
    
    //inputs ordered to match main decoder truth table
    //Local variable names take priority
    task SetExpected(input logic reg_write,
                     input logic [2:0] imm_src,
                     input logic alu_src, mem_write,
                     input logic [2:0] result_src,
                     input logic [1:0] branch_op, alu_op,
                     input logic width_op, pc_base_src);
        
        RegWriteExp = reg_write; WidthOpExp = width_op; ALUSrcExp = alu_src; PCBaseSrcExp = pc_base_src; MemWriteExp = mem_write;
        ALUOpExp = alu_op; BranchOpExp = branch_op; ImmSrcExp = imm_src; ResultSrcExp = result_src; 
        
    endtask
   
    //RegWriteExp, WidthOpExp, ALUSrcExp, PCBaseSrcExp, MemWriteExp, ALUOpExp, BranchOpExp, ImmSrcExp, ResultSrcExp
   
    initial begin

        dump_setup;
        
        //R-Type Instructions
        op = 7'b0110011; 
        SetExpected(1'b1, 3'bx, 1'b0, 1'b0, 3'b000, 2'b00, 2'b10, 1'b0, 1'bx);
        #10;
        CheckOutput();
        
        //I-Type ALU Instructions
        op = 7'b0010011;
        SetExpected(1'b1, 3'b000, 1'b1, 1'b0, 3'b000, 2'b00, 2'b10, 1'b0, 1'bx);
        #10;
        CheckOutput();
        
        //I-Type Load Instructions
        op = 7'b0000011; 
        SetExpected(1'b1, 3'b000, 1'b1, 1'b0, 3'b100, 2'b00, 2'b00, 1'b1, 1'bx);
        #10;
        CheckOutput();
        
        //S-Type Instructions
        op = 7'b0100011; 
        SetExpected(1'b0, 3'b001, 1'b1, 1'b1, 3'b0xx, 2'b00, 2'b00, 1'b1, 1'bx);
        #10;
        CheckOutput();
        
        //B-type Instructions
        op = 7'b1100011;
        SetExpected(1'b0, 3'b010, 1'b0, 1'b0, 3'b0xx, 2'b11, 2'b01, 1'bx, 1'b0);
        #10;
        CheckOutput();
        
        //jal
        op = 7'b1101111;
        SetExpected(1'b1, 3'b011, 1'bx, 1'b0, 3'b010, 2'b01, 2'bx, 1'b0, 1'b0);
        #10;
        CheckOutput();
        
        //jalr
        op = 7'b1100111;
        SetExpected(1'b1, 3'b000, 1'bx, 1'b0, 3'b010, 2'b01, 2'bx, 1'b0, 1'b1);
        #10;
        CheckOutput();
        
        //lui
        op = 7'b0110111;
        SetExpected(1'b1, 3'b100, 1'bx, 1'b0, 3'b011, 2'b00, 2'bxx, 1'b0, 1'bx);
        #10;
        CheckOutput();
        
        //auipc
        op = 7'b0010111;
        SetExpected(1'b1, 3'b100, 1'bx, 1'b0, 3'b001, 2'b00, 2'bx, 1'b0, 1'b0);
        #10;
        CheckOutput();
        
        //Unused opcode
        op = 7'b0;
        SetExpected(1'b0, 3'b0, 1'b0, 1'b0, 3'b0, 2'b0, 2'b0, 1'b0, 1'b0);
        #10;
        CheckOutput();
        
        $display("TEST PASSED");
        $finish;
        
    end

endmodule
