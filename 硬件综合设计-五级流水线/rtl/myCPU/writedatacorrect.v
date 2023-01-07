`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/19 23:15:22
// Design Name: 
// Module Name: writedatacorrect
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
module writedatacorrect(
    input [31:0] writedataM,
    input [7:0] alucontrolM,
    output reg [31:0] writedata2M
    );
    always@ (*) begin
        case (alucontrolM)
            `EXE_SB_OP: writedata2M <= {{writedataM[7:0]},{writedataM[7:0]},{writedataM[7:0]},{writedataM[7:0]}};
            `EXE_SH_OP: writedata2M <= {{writedataM[15:0]},{writedataM[15:0]}};
            default: writedata2M <= writedataM;
        endcase
    end
endmodule
