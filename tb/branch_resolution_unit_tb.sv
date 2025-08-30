`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2024 05:46:53 PM
// Design Name: 
// Module Name: branchdecoder_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for branchdecoder module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module branch_resolution_unit_tb();

    //Stimulus and expected outputs
    logic [2:0] funct3;
    logic [1:0] BranchOp;
    logic N, Z, C, V, PCSrc, PCSrcExp;
    
    //queue to hold valid funct3 values
    logic [2:0] funct3Val [$] = '{3'b000, 3'b001, 3'b101, 3'b111, 3'b100, 3'b110};
    
    // signal to hold value of N, Z, C, V
    logic [3:0] Flags [31:0];
    
    //Instantiate DUT
    branch_resolution_unit DUT(funct3, BranchOp, N, Z, C, V, PCSrc);
    
    //Assert that expected and actual oputputs match
    task AssertCorrect();
        
        assert (PCSrc === PCSrcExp) else
        $fatal("Error: BranchOp: %b, funct3: %b\n\
                N: %b, Z: %b, C: %b, V: %b\n\
                Expected Output: %b\n\
                Actual Output:   %b", BranchOp, funct3, N, Z, C, V, PCSrcExp, PCSrc);
    
    endtask

    initial begin
        
        dump_setup;

        //Non-branching instructions
        BranchOp = 2'b00; PCSrcExp = 1'b0; #10;
        AssertCorrect();
        
        //Jumps
        BranchOp = 2'b01; PCSrcExp = 1'b1; #10;
        AssertCorrect();
        
        //Conditional branches
        BranchOp = 2'b10;
        
        //Initialize all possible combinations of flags
        for (int i = 0; i < 32; i++) begin
            Flags[i] = i;
        end
        
        foreach (funct3Val[i]) begin
            
            funct3 = funct3Val[i];
            
            for (int j = 0; j < 32; j++) begin
                
                //Set Flag values
                N = Flags[j][0];
                Z = Flags[j][1];
                C = Flags[j][2];
                V = Flags[j][3];
                
                //Determine correct output
                case (funct3Val[i])
                    3'b000: PCSrcExp = Z;
                    3'b001: PCSrcExp = ~Z;
                    3'b101: PCSrcExp = ~(N ^ V);
                    3'b111: PCSrcExp = C;
                    3'b100: PCSrcExp = N ^ V;
                    3'b110: PCSrcExp = ~C;
                    default: PCSrcExp = 1'bx;
                endcase
                
                #10;
                AssertCorrect();
            
            end
        
        end
        
        $display("Simulation Success!");
             
    end


endmodule
