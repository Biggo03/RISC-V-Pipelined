`timescale 1ns / 1ps
//==============================================================//
//  Module:       csr_reg_file
//  File:         csr_reg_file.sv
//  Description:  Contains the supported CSR regists, and a decoder for accessign them
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//
`include "instr_macros.sv"
`include "csr_macros.sv"

// module csr_reg_file (
//     // -- Clk and Reset --
//     input logic         clk_i,
//     input logic         reset_i,
//
//     // -- Write Signals --
//     input logic         csr_we_i,
//     input logic [11:0]  csr_waddr_i,
//     input logic [31:0]  csr_wdata_i,
//
//     // -- Read Signals --
//     input  logic [11:0] csr_raddr_i,
//     output logic [31:0] csr_rdata_o,
//
//     // -- Other --
//     input logic         retire_w_i
// );
//
//     localparam logic [11:0] CSR_ADDRS [NUM_CSR] = {
//         `MCYCLE_ADDR,
//         `MCYCLE_ADDRH,
//         `MINSTRET_ADDR,
//         `MINSTRETH_ADDR
//     };
//
//     // ----- Counter Register Storage -----
//     logic [63:0] mcycle;
//     logic [63:0] minstret;
//
//     // Write logic (only implementing specific registers as of now)
//     always_ff @(posedge clk_i) begin
//         if (reset_i) begin
//             mcycle <= 0;
//             minstret <= 0;
//         end else begin
//             if (csr_we_i) begin
//                 case (cst_addr_i)
//                     `MCYCLEH_ADDR:      mcycle[63:32]   = csr_wdata_i;
//                     `MCYCLE_ADDR:       mcycle[31:0]    = csr_wdata_i;
//                     `MINSTRETH_ADDR:    minstret[63:32] = csr_wdata_i;
//                     `MINSTRET_ADDR:     minstret[31:0]  = csr_wdata_i;
//                 endcase
//             end else begin
//                 if (retire_w_i) minstret <= minstret + 1;
//                 mcycle <= mcycle + 1;
//             end
//         end
//     end
//
//     // Read logic
//     always_comb begin
//         if (csr_waddr_i == csr_raddr_i) begin
//             csr_rdata_o = csr_wdata_i;
//         end else begin
//             case (csr_addr_i)
//                 `MCYCLEH_ADDR:      csr_rdata_o = mcycle[63:32]
//                 `MCYCLE_ADDR:       csr_rdata_o = mcycle[31:0]
//                 `MINSTRETH_ADDR:    csr_rdata_o = minstret[63:32]
//                 `MINSTRET_ADDR:     csr_rdata_o = minstret[31:0]
//                 default:            csr_rdata_o = 0;
//             endcase
//         end
//     end
//
// endmodule
