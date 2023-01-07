`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/20 20:34:06
// Design Name: 
// Module Name: exception_type
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


module exception_type(
	input rst,
	input [31:0] pcM,
	input [7:0] exceptioncollectM,
	input wire[31:0] cp0_status,cp0_cause,aluoutM,
	output reg [31:0] excepttype_i,bad_addr
    );
	//0:eret,1:syscall,2:break,3:reserve,4:orveflow,5:adelM,6:adesM
	always @(*) 
	begin
		if(rst) excepttype_i <= 32'h0000_0000;
		else 
		begin
			if(((cp0_cause[15:8] & cp0_status[15:8]) != 8'h00) &&
				 	(cp0_status[1] == 1'b0) && (cp0_status[0] == 1'b1))
				excepttype_i <= 32'h00000001;
			else if(pcM[1:0]!=2'b00)	
				begin 
					excepttype_i <= 32'h0000_0004;
					bad_addr <= pcM;
				 end 
			else if(exceptioncollectM[5])
			begin
				excepttype_i <= 32'h0000_0004;
				bad_addr <= aluoutM;
			end
			else if(exceptioncollectM[1])	excepttype_i <= 32'h0000_0008;
			else if(exceptioncollectM[2])	excepttype_i <= 32'h0000_0009;
			else if(exceptioncollectM[0])	excepttype_i <= 32'h0000_000e;
			else if(exceptioncollectM[3])	excepttype_i <= 32'h0000_000a;
			else if(exceptioncollectM[4])	excepttype_i <= 32'h0000_000c;
			else if(exceptioncollectM[6])	
			begin 
				excepttype_i <= 32'h0000_0005;
				bad_addr<=aluoutM;
			end
			else	excepttype_i <= 32'h0000_0000;
		end
	end
endmodule
