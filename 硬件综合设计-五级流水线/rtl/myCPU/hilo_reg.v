`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/12 11:26:03
// Design Name: 
// Module Name: hilo_reg
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
module hilo_reg(
	input wire clk,rst,hilo_signal,
	input wire hilo_div,
	input wire [7:0] alucontrolE,
	input wire [31:0] hi_in,lo_in,
	input wire [63:0] div_result,
	output reg [31:0] hi_out,lo_out,
	output wire flushE
    );

	always @(negedge clk) begin
		if(rst) begin
			hi_out <= 0;
			lo_out <= 0;
		end 
		else if(~flushE) begin
		if(hilo_div) begin
			hi_out <=div_result[63:32];
			lo_out <=div_result[31:0];
		end
		else if(alucontrolE == `EXE_MULT_OP | alucontrolE == `EXE_MULTU_OP) begin
		    hi_out <=hi_in;
			lo_out <=lo_in;
		end
		else if(hilo_signal & alucontrolE == `EXE_MTHI_OP) begin
			hi_out <= hi_in;
		end
		else if(hilo_signal & alucontrolE == `EXE_MTLO_OP) begin
			lo_out <= lo_in;
		end
		end
		

	end
endmodule
