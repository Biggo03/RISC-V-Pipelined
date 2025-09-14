`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2024 03:55:16 PM
// Design Name: 
// Module Name: ALUdecoder_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for ALUdecoder
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_decoder_tb();
    
    // Stimulus and expected output
    logic [2:0] funct3;
    logic [1:0] alu_op;
    logic [6:0] funct7;
    logic [6:0] op;
    logic [3:0] alu_control;

    // Arrays for holding expected values based on corresponding funct3 value
    logic [3:0] ALUControlExp [7:0];

    // Array for holding all combos of op5 and funct7[5]
    logic [1:0] op5_funct7 [3:0];

    // Instantiate DUT
    alu_decoder u_DUT (
        .funct3_i                       (funct3),
        .alu_op_i                       (alu_op),
        .op                             (op),
        .funct7_i                       (funct7),
        .alu_control_o                  (alu_control)
    );
    
    //Task for printing assertions
    task PrintError(input int i);
        
        $fatal(1, "Error: alu_op: %b, funct3: %b, op[5]: %b, funct7[5]: %b\nExpected Output: %b\nActual Output:   %b", alu_op, funct3, op[5], funct7[5], ALUControlExp[i], alu_control);
        
    endtask
        
    initial begin

        dump_setup;

        ALUControlExp[0] = 4'b0;
        ALUControlExp[1] = 4'b0111;
        ALUControlExp[2] = 4'b0101;
        ALUControlExp[3] = 4'b0110;
        ALUControlExp[4] = 4'b0100;
        ALUControlExp[5] = 4'b0;
        ALUControlExp[6] = 4'b0011;
        ALUControlExp[7] = 4'b0010;


        for (int i = 0; i < 4; i++) begin
            op5_funct7[i] = i;
        end

        //S-type and I-type load instructions
        //Not dependant on any values other than alu_op
        alu_op = 2'b00; #10;
        
        assert (alu_control === 4'b1000) 
        else $fatal(1, "Error: alu_op: 00\nExpected output: %b\nActual output:   %b", 4'b1000, alu_control);
        
        //B-type instructions
        //Again not dependant on any values other than alu_op
        alu_op = 2'b01; #10;
        
        assert (alu_control === 4'b1001) 
        else $fatal(1, "Error: alu_op: 01\nExpected output: %b\n\Actual output:   %b", 4'b1001, alu_control);
        
        
        //All other operations depend on more than alu_op
        alu_op = 2'b10;
        
        for (integer i = 0; i < 8; i++) begin
            
            funct3 = i; 
            
            //Addition or subtraction
            if (funct3 == 3'b000) begin
                
                //00, 01, 10 == addition, 11 = subtraction
                for (integer j = 0; j < 4; j++) begin
                    
                    //set actual inputs
                    op[5] = op5_funct7[j][1];
                    funct7[5] = op5_funct7[j][0];
                    #10;
                    
                    if (op5_funct7[j] < 3) ALUControlExp[0] = 4'b1000;
                    else ALUControlExp[0] = 4'b1001;
                    
                    assert(alu_control === ALUControlExp[0]) else PrintError(0);
                    
                end
                
            //right shift, 00, 10 = logical, 11, 01 = arithmetic
            end else if (funct3 == 3'b101) begin
                
                for (int j = 0; j < 4; j++) begin
                    
                    //set actual inputs
                    op[5] = op5_funct7[j][1];
                    funct7[5] = op5_funct7[j][0];
                    #10;
                    
                    //Dependant on funct7[5], op5 does not change decoding
                    if (op5_funct7[j][0] == 1'b0) ALUControlExp[5] = 4'b0000;
                    else ALUControlExp[5] = 4'b0001;
                    
                    assert(alu_control === ALUControlExp[5]) else PrintError(5);
                    
                end
            
            //All other operations
            end else
                
                #10;
                assert (alu_control == ALUControlExp[i]) else PrintError(i);
                
            end
            
            alu_op = 2'b11; #10;
            
            assert(alu_control === 4'b0) else $fatal(1, "Error: Unused alu_op code results in unexpected output");
            
                $display("TEST PASSED");
                $finish;
        
      end
        
        

endmodule
