`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2024 12:17:34 PM
// Design Name: 
// Module Name: instrmem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Stores instructions describing a program
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instr_mem (
    // Address & data inputs
    input  logic [31:0] addr,

    // data outputs
    output logic [31:0] rd_o,

    // Status outputs
    output logic        instr_miss_f_o,
    output logic        instr_cache_rep_en_o
);
    
    //Initialize a RAM array (32-bit words, store 64 words)
    (* ram_style = "block" *) logic [31:0] RAM [127:0];
    
    //Initialize instruction memory with given file
    initial begin
       $readmemh(`TEST_FILE, RAM);
    end
    
    //[31:2] as to maintain word alignment
    assign rd_o = RAM[addr[31:2]];

    assign instr_miss_f_o = 1'b0;
    assign instr_cache_rep_en_o = 1'b1;

endmodule
