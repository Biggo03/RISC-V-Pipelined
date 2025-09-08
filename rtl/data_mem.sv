`timescale 1ns / 1ps
//==============================================================//
//  Module:       data_mem
//  File:         data_mem.sv
//  Description:  Stores the data of the system
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   WIDTH - Data width
//
//  Notes:        Can have variable width stores through control signal width_src
//==============================================================//

module data_mem #(
    parameter int WIDTH = 32
) (
    // Clock & control inputs
    input  logic             clk_i,
    input  logic             WE,
    input  logic [1:0]       width_src,

    // Address & write data inputs
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] WD,

    // Read data output
    output logic [WIDTH-1:0] RD
);
               
    (* ram_style = "block" *) logic [31:0] RAM[255:0];

    always @(posedge clk_i) begin
        
        //Write logic
        if (WE) begin
        //Change last bit of A index to maintain word, and half-word alignment
            case(width_src)
                2'b00: RAM[A[31:2]] = WD; //Word
                
                //Half-word
                2'b10: begin
                    if (A[1]) RAM[A[31:2]][31:16] = WD[15:0]; //Upper HW
                    else RAM[A[31:2]][15:0] = WD[15:0];       //Lower HW
                end
                
                //Byte
                2'b01: begin
                    case(A[1:0])
                        2'b00: RAM[A[31:2]][7:0] = WD[7:0];
                        2'b01: RAM[A[31:2]][15:8] = WD[7:0];  
                        2'b10: RAM[A[31:2]][23:16] = WD[7:0];
                        2'b11: RAM[A[31:2]][31:24] = WD[7:0];
                    endcase
                
                end
                
            endcase
        
        end
        
    end
    
    //Read logic
    always @(*) begin
    
        case(width_src)
            2'b00: RD = RAM[A[31:2]]; //Word
            
            //Half-word
            2'b10: begin
                if (A[1]) RD = RAM[A[31:2]][31:16]; //Upper HW
                else RD = RAM[A[31:2]][15:0];       //Lower HW
            end
            
            //Byte
            2'b01: begin
                case(A[1:0])
                    2'b00: RD = RAM[A[31:2]][7:0];    //Byte 0
                    2'b01: RD = RAM[A[31:2]][15:8];   //Byte 1
                    2'b10: RD = RAM[A[31:2]][23:16];  //Byte 2
                    2'b11: RD = RAM[A[31:2]][31:24];  //Byte 3
                endcase

            end
            
            default: RD = 32'bx;
        
        endcase
        
    end
    

endmodule
