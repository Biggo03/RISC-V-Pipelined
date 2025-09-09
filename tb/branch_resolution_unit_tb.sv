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
    logic [1:0] branch_op;
    logic       neg_flag;
    logic       zero_flag;
    logic       carry_flag;
    logic       v_flag;
    logic       pc_src_res;
    logic       PCSrcResExp;

    // Queue to hold valid funct3 values
    logic [2:0] funct3Val [6];

    // Signal to hold value of N, Z, C, V
    logic [3:0] Flags [31:0];

    // Instantiate DUT
    branch_resolution_unit u_DUT (
        .funct3_i                       (funct3),
        .branch_op_i                    (branch_op),
        .neg_flag_i                     (neg_flag),
        .zero_flag_i                    (zero_flag),
        .carry_flag_i                   (carry_flag),
        .v_flag_i                       (v_flag),
        .pc_src_res_o                   (pc_src_res)
    );
    
    //Assert that expected and actual oputputs match
    task AssertCorrect();
        
        assert (pc_src_res === PCSrcResExp) else
        $fatal(1, "Error: branch_op: %b, funct3: %b\nN: %b, Z: %b, C: %b, V: %b\nExpected Output: %b\nActual Output:   %b", branch_op, funct3, neg_flag, zero_flag, carry_flag, v_flag, PCSrcResExp, pc_src_res);
    
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
        branch_op = 2'b00; PCSrcResExp = 1'b0; #10;
        AssertCorrect();
        
        //Jumps
        branch_op = 2'b01; PCSrcResExp = 1'b1; #10;
        AssertCorrect();
        
        //Conditional branches
        branch_op = 2'b11;
        
        //Initialize all possible combinations of flags
        for (int i = 0; i < 32; i++) begin
            Flags[i] = i;
        end
        
        foreach (funct3Val[i]) begin
            
            funct3 = funct3Val[i];
            
            for (int j = 0; j < 32; j++) begin
                
                //set Flag values
                neg_flag = Flags[j][0];
                neg_flag = Flags[j][1];
                neg_flag = Flags[j][2];
                neg_flag = Flags[j][3];
                
                //Determine correct output
                case (funct3Val[i])
                    3'b000: PCSrcResExp = zero_flag;
                    3'b001: PCSrcResExp = ~zero_flag;
                    3'b101: PCSrcResExp = ~(neg_flag ^ v_flag);
                    3'b111: PCSrcResExp = carry_flag;
                    3'b100: PCSrcResExp = neg_flag ^ v_flag;
                    3'b110: PCSrcResExp = ~carry_flag;
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
