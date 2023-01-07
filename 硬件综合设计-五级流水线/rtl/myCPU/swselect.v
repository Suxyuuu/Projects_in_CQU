`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/19 16:39:24
// Design Name: 
// Module Name: swselect
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

`include "defines.vh"
module swselect(
    input wire adesE, //已经改成了M阶段
    input [31:0] addressE,
    input [7:0] alucontrolE,
    input [3:0] memwriteE,
    output reg [3:0] memwrite2E
    );
    always@ (*) begin
    if(adesE) 
         memwrite2E <= 4'b0000;
    else begin    
        case(alucontrolE)
            `EXE_SB_OP: begin
                case(addressE[1:0])
//                    2'b00: memwrite2E <= 4'b1000;
//                    2'b01: memwrite2E <= 4'b0100;
//                    2'b10: memwrite2E <= 4'b0010;
//                    2'b11: memwrite2E <= 4'b0001;
                    2'b11: memwrite2E <= 4'b1000;
                    2'b10: memwrite2E <= 4'b0100;
                    2'b01: memwrite2E <= 4'b0010;
                    2'b00: memwrite2E <= 4'b0001;
                    default: memwrite2E <= 4'b0000;
                endcase
            end    
            `EXE_SH_OP: begin
                case(addressE[1:0])
                    2'b00: memwrite2E <= 4'b0011;
                    2'b10: memwrite2E <= 4'b1100;
                    default: memwrite2E <= 4'b0000;
                endcase
            end
            `EXE_SW_OP:
                memwrite2E <= 4'b1111;
            default: memwrite2E <= 4'b0000;       
        endcase
    end
    end
endmodule
