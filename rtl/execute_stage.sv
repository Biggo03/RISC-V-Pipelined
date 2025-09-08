`timescale 1ns / 1ps
//==============================================================//
//  Module:       execute_stage
//  File:         execute_stage.sv
//  Description:  All logic contained within the Execute pipeline stage, along with its pipeline register.
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module execute_stage (
    // Clock & reset_i
    input  logic        clk_i,
    input  logic        reset_i,

    // Data inputs
    input  logic [31:0] rd1_d_i,
    input  logic [31:0] rd2_d_i,
    input  logic [31:0] result_w_i,
    input  logic [31:0] forward_data_m_i,
    input  logic [31:0] pc_d_i,
    input  logic [31:0] pc_plus4_d_i,
    input  logic [31:0] imm_ext_d_i,
    input  logic [31:0] pred_pc_target_d_i,
    input  logic [2:0]  funct3_d_i,
    input  logic [4:0]  rd_d_i,
    input  logic [4:0]  rs1_d_i,
    input  logic [4:0]  rs2_d_i,

    // Control inputs
    input  logic [3:0]  alu_control_d_i,
    input  logic [2:0]  width_src_d_i,
    input  logic [2:0]  result_src_d_i,
    input  logic [1:0]  branch_op_d_i,
    input  logic        reg_write_d_i,
    input  logic        mem_write_d_i,
    input  logic        pc_base_src_d_i,
    input  logic        alu_src_d_i,
    input  logic [1:0]  forward_a_e_i,
    input  logic [1:0]  forward_b_e_i,
    input  logic        flush_e_i,
    input  logic        stall_e_i,
    input  logic        pc_src_pred_d_i,

    // Data outputs
    output logic [31:0] alu_result_e_o,
    output logic [31:0] write_data_e_o,
    output logic [31:0] pc_target_e_o,
    output logic [31:0] pc_plus4_e_o,
    output logic [31:0] imm_ext_e_o,
    output logic [31:0] pc_e_o,
    output logic [4:0]  rs1_e_o,
    output logic [4:0]  rs2_e_o,
    output logic [4:0]  rd_e_o,
    output logic [2:0]  funct3_e_o,
    output logic        N,
    output logic        Z,
    output logic        C,
    output logic        V,

    // Control outputs
    output logic [2:0]  width_src_e_o,
    output logic [2:0]  result_src_e_o,
    output logic [1:0]  branch_op_e_o,
    output logic        mem_write_e_o,
    output logic        reg_write_e_o,
    output logic        pc_src_pred_e_o,
    output logic        target_match_e_o
);
     
    localparam REG_WIDTH = 227;
                    
    // ----- Execute pipeline register -----
    logic [REG_WIDTH-1:0] inputs_e;
    logic [REG_WIDTH-1:0] outputs_e;
    logic                 reset_e;

    // ----- Execute stage outputs -----
    logic [31:0] rd1_e;
    logic [31:0] rd2_e;
    logic [31:0] pred_pc_target_e;
    logic [3:0]  alu_control_e;
    logic        pc_base_src_e;
    logic        alu_src_e;

    // ----- Execute stage intermediates -----
    logic [31:0] src_a_e;
    logic [31:0] src_b_e;
    logic [31:0] pc_base_e;

    assign inputs_e = {branch_op_d_i, width_src_d_i, result_src_d_i, mem_write_d_i, alu_control_d_i, pc_base_src_d_i, alu_src_d_i, reg_write_d_i,
                      funct3_d_i, rd1_d_i, rd2_d_i, pc_d_i, rd_d_i, imm_ext_d_i, rs1_d_i, rs2_d_i, pc_plus4_d_i, pred_pc_target_d_i, pc_src_pred_d_i};
                      
    assign reset_e = (reset_i | flush_e_i);
    
    flop #(
        .WIDTH                          (REG_WIDTH)
    ) u_execute_reg (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .en                             (~stall_e_i),
        .reset                          (reset_e),

        // Data input
        .D                              (inputs_e),

        // Data output
        .Q                              (outputs_e)
    );
    
    assign {branch_op_e_o, width_src_e_o, result_src_e_o, mem_write_e_o, alu_control_e, pc_base_src_e, alu_src_e, reg_write_e_o, 
            funct3_e_o, rd1_e, rd2_e, pc_e_o, rd_e_o, imm_ext_e_o, rs1_e_o, rs2_e_o, pc_plus4_e_o, pred_pc_target_e, pc_src_pred_e_o} = outputs_e;
   
   //Test Branch Prediction
    always @(*) begin
        if (pc_target_e_o == pred_pc_target_e) target_match_e_o = 1;
        else target_match_e_o = 0;
    end
   
    //Stage multiplexers:
    mux3 u_forward_mux_a (
        // Data inputs
        .d0                             (rd1_e),
        .d1                             (result_w_i),
        .d2                             (forward_data_m_i),

        // Select input
        .s                              (forward_a_e_i),

        // Data output
        .y                              (src_a_e)
    );
        
    mux3 u_forward_mux_b (
        // Data inputs
        .d0                             (rd2_e),
        .d1                             (result_w_i),
        .d2                             (forward_data_m_i),

        // Select input
        .s                              (forward_b_e_i),

        // Data output
        .y                              (write_data_e_o)
    );
        
    mux2 u_src_b_mux (
        // Data inputs
        .d0                             (write_data_e_o),
        .d1                             (imm_ext_e_o),

        // Select input
        .s                              (alu_src_e),

        // Data output
        .y                              (src_b_e)
    );
        
    mux2 u_pc_target_mux (
        // Data inputs
        .d0                             (pc_e_o),
        .d1                             (src_a_e),

        // Select input
        .s                              (pc_base_src_e),

        // Data output
        .y                              (pc_base_e)
    );
        
    //Arithmetic units:
    alu u_alu (
        // Control inputs
        .alu_control_i                  (alu_control_e),

        // Data inputs
        .A                              (src_a_e),
        .B                              (src_b_e),

        // Data outputs
        .alu_result_o                   (alu_result_e_o),

        // Status flag outputs
        .N                              (N),
        .Z                              (Z),
        .C                              (C),
        .V                              (V)
    );
                
    adder u_pc_target_adder (
        // Data inputs
        .a                              (pc_base_e),
        .b                              (imm_ext_e_o),

        // Data output
        .y                              (pc_target_e_o)
    );

endmodule
