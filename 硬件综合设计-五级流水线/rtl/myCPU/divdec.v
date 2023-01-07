`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/16 15:27:39
// Design Name: 
// Module Name: divdec
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
module divdec(
    input [7:0] alucontrol,
	input wire div_ready,flushM,
	output reg div_start, div_signed, div_annul
    );

	always @(*) begin
		case (alucontrol)
			`EXE_DIV_OP: 
			begin
				if (div_ready)
					{div_start,div_signed,div_annul} = 3'b010;
				else
					{div_start,div_signed,div_annul} = 3'b110;
			end
			`EXE_DIVU_OP: 
			begin
				if (div_ready)
					{div_start,div_signed,div_annul} = 3'b000;
				else
					{div_start,div_signed,div_annul} = 3'b100;
			end
			default: {div_start,div_signed,div_annul} = 3'b000;
		endcase
		if(flushM)		div_annul <= 1;
	end
endmodule
