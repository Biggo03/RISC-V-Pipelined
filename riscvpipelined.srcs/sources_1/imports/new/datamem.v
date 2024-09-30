`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2024 12:25:17 PM
// Design Name: 
// Module Name: datamem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Stores the data of the system. Can have variable width stores through control signal WidthSrc
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module datamem #(parameter WIDTH = 32)
            (input clk, WE,
             input [1:0] WidthSrc,
             input [WIDTH-1:0] A, WD,
             output [WIDTH-1:0] RD);
               
    (* keep = "true" *) reg [31:0] RAM[255:0];
    reg [31:0] TempRD;

    always @(posedge clk) begin
        
        //Write logic
        if (WE) begin
        //Change last bit of A index to maintain word, and half-word alignment
            case(WidthSrc)
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
    
        case(WidthSrc)
            2'b00: TempRD = RAM[A[31:2]]; //Word
            
            //Half-word
            2'b10: begin
                if (A[1]) TempRD = RAM[A[31:2]][31:16]; //Upper HW
                else TempRD = RAM[A[31:2]][15:0];       //Lower HW
            end
            
            //Byte
            2'b01: begin
                case(A[1:0])
                    2'b00: TempRD = RAM[A[31:2]][7:0];    //Byte 0
                    2'b01: TempRD = RAM[A[31:2]][15:8];   //Byte 1
                    2'b10: TempRD = RAM[A[31:2]][23:16];  //Byte 2
                    2'b11: TempRD = RAM[A[31:2]][31:24];  //Byte 3
                endcase

            end
            
            default: TempRD = 32'bx;
        
        endcase
        
    end
    
    assign RD = TempRD;
    

endmodule
