`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/20 20:20:38
// Design Name: 
// Module Name: lwswexcept
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
module lwswexcept(
    input [31:0] addrs,
    input [7:0] alucontrolM,
    output reg adelM,adesM
    );
    always@(*) begin
        case (alucontrolM)
            `EXE_LH_OP: if (addrs[1:0] != 2'b00 & addrs[1:0] != 2'b10 ) begin
                adelM = 1'b1;
            end
            `EXE_LHU_OP: if ( addrs[1:0] != 2'b00 & addrs[1:0] != 2'b10 ) begin
                adelM = 1'b1;
            end
            `EXE_LW_OP: if ( addrs[1:0] != 2'b00 ) begin
                adelM = 1'b1;
            end
            `EXE_SH_OP: if (addrs[1:0] != 2'b00 & addrs[1:0] != 2'b10 ) begin
                adesM = 1'b1;
            end
            `EXE_SW_OP: if ( addrs[1:0] != 2'b00 ) begin
                adesM = 1'b1;
            end
            default: begin
                adelM = 1'b0;
                adesM = 1'b0;
            end
        endcase
    end
endmodule
