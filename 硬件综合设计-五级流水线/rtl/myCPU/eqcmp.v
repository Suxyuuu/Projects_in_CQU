`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/23 22:57:01
// Design Name: 
// Module Name: eqcmp
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

module compare(
	input wire [31:0] a,b,
	input wire [7:0] alucontrolD,
	output reg y
    );

	always@ (*) begin
		case (alucontrolD)
			`EXE_BEQ_OP: y = (a == b) ? 1:0;
			`EXE_BGTZ_OP: y = ((a[31] == 1'b0) && (a != `ZeroWord)) ? 1:0;
			`EXE_BLEZ_OP: y = ((a[31] == 1'b1) || (a == `ZeroWord)) ? 1:0;
			`EXE_BNE_OP: y = (a != b) ? 1:0; 
			`EXE_BLTZ_OP: y = (a[31] == 1'b1) ? 1:0;
			`EXE_BLTZAL_OP: y = (a[31] == 1'b1) ? 1:0;
			`EXE_BGEZ_OP: y = (a[31] == 1'b0) ? 1:0;
			`EXE_BGEZAL_OP: y = (a[31] == 1'b0) ? 1:0;
		default: y = 0;
		endcase
	end
endmodule
