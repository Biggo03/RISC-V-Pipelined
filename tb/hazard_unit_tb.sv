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
    logic       InstrMissF;

    // Decode stage inputs
    logic [4:0] Rs1D;
    logic [4:0] Rs2D;

    // Execute stage inputs
    logic [4:0] Rs1E;
    logic [4:0] Rs2E;
    logic [4:0] RdE;
    logic [2:0] ResultSrcE;
    logic [1:0] PCSrc;

    // Memory stage inputs
    logic [4:0] RdM;
    logic       RegWriteM;

    // Writeback stage inputs
    logic [4:0] RdW;
    logic       RegWriteW;

    // Branch predictor / cache inputs
    logic [1:0]  PCSrcReg;
    logic        InstrCacheRepActive;

    // Stall outputs
    logic       StallF;
    logic       StallD;
    logic       StallE;
    logic       StallM;
    logic       StallW;

    // Flush outputs
    logic       FlushD;
    logic       FlushE;

    // Forwarding outputs
    logic [1:0] ForwardAE;
    logic [1:0] ForwardBE;

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
        .InstrMissF          (InstrMissF),

        // Decode stage inputs
        .Rs1D                (Rs1D),
        .Rs2D                (Rs2D),

        // Execute stage inputs
        .Rs1E                (Rs1E),
        .Rs2E                (Rs2E),
        .RdE                 (RdE),
        .ResultSrcEb2        (ResultSrcE[2]),
        .PCSrcb1             (PCSrc[1]),

        // Memory stage inputs
        .RdM                 (RdM),
        .RegWriteM           (RegWriteM),

        // Writeback stage inputs
        .RdW                 (RdW),
        .RegWriteW           (RegWriteW),

        // Branch predictor / cache inputs
        .PCSrcReg            (PCSrcReg),
        .InstrCacheRepActive (InstrCacheRepActive),

        // Stall outputs
        .StallF              (StallF),
        .StallD              (StallD),
        .StallE              (StallE),
        .StallM              (StallM),
        .StallW              (StallW),

        // Flush outputs
        .FlushD              (FlushD),
        .FlushE              (FlushE),

        // Forwarding outputs
        .ForwardAE           (ForwardAE),
        .ForwardBE           (ForwardBE)
    );
    
    //Parameters to consolidate signal values
    localparam [1:0] NO_FORWARD = 2'b00;
    localparam [1:0] WB_FORWARD = 2'b01;
    localparam [1:0] MEM_FORWARD = 2'b10;
    

    task AssertForwardA();
        assert (ForwardExpectedA === ForwardAE) else $error(1, "Error: ForwardingAE doesn't match expected\nRs1E: %b, RdM: %b, RdW: %b, RegWriteM: %b RegWriteW: %b\nExpected Output: %b\nActual Output:   %b",
                                                              Rs1E, RdM, RdW, RegWriteM, RegWriteW, ForwardExpectedA, ForwardAE);
    
    endtask

    //Asserts correct outputs when checking functionality of ForwardBE
    task AssertForwardB();
        
        assert (ForwardExpectedB === ForwardAE) else $error(1, "Error: ForwardingAE doesn't match expected\nRs1E: %b, RdM: %b, RdW: %b, RegWriteM: %b RegWriteW: %b\nExpected Output: %b\nActual Output:   %b",
                                                              Rs1E, RdM, RdW, RegWriteM, RegWriteW, ForwardExpectedB, ForwardBE);
    endtask

    initial begin

        dump_setup;

        //Initial values
        error_cnt = 0;
        InstrMissF = 0;
        Rs1D = 0;
        Rs2D = 0;
        Rs1E = 0;
        Rs2E = 0;
        RdE = 0;
        ResultSrcE = 0;
        PCSrc = 0;
        RdM = 0;
        RegWriteM = 0;
        PCSrcReg = 0;
        InstrCacheRepActive = 0;

        #10;
        
        //Test all register combinations for ForwrdAE and ForwardBE
        for (int i = 0; i < 64; i++) begin
            
            //Do this so can test both types of forwarding
            if (i < 32) RdM = i;
            else RdW = i-32;
        
            for (int j = 0; j < 32; j++) begin
            
                Rs1E = j;
                Rs2E = j;
                
                //Test ForwardExpectedAE
                if (Rs1E === 0) ForwardExpectedA = NO_FORWARD;
                else if (Rs1E === RdM & RegWriteM) ForwardExpectedA = MEM_FORWARD; 
                else if (Rs1E === RdW & RegWriteW) ForwardExpectedA = WB_FORWARD;
                else ForwardExpectedA = NO_FORWARD;
                
                #10;
                
                AssertForwardA();
                
                //Test ForwardExpectedBE
                if (Rs2E === 0) ForwardExpectedB = NO_FORWARD;
                else if (Rs2E === RdM & RegWriteM) ForwardExpectedB = MEM_FORWARD; 
                else if (Rs2E === RdW & RegWriteW) ForwardExpectedB = WB_FORWARD;
                else ForwardExpectedB = NO_FORWARD;
                
                #10;
                
                AssertForwardB();
                
            end
            
        end
        
        $display("Forwarding Successful!");
        
        drive_no_hazard();
        expect_no_hazard();

        drive_load_hazard_rs1();
        expect_load_hazard("Rs1 Hazard Case");
        drive_no_hazard();

        drive_load_hazard_rs2();
        expect_load_hazard("Rs2 Hazard Case");
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
        ResultSrcE = 0;
        Rs1D = 0;
        Rs2D = 0;
        RdE = 1;

        InstrMissF = 0;
        PCSrc = 0;
        PCSrcReg = 0;
        InstrCacheRepActive = 0;
        #5;
    endtask

    task drive_load_hazard_rs1();
        ResultSrcE = 3'b111;
        Rs1D = 1;
        RdE = Rs1D;
        #5;
    endtask

    task drive_load_hazard_rs2();
        ResultSrcE = 3'b111;
        Rs2D = 2;
        RdE = Rs2D;
        #5;
    endtask

    task drive_cache_miss();
        InstrMissF = 1;
        InstrCacheRepActive = 1; //No branching instruction
        #5;
    endtask

    task drive_cache_hit_branch_miss();
        InstrMissF = 0;
        InstrCacheRepActive = 1;
        PCSrc = 2'b11;
        PCSrcReg = 0;
        #5;
    endtask

    //Scenario tasks
    task scenario_cache_miss_branch_miss(logic next_miss);
        InstrMissF = 1;
        InstrCacheRepActive = 0;
        PCSrcReg = 0;
        PCSrc = 2'b11;
        #10;

        InstrMissF = 1;
        InstrCacheRepActive = 0;
        PCSrcReg = 2'b11;
        PCSrc = 2'b11;
        #10;

        if (next_miss == 1) InstrMissF = 1;
        else InstrMissF = 0;
        InstrCacheRepActive = 1;
        PCSrcReg = 0;
        PCSrc = 0;

    endtask

    task scenario_cache_miss_branch_hit();
        InstrMissF = 1;
        InstrCacheRepActive = 0;
        PCSrc = 2'b01;
        PCSrcReg = 0;

        #10;

        InstrMissF = 1;
        InstrCacheRepActive = 1;
        PCSrc = 2'b01;
        PCSrcReg = 0;
        
    endtask

    //Expect tasks
    task expect_no_hazard();
        `CHECK(StallF == 0, "[%t] No hazard case: StallF should be 0", $time)
        `CHECK(StallD == 0, "[%t] No hazard case: StallD should be 0", $time)
        `CHECK(StallE == 0, "[%t] No hazard case: StallE should be 0", $time)
        `CHECK(StallM == 0, "[%t] No hazard case: StallM should be 0", $time)
        `CHECK(StallW == 0, "[%t] No hazard case: StallW should be 0", $time)

        `CHECK(FlushD == 0, "[%t] No hazard case: FlushD should be 0", $time)
        `CHECK(FlushE == 0, "[%t] No hazard case: FlushE should be 0", $time)
    endtask
    
    task expect_load_hazard(input string variant);
        `CHECK(StallF == 1, "[%t] %s: StallF should be 1", $time, variant)
        `CHECK(StallD == 1, "[%t] %s: StallD should be 1", $time, variant)

        `CHECK(FlushE == 1, "[%t] %s: FlushE should be 1", $time, variant)
    endtask

    task expect_cache_miss();
        `CHECK(StallF == 1, "[%t] Cache Miss Case: StallF should be 1", $time)
        `CHECK(StallD == 1, "[%t] Cache Miss Case: StallD should be 1", $time)
        `CHECK(StallE == 1, "[%t] Cache Miss Case: StallE should be 1", $time)
        `CHECK(StallM == 1, "[%t] Cache Miss Case: StallM should be 1", $time)
        `CHECK(StallW == 1, "[%t] Cache Miss Case: StallW should be 1", $time)
    endtask

    task expect_cache_hit_branch_miss();
        `CHECK(StallF == 0, "[%t] Cache Hit Branch Miss: StallF should be 0", $time)
        `CHECK(StallD == 0, "[%t] Cache Hit Branch Miss: StallD should be 0", $time)
        `CHECK(StallE == 0, "[%t] Cache Hit Branch Miss: StallE should be 0", $time)
        `CHECK(StallM == 0, "[%t] Cache Hit Branch Miss: StallM should be 0", $time)
        `CHECK(StallW == 0, "[%t] Cache Hit Branch Miss: StallW should be 0", $time)

        `CHECK(FlushD == 1, "[%t] Cache Hit Branch Miss: FlushD should be 1", $time)
        `CHECK(FlushE == 1, "[%t] Cache Hit Branch Miss: FlushE should be 1", $time)
    endtask

    task expect_cache_miss_branch_miss(logic next_miss);
        #5;
        //=================================================================================================================
        `CHECK(StallF == 1, "[%t] Cache Miss Branch Miss Cycle 1: StallF should be 1", $time)
        `CHECK(StallD == 1, "[%t] Cache Miss Branch Miss Cycle 1: StallD should be 1", $time)
        `CHECK(StallE == 1, "[%t] Cache Miss Branch Miss Cycle 1: StallE should be 1", $time)
        `CHECK(StallM == 1, "[%t] Cache Miss Branch Miss Cycle 1: StallM should be 1", $time)
        `CHECK(StallW == 1, "[%t] Cache Miss Branch Miss Cycle 1: StallW should be 1", $time)

        `CHECK(FlushD == 1, "[%t] Cache Miss Branch Miss Cycle 1: FlushD should be 1", $time)
        `CHECK(FlushE == 0, "[%t] Cache Miss Branch Miss Cycle 1: FlushE should be 0", $time)
        //=================================================================================================================
        #10;
        //=================================================================================================================
        `CHECK(StallF == 0, "[%t] Cache Miss Branch Miss Cycle 2: StallF should be 0", $time)
        `CHECK(StallD == 1, "[%t] Cache Miss Branch Miss Cycle 2: StallD should be 1", $time)
        `CHECK(StallE == 1, "[%t] Cache Miss Branch Miss Cycle 2: StallE should be 1", $time)
        `CHECK(StallM == 1, "[%t] Cache Miss Branch Miss Cycle 2: StallM should be 1", $time)
        `CHECK(StallW == 1, "[%t] Cache Miss Branch Miss Cycle 2: StallW should be 1", $time)

        `CHECK(FlushD == 1, "[%t] Cache Miss Branch Miss Cycle 2: FlushD should be 1", $time)
        `CHECK(FlushE == 1, "[%t] Cache Miss Branch Miss Cycle 2: FlushE should be 1", $time)
        //=================================================================================================================
        #10;
        //=================================================================================================================
        `CHECK(StallF == next_miss, "[%t] Cache Miss Branch Miss Cycle 3: StallF should be %b", $time, next_miss)
        `CHECK(StallD == next_miss, "[%t] Cache Miss Branch Miss Cycle 3: StallD should be %b", $time, next_miss)
        `CHECK(StallE == next_miss, "[%t] Cache Miss Branch Miss Cycle 3: StallE should be %b", $time, next_miss)
        `CHECK(StallM == next_miss, "[%t] Cache Miss Branch Miss Cycle 3: StallM should be %b", $time, next_miss)
        `CHECK(StallW == next_miss, "[%t] Cache Miss Branch Miss Cycle 3: StallW should be %b", $time, next_miss)

        `CHECK(FlushD == 0, "[%t] Cache Miss Branch Miss Cycle 3: FlushD should be 0", $time)
        `CHECK(FlushE == 0, "[%t] Cache Miss Branch Miss Cycle 3: FlushE should be 0", $time)
        //=================================================================================================================
    endtask

    task expect_cache_miss_branch_hit();
        #5;
        //=================================================================================================================
        `CHECK(StallF == 1, "[%t] Cache Miss Branch Hit Cycle 1: StallF should be 1", $time)
        `CHECK(StallD == 1, "[%t] Cache Miss Branch Hit Cycle 1: StallD should be 1", $time)
        `CHECK(StallE == 1, "[%t] Cache Miss Branch Hit Cycle 1: StallE should be 1", $time)
        `CHECK(StallM == 1, "[%t] Cache Miss Branch Hit Cycle 1: StallM should be 1", $time)
        `CHECK(StallW == 1, "[%t] Cache Miss Branch Hit Cycle 1: StallW should be 1", $time)
        //=================================================================================================================
        #10;
        //=================================================================================================================
        `CHECK(StallF == 1, "[%t] Cache Miss Branch Hit Cycle 2: StallF should be 1", $time)
        `CHECK(StallD == 1, "[%t] Cache Miss Branch Hit Cycle 2: StallD should be 1", $time)
        `CHECK(StallE == 1, "[%t] Cache Miss Branch Hit Cycle 2: StallE should be 1", $time)
        `CHECK(StallM == 1, "[%t] Cache Miss Branch Hit Cycle 2: StallM should be 1", $time)
        `CHECK(StallW == 1, "[%t] Cache Miss Branch Hit Cycle 2: StallW should be 1", $time)
        //=================================================================================================================
    endtask

endmodule


