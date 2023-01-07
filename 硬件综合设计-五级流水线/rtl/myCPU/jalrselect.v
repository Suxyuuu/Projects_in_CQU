`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/17 16:30:27
// Design Name: 
// Module Name: jalrselect
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
module jalrselect(
    input wire [4:0] writeregE,
    input [7:0] alucontrolE,
    output reg [4:0] writeregjalrE
    );
    always @(*) begin
		if(alucontrolE == `EXE_JALR_OP & writeregE == 0) 
                writeregjalrE <= 5'b11111;
        else 
            writeregjalrE <= writeregE;
	end
endmodule
