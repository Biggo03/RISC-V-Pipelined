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

    // Stimulus and expected outputs
    logic [2:0] funct3;
    logic [1:0] BranchOp;
    logic       N;
    logic       Z;
    logic       C;
    logic       V;
    logic       PCSrcRes;
    logic       PCSrcResExp;

    // Queue to hold valid funct3 values
    logic [2:0] funct3Val [6];

    // Signal to hold value of N, Z, C, V
    logic [3:0] Flags [31:0];

    // Instantiate DUT
    branch_resolution_unit u_DUT (
        .funct3   (funct3),
        .BranchOp (BranchOp),
        .N        (N),
        .Z        (Z),
        .C        (C),
        .V        (V),
        .PCSrcRes    (PCSrcRes)
    );
    
    //Assert that expected and actual oputputs match
    task AssertCorrect();
        
        assert (PCSrcRes === PCSrcResExp) else
        $fatal(1, "Error: BranchOp: %b, funct3: %b\nN: %b, Z: %b, C: %b, V: %b\nExpected Output: %b\nActual Output:   %b", BranchOp, funct3, N, Z, C, V, PCSrcResExp, PCSrcRes);
    
    endtask

    initial begin
        
        dump_setup;
        funct3Val[0] = 3'b000;
        funct3Val[1] = 3'b001;
        funct3Val[2] = 3'b101;
        funct3Val[3] = 3'b111;
        funct3Val[4] = 3'b100;
        funct3Val[5] = 3'b110;

        //Non-branching instructions
        BranchOp = 2'b00; PCSrcResExp = 1'b0; #10;
        AssertCorrect();
        
        //Jumps
        BranchOp = 2'b01; PCSrcResExp = 1'b1; #10;
        AssertCorrect();
        
        //Conditional branches
        BranchOp = 2'b11;
        
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
                    3'b000: PCSrcResExp = Z;
                    3'b001: PCSrcResExp = ~Z;
                    3'b101: PCSrcResExp = ~(N ^ V);
                    3'b111: PCSrcResExp = C;
                    3'b100: PCSrcResExp = N ^ V;
                    3'b110: PCSrcResExp = ~C;
                    default: PCSrcResExp = 1'bx;
                endcase
                
                #10;
                AssertCorrect();
            
            end
        
        end
        
        $display("TEST PASSED");
        $finish;
             
    end


endmodule
