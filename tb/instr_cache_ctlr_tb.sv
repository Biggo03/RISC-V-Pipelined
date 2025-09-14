`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 09:35:35 PM
// Design Name: 
// Module Name: InstrCacheController_TB
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


module instr_cache_ctlr_tb();

    logic [5:0]  set;
    logic [63:0] miss_array;
    logic [63:0] active_array;
    logic        instr_miss_f;
    logic        stall;

    logic        clk;
    logic        reset;
    logic [1:0]  pc_src_reg;
    logic [1:0]  branch_op_e;
    logic        instr_cache_rep_en;

    instr_cache_ctlr u_DUT (
        .clk_i                          (clk),
        .reset_i                        (reset),
        .set_i                          (set),
        .miss_array_i                   (miss_array),
        .pc_src_reg_i                   (pc_src_reg),
        .branch_op_e_i                  (branch_op_e),
        .active_array_o                 (active_array),
        .instr_miss_f_o                 (instr_miss_f),
        .instr_cache_rep_en_o           (instr_cache_rep_en)
    );
    
    always begin
        clk = ~clk; #5;
    end
    
    initial begin

        dump_setup;
    
        miss_array = 64'h0123456789ABCDEF; clk = 0; reset = 1;
    
        //Combinational output test
        for (int i = 0; i < 63; i = i + 1) begin
        
            set = i;
            #5;
            assert(active_array[i] === 1'b1) else $fatal(1, "Incorrect active array");
            assert(instr_miss_f === miss_array[i]) else $fatal(1, "Incorrect cache miss value");
            
        end
        
        //FSM test
        reset = 0; branch_op_e[1] = 0; pc_src_reg[0] = 0;
        
        //Normal operation hit
        branch_op_e[0] = 0; miss_array = 0; pc_src_reg[1] = 0;
        #10;
        assert(u_DUT.present_state === 0 & instr_cache_rep_en === 1) else $fatal(1, "Normal operation hit fail");
        
        //Normal operation miss
        miss_array = '1;
        #10;
        assert(u_DUT.present_state === 0 & instr_cache_rep_en === 1) else $fatal(1, "Normal operation miss fail");
        
        //Correct branch hit
        miss_array = 0; branch_op_e[0] = 1;
        #10;
        assert(u_DUT.present_state === 0 & instr_cache_rep_en === 1) else $fatal(1, "Correct branch hit step 1 failed");
        
        branch_op_e[0] = 0;
        #10;
        
        //Correct branch miss
        miss_array = {64{1'b1}} ; branch_op_e[0] = 1;
        #5;
        //instr_cache_rep_en goes low
        assert(instr_cache_rep_en === 0 && u_DUT.present_state === 0) else $fatal(1, "Correct branch miss instr_cache_rep_en error");
        #6;
        branch_op_e[0] = 0;
        //instr_cache_rep_en goes high based on present_state
        assert(u_DUT.present_state === 1 && instr_cache_rep_en === 1) else $fatal(1, "Correct branch miss state transition failed");
        #9;
        
        //Misprediction hit
        miss_array = 0; branch_op_e[0] = 1;
        #10;
        assert(u_DUT.present_state === 0 && instr_cache_rep_en === 1) else $fatal(1, "Misprediction hit error");
        #10;
        
        //Misprediction miss;
        miss_array = {64{1'b1}}; branch_op_e[0] = 1;
        #5;
        assert(instr_cache_rep_en === 0 && u_DUT.present_state === 0) else $fatal(1, "Misprediction miss instr_cache_rep_en error");
        #5;
        
        //At clk edge, indicate a miss
        pc_src_reg[1] = 1;
        #1;
        
        assert(instr_cache_rep_en === 0 && u_DUT.present_state === 1) else $fatal(1, "Misprediction miss state transition error");
        
        #9;
        branch_op_e[0] = 0; 
        
        //Allow pc_src_reg to update appropriately (after clock edge, not before)
        #1;
        pc_src_reg[1] = 0;
        #1;
        assert(instr_cache_rep_en === 1 && u_DUT.present_state === 0) else $fatal(1, "Misprediction miss state transition error (2)");
        
        $display("TEST PASSED");
        $finish;
        
    end
    
endmodule
