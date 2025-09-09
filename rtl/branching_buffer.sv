`timescale 1ns / 1ps
//==============================================================//
//  Module:       branching_buffer
//  File:         branching_buffer.sv
//  Description:  Contains and controls local branch predictors
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        Uses pc_e for corrections, and local predictor updates, uses pc_f_i for fetching predictions
//==============================================================//

module branching_buffer (
    // Clock & reset_i
    input  logic        clk_i,
    input  logic        reset_i,

    // pc inputs
    input  logic [31:0] pc_target_e_i,
    input  logic [9:0]  pc_f_i,
    input  logic [9:0]  pc_e,

    // Control inputs
    input  logic [1:0]  local_src_i,
    input  logic        pc_src_res_e_i,
    input  logic        target_match_i,
    input  logic [1:0]  branch_op_e_i,

    // Branch predictor outputs
    output logic        pc_src_pred_f_o,
    output logic [31:0] pred_pc_target_f_o
);

    // ----- Memories -----
    (* ram_style = "distributed" *) reg [31:0] buffer_entry [1023:0];
    logic [3:0] lp_outputs [1023:0];
    
    // ----- Control inputs -----
    logic [4095:0] enable; 
    logic [1023:0] local_reset;
    
    // ----- Generate indices -----
    genvar i;
    
    //Every group of 4 bits corrosponds to a given pc_e index
    assign enable = branch_op_e_i[0] ? 1'b1 << {pc_e, local_src_i} : 0;
    
    generate
        for (i = 0; i < 4096; i = i + 1) begin
            
            // i/4 so have group of 4, i%4 to increment internal entry
            local_predictor u_local_predictor (
                // Clock & reset_i
                .clk_i                          (clk_i),
                .reset_i                        (local_reset[i/4]),

                // Control inputs
                .pc_src_res_e_i                 (pc_src_res_e_i),
                .enable_i                       (enable[i]),

                // Predictor output
                .pc_src_pred_o                  (lp_outputs[i/4][i % 4])
            );
        end
    endgenerate
    
    //Execute stage and reset_i logic
    always @(posedge clk_i) begin
        if (reset_i) begin
            local_reset <= {4096{1'b1}};
        end else if (~target_match_i && branch_op_e_i[0]) begin
            buffer_entry[pc_e][31:0] <= pc_target_e_i;
            local_reset <= 0; //Initizlize to 0 to ensure only current branch stays reset_i
            local_reset[pc_e] <= 1'b1;
        end else begin
            local_reset <= 0; //Ensures all local predictors are ready after a reset_i
        end
    end
    
    //Fetch stage logic
    assign pc_src_pred_f_o = lp_outputs[pc_f_i][local_src_i];
    assign pred_pc_target_f_o = buffer_entry[pc_f_i][31:0];
    
endmodule
