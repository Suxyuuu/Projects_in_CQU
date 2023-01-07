`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/20 19:15:06
// Design Name: 
// Module Name: pcflopenrc
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


module pcflopenrc # (parameter WIDTH = 8)(
	input clk, reset, enable,clear,
	input [WIDTH-1:0] d,
	input [WIDTH-1:0] newPC,
	output reg [WIDTH-1:0] q
	);
	always @(posedge clk, posedge reset)
		if(reset)			q <= 32'hbfc00000;
		else if(clear) 		q <= newPC;
		else if(enable) 	q <= d;
endmodule
