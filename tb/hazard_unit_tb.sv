`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2024 04:04:23 PM
// Design Name: 
// Module Name: hazardcontrol_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module hazard_unit_tb();
    `include "tb_macros.sv"

    // ---------------------------------------------------
    // Stimulus signals
    // ---------------------------------------------------
    // Fetch stage inputs
    logic       instr_miss_f;

    // Decode stage inputs
    logic [4:0] rs1_d;
    logic [4:0] rs2_d;

    // Execute stage inputs
    logic [4:0] rs1_e;
    logic [4:0] rs2_e;
    logic [4:0] rd_e;
    logic [2:0] result_src_e;
    logic [1:0] pc_src;

    // Memory stage inputs
    logic [4:0] rd_m;
    logic       reg_write_m;

    // Writeback stage inputs
    logic [4:0] rd_w;
    logic       reg_write_w;

    // Branch predictor / cache inputs
    logic [1:0]  pc_src_reg;
    logic        instr_cache_rep_en;

    // stall outputs
    logic       stall_f;
    logic       stall_d;
    logic       stall_e;
    logic       stall_m;
    logic       stall_w;

    // flush outputs
    logic       flush_d;
    logic       flush_e;

    // Forwarding outputs
    logic [1:0] forward_a_e;
    logic [1:0] forward_b_e;

    // ---------------------------------------------------
    // Expected results
    // ---------------------------------------------------
    logic [1:0] ForwardExpectedA;
    logic [1:0] ForwardExpectedB;

    int error_cnt;

    // ---------------------------------------------------
    // DUT instantiation
    // ---------------------------------------------------
    hazard_unit u_DUT (
        // Fetch stage inputs
        .instr_miss_f_i                 (instr_miss_f),

        // Decode stage inputs
        .rs1_d_i                        (rs1_d),
        .rs2_d_i                        (rs2_d),

        // Execute stage inputs
        .rs1_e_i                        (rs1_e),
        .rs2_e_i                        (rs2_e),
        .rd_e_i                         (rd_e),
        .result_src_e_i                 (result_src_e),
        .pc_src_i                       (pc_src),

        // Memory stage inputs
        .rd_m_i                         (rd_m),
        .reg_write_m_i                  (reg_write_m),

        // Writeback stage inputs
        .rd_w_i                         (rd_w),
        .reg_write_w_i                  (reg_write_w),

        // Branch predictor / cache inputs
        .pc_src_reg_i                   (pc_src_reg),
        .instr_cache_rep_en_i           (instr_cache_rep_en),

        // stall outputs
        .stall_f_o                      (stall_f),
        .stall_d_o                      (stall_d),
        .stall_e_o                      (stall_e),
        .stall_m_o                      (stall_m),
        .stall_w_o                      (stall_w),

        // flush outputs
        .flush_d_o                      (flush_d),
        .flush_e_o                      (flush_e),

        // Forwarding outputs
        .forward_a_e_o                  (forward_a_e),
        .forward_b_e_o                  (forward_b_e)
    );
    
    //Parameters to consolidate signal values
    localparam [1:0] NO_FORWARD = 2'b00;
    localparam [1:0] WB_FORWARD = 2'b01;
    localparam [1:0] MEM_FORWARD = 2'b10;
    

    task AssertForwardA();
        assert (ForwardExpectedA === forward_a_e) else $error(1, "Error: ForwardingAE doesn't match expected\nRs1E: %b, rd_m: %b, rd_w: %b, reg_write_m: %b reg_write_w: %b\nExpected Output: %b\nActual Output:   %b",
                                                              rs1_e, rd_m, rd_w, reg_write_m, reg_write_w, ForwardExpectedA, forward_a_e);
    
    endtask

    //Asserts correct outputs when checking functionality of forward_b_e
    task AssertForwardB();
        
        assert (ForwardExpectedB === forward_a_e) else $error(1, "Error: ForwardingAE doesn't match expected\nRs1E: %b, rd_m: %b, rd_w: %b, reg_write_m: %b reg_write_w: %b\nExpected Output: %b\nActual Output:   %b",
                                                              rs1_e, rd_m, rd_w, reg_write_m, reg_write_w, ForwardExpectedB, forward_b_e);
    endtask

    initial begin

        dump_setup;

        //Initial values
        error_cnt = 0;
        instr_miss_f = 0;
        rs1_d = 0;
        rs2_d = 0;
        rs1_e = 0;
        rs2_e = 0;
        rd_e = 0;
        result_src_e = 0;
        pc_src = 0;
        rd_m = 0;
        reg_write_m = 0;
        pc_src_reg = 0;
        instr_cache_rep_en = 0;

        #10;
        
        //Test all register combinations for ForwrdAE and forward_b_e
        for (int i = 0; i < 64; i++) begin
            
            //Do this so can test both types of forwarding
            if (i < 32) rd_m = i;
            else rd_w = i-32;
        
            for (int j = 0; j < 32; j++) begin
            
                rs1_e = j;
                rs2_e = j;
                
                //Test ForwardExpectedAE
                if (rs1_e === 0) ForwardExpectedA = NO_FORWARD;
                else if (rs1_e === rd_m & reg_write_m) ForwardExpectedA = MEM_FORWARD; 
                else if (rs1_e === rd_w & reg_write_w) ForwardExpectedA = WB_FORWARD;
                else ForwardExpectedA = NO_FORWARD;
                
                #10;
                
                AssertForwardA();
                
                //Test ForwardExpectedBE
                if (rs2_e === 0) ForwardExpectedB = NO_FORWARD;
                else if (rs2_e === rd_m & reg_write_m) ForwardExpectedB = MEM_FORWARD; 
                else if (rs2_e === rd_w & reg_write_w) ForwardExpectedB = WB_FORWARD;
                else ForwardExpectedB = NO_FORWARD;
                
                #10;
                
                AssertForwardB();
                
            end
            
        end
        
        $display("Forwarding Successful!");
        
        drive_no_hazard();
        expect_no_hazard();

        drive_load_hazard_rs1();
        expect_load_hazard("rs1 Hazard Case");
        drive_no_hazard();

        drive_load_hazard_rs2();
        expect_load_hazard("rs2 Hazard Case");
        drive_no_hazard();

        drive_cache_miss();
        expect_cache_miss();
        drive_no_hazard();

        drive_cache_hit_branch_miss();
        expect_cache_hit_branch_miss();
        drive_no_hazard();

        fork
            scenario_cache_miss_branch_miss(1'b1);
            expect_cache_miss_branch_miss(1'b1);
        join
        drive_no_hazard();

        fork
            scenario_cache_miss_branch_miss(1'b0);
            expect_cache_miss_branch_miss(1'b0);
        join
        drive_no_hazard();

        fork
            scenario_cache_miss_branch_hit();
            expect_cache_miss_branch_hit();
        join
        drive_no_hazard();

        if (error_cnt == 0) $display("TEST PASSED");
        else $display("TEST FAILED");
        $finish;
        
    end

    //Drive tasks
    task drive_no_hazard();
        result_src_e = 0;
        rs1_d = 0;
        rs2_d = 0;
        rd_e = 1;

        instr_miss_f = 0;
        pc_src = 0;
        pc_src_reg = 0;
        instr_cache_rep_en = 0;
        #5;
    endtask

    task drive_load_hazard_rs1();
        result_src_e = 3'b100;
        rs1_d = 1;
        rd_e = rs1_d;
        #5;
    endtask

    task drive_load_hazard_rs2();
        result_src_e = 3'b100;
        rs2_d = 2;
        rd_e = rs2_d;
        #5;
    endtask

    task drive_cache_miss();
        instr_miss_f = 1;
        instr_cache_rep_en = 1; //No branching instruction
        #5;
    endtask

    task drive_cache_hit_branch_miss();
        instr_miss_f = 0;
        instr_cache_rep_en = 1;
        pc_src = 2'b11;
        pc_src_reg = 0;
        #5;
    endtask

    //Scenario tasks
    task scenario_cache_miss_branch_miss(logic next_miss);
        instr_miss_f = 1;
        instr_cache_rep_en = 0;
        pc_src_reg = 0;
        pc_src = 2'b11;
        #10;

        instr_miss_f = 1;
        instr_cache_rep_en = 0;
        pc_src_reg = 2'b11;
        pc_src = 2'b11;
        #10;

        if (next_miss == 1) instr_miss_f = 1;
        else instr_miss_f = 0;
        instr_cache_rep_en = 1;
        pc_src_reg = 0;
        pc_src = 0;

    endtask

    task scenario_cache_miss_branch_hit();
        instr_miss_f = 1;
        instr_cache_rep_en = 0;
        pc_src = 2'b01;
        pc_src_reg = 0;

        #10;

        instr_miss_f = 1;
        instr_cache_rep_en = 1;
        pc_src = 2'b01;
        pc_src_reg = 0;
        
    endtask

    //Expect tasks
    task expect_no_hazard();
        `CHECK(stall_f == 0, "[%t] No hazard case: stall_f should be 0", $time)
        `CHECK(stall_d == 0, "[%t] No hazard case: stall_d should be 0", $time)
        `CHECK(stall_e == 0, "[%t] No hazard case: stall_e should be 0", $time)
        `CHECK(stall_m == 0, "[%t] No hazard case: stall_m should be 0", $time)
        `CHECK(stall_w == 0, "[%t] No hazard case: stall_w should be 0", $time)

        `CHECK(flush_d == 0, "[%t] No hazard case: flush_d should be 0", $time)
        `CHECK(flush_e == 0, "[%t] No hazard case: flush_e should be 0", $time)
    endtask
    
    task expect_load_hazard(input string variant);
        `CHECK(stall_f == 1, "[%t] %s: stall_f should be 1", $time, variant)
        `CHECK(stall_d == 1, "[%t] %s: stall_d should be 1", $time, variant)

        `CHECK(flush_e == 1, "[%t] %s: flush_e should be 1", $time, variant)
    endtask

    task expect_cache_miss();
        `CHECK(stall_f == 1, "[%t] Cache Miss Case: stall_f should be 1", $time)
        `CHECK(stall_d == 1, "[%t] Cache Miss Case: stall_d should be 1", $time)
        `CHECK(stall_e == 1, "[%t] Cache Miss Case: stall_e should be 1", $time)
        `CHECK(stall_m == 1, "[%t] Cache Miss Case: stall_m should be 1", $time)
        `CHECK(stall_w == 1, "[%t] Cache Miss Case: stall_w should be 1", $time)
    endtask

    task expect_cache_hit_branch_miss();
        `CHECK(stall_f == 0, "[%t] Cache Hit Branch Miss: stall_f should be 0", $time)
        `CHECK(stall_d == 0, "[%t] Cache Hit Branch Miss: stall_d should be 0", $time)
        `CHECK(stall_e == 0, "[%t] Cache Hit Branch Miss: stall_e should be 0", $time)
        `CHECK(stall_m == 0, "[%t] Cache Hit Branch Miss: stall_m should be 0", $time)
        `CHECK(stall_w == 0, "[%t] Cache Hit Branch Miss: stall_w should be 0", $time)

        `CHECK(flush_d == 1, "[%t] Cache Hit Branch Miss: flush_d should be 1", $time)
        `CHECK(flush_e == 1, "[%t] Cache Hit Branch Miss: flush_e should be 1", $time)
    endtask

    task expect_cache_miss_branch_miss(logic next_miss);
        #5;
        //=================================================================================================================
        `CHECK(stall_f == 1, "[%t] Cache Miss Branch Miss Cycle 1: stall_f should be 1", $time)
        `CHECK(stall_d == 1, "[%t] Cache Miss Branch Miss Cycle 1: stall_d should be 1", $time)
        `CHECK(stall_e == 1, "[%t] Cache Miss Branch Miss Cycle 1: stall_e should be 1", $time)
        `CHECK(stall_m == 1, "[%t] Cache Miss Branch Miss Cycle 1: stall_m should be 1", $time)
        `CHECK(stall_w == 1, "[%t] Cache Miss Branch Miss Cycle 1: stall_w should be 1", $time)

        `CHECK(flush_d == 1, "[%t] Cache Miss Branch Miss Cycle 1: flush_d should be 1", $time)
        `CHECK(flush_e == 0, "[%t] Cache Miss Branch Miss Cycle 1: flush_e should be 0", $time)
        //=================================================================================================================
        #10;
        //=================================================================================================================
        `CHECK(stall_f == 0, "[%t] Cache Miss Branch Miss Cycle 2: stall_f should be 0", $time)
        `CHECK(stall_d == 1, "[%t] Cache Miss Branch Miss Cycle 2: stall_d should be 1", $time)
        `CHECK(stall_e == 1, "[%t] Cache Miss Branch Miss Cycle 2: stall_e should be 1", $time)
        `CHECK(stall_m == 1, "[%t] Cache Miss Branch Miss Cycle 2: stall_m should be 1", $time)
        `CHECK(stall_w == 1, "[%t] Cache Miss Branch Miss Cycle 2: stall_w should be 1", $time)

        `CHECK(flush_d == 1, "[%t] Cache Miss Branch Miss Cycle 2: flush_d should be 1", $time)
        `CHECK(flush_e == 1, "[%t] Cache Miss Branch Miss Cycle 2: flush_e should be 1", $time)
        //=================================================================================================================
        #10;
        //=================================================================================================================
        `CHECK(stall_f == next_miss, "[%t] Cache Miss Branch Miss Cycle 3: stall_f should be %b", $time, next_miss)
        `CHECK(stall_d == next_miss, "[%t] Cache Miss Branch Miss Cycle 3: stall_d should be %b", $time, next_miss)
        `CHECK(stall_e == next_miss, "[%t] Cache Miss Branch Miss Cycle 3: stall_e should be %b", $time, next_miss)
        `CHECK(stall_m == next_miss, "[%t] Cache Miss Branch Miss Cycle 3: stall_m should be %b", $time, next_miss)
        `CHECK(stall_w == next_miss, "[%t] Cache Miss Branch Miss Cycle 3: stall_w should be %b", $time, next_miss)

        `CHECK(flush_d == 0, "[%t] Cache Miss Branch Miss Cycle 3: flush_d should be 0", $time)
        `CHECK(flush_e == 0, "[%t] Cache Miss Branch Miss Cycle 3: flush_e should be 0", $time)
        //=================================================================================================================
    endtask

    task expect_cache_miss_branch_hit();
        #5;
        //=================================================================================================================
        `CHECK(stall_f == 1, "[%t] Cache Miss Branch Hit Cycle 1: stall_f should be 1", $time)
        `CHECK(stall_d == 1, "[%t] Cache Miss Branch Hit Cycle 1: stall_d should be 1", $time)
        `CHECK(stall_e == 1, "[%t] Cache Miss Branch Hit Cycle 1: stall_e should be 1", $time)
        `CHECK(stall_m == 1, "[%t] Cache Miss Branch Hit Cycle 1: stall_m should be 1", $time)
        `CHECK(stall_w == 1, "[%t] Cache Miss Branch Hit Cycle 1: stall_w should be 1", $time)
        //=================================================================================================================
        #10;
        //=================================================================================================================
        `CHECK(stall_f == 1, "[%t] Cache Miss Branch Hit Cycle 2: stall_f should be 1", $time)
        `CHECK(stall_d == 1, "[%t] Cache Miss Branch Hit Cycle 2: stall_d should be 1", $time)
        `CHECK(stall_e == 1, "[%t] Cache Miss Branch Hit Cycle 2: stall_e should be 1", $time)
        `CHECK(stall_m == 1, "[%t] Cache Miss Branch Hit Cycle 2: stall_m should be 1", $time)
        `CHECK(stall_w == 1, "[%t] Cache Miss Branch Hit Cycle 2: stall_w should be 1", $time)
        //=================================================================================================================
    endtask

endmodule


