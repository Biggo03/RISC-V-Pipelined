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

    logic [6:0] op;
    logic [2:0] ImmSrc, ResultSrc, ImmSrcExp, ResultSrcExp;
    logic [1:0] ALUOp, BranchOp, ALUOpExp, BranchOpExp;
    logic WidthOp, ALUSrc, PCBaseSrc, RegWrite, MemWrite;
    logic WidthOpExp, ALUSrcExp, PCBaseSrcExp, RegWriteExp, MemWriteExp;
    
    main_decoder DUT(op, ImmSrc, ResultSrc, ALUOp, BranchOp, WidthOp,
                    ALUSrc, PCBaseSrc, RegWrite, MemWrite);
    

    //Repetitive assertions warrant a task
    task CheckOutput();
        string msg;
    
        assert(RegWrite === RegWriteExp & WidthOp === WidthOpExp & ALUSrc === ALUSrcExp &
               PCBaseSrc === PCBaseSrcExp & MemWrite === MemWriteExp &
               ALUOp === ALUOpExp & BranchOp === BranchOpExp & 
               ImmSrc === ImmSrcExp & ResultSrc === ResultSrcExp)
               else $fatal(1, "Error: Incorrect output for operation %b\nExpected: RegWrite: %b,ImmSrc: %b, ALUSrc: %b, MemWrite: %b, ResultSrc: %b, BranchOp: %b, ALUOp: %b, WidthOp: %b, PCBaseSrc: %b\nActual:   RegWrite: %b,ImmSrc: %b, ALUSrc: %b, MemWrite: %b, ResultSrc: %b, BranchOp: %b, ALUOp: %b, WidthOp: %b, PCBaseSrc: %b", 
               op, RegWriteExp, ImmSrcExp, ALUSrcExp, MemWriteExp, ResultSrcExp, BranchOpExp, ALUOpExp, WidthOpExp, PCBaseSrcExp,
               RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, BranchOp, ALUOp, WidthOp, PCBaseSrc);
    endtask
    
    //Inputs ordered to match main decoder truth table
    //Local variable names take priority
    task SetExpected(input logic RegWrite,
                     input logic [2:0] ImmSrc,
                     input logic ALUSrc, MemWrite,
                     input logic [2:0] ResultSrc,
                     input logic [1:0] BranchOp, ALUOp,
                     input logic WidthOp, PCBaseSrc);
        
        RegWriteExp = RegWrite; WidthOpExp = WidthOp; ALUSrcExp = ALUSrc; PCBaseSrcExp = PCBaseSrc; MemWriteExp = MemWrite;
        ALUOpExp = ALUOp; BranchOpExp = BranchOp; ImmSrcExp = ImmSrc; ResultSrcExp = ResultSrc; 
        
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
