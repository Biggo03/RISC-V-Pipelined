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


module ALUdecoder_TB();
    
    //Stimulus and expected output
    logic [2:0] funct3;
    logic [1:0] ALUOp;
    logic op5, funct7b5;
    logic [3:0] ALUControl;
    
    //Arrays for holding expected values based on corrosponding funct3 value
    //x values in cases where output dependant on more than funct3
    logic [3:0] ALUControlExp [] = '{4'bx, 4'b0111, 4'b0101, 4'b0110, 4'b0100, 4'bx, 4'b0011, 4'b0010};
    
    //Array for holding all combos of op5 and funct7b5
    logic [1:0] op5_funct7 [] = '{2'b00, 2'b01, 2'b10, 2'b11};
    
    //Instantiate DUT
    ALUdecoder DUT(funct3, ALUOp, op5, funct7b5, ALUControl);
    
    //Task for printing assertions
    task PrintError(input int i);
        
        $fatal("Error: ALUOp: %b, funct3: %b, op5: %b, funct7b5: %b\n\
                Expected Output: %b\n\
                Actual Output:   %b", ALUOp, funct3, op5, funct7b5, ALUControlExp[i], ALUControl);
        
    endtask
        
    initial begin
        //S-type and I-type load instructions
        //Not dependant on any values other than ALUOp
        ALUOp = 2'b00; #10;
        
        assert (ALUControl === 4'b1000) 
        else $fatal("Error: ALUOp: 00\n\
                     Expected output: %b\n\
                     Actual output:   %b", 4'b1000, ALUControl);
        
        //B-type instructions
        //Again not dependant on any values other than ALUOp
        ALUOp = 2'b01; #10;
        
        assert (ALUControl === 4'b1001) 
        else $fatal("Error: ALUOp: 01\n\
                     Expected output: %b\n\
                     Actual output:   %b", 4'b1001, ALUControl);
        
        
        //All other operations depend on more than ALUOp
        ALUOp = 2'b10;
        
        for (int i = 0; i < 8; i++) begin
            
            funct3 = i; 
            
            //Addition or subtraction
            if (funct3 == 3'b000) begin
                
                //00, 01, 10 == addition, 11 = subtraction
                for (int j = 0; j < 4; j++) begin
                    
                    //Set actual inputs
                    op5 = op5_funct7[j][1];
                    funct7b5 = op5_funct7[j][0];
                    #10;
                    
                    if (op5_funct7[j] < 3) ALUControlExp[0] = 4'b1000;
                    else ALUControlExp[0] = 4'b1001;
                    
                    assert(ALUControl === ALUControlExp[0]) else PrintError(0);
                    
                end
                
            //right shift, 00, 10 = logical, 11, 01 = arithmetic
            end else if (funct3 == 3'b101) begin
                
                for (int j = 0; j < 4; j++) begin
                    
                    //Set actual inputs
                    op5 = op5_funct7[j][1];
                    funct7b5 = op5_funct7[j][0];
                    #10;
                    
                    //Dependant on funct7[5], op5 does not change decoding
                    if (op5_funct7[j][0] == 1'b0) ALUControlExp[5] = 4'b0000;
                    else ALUControlExp[5] = 4'b0001;
                    
                    assert(ALUControl === ALUControlExp[5]) else PrintError(5);
                    
                end
            
            //All other operations
            end else
                
                #10;
                assert (ALUControl == ALUControlExp[i]) else PrintError(i);
                
            end
            
            ALUOp = 2'b11; #10;
            
            assert(ALUControl === 4'bx) else $fatal("Error: Unused ALUOp code results in unexpected output");
            
            $display("Simulation Succesful!");
        
      end
        
        

endmodule
