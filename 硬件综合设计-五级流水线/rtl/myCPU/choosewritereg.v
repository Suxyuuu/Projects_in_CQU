`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/20 23:52:40
// Design Name: 
// Module Name: choosewritereg
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


module choosewritereg(
    input [4:0] rtE,rdE,
    input regwriteE,regdstE,
    output reg [4:0] writeregE
    );
    always@(*) begin 
        if(regwriteE)
            if(regdstE)
                writeregE = rdE;
             else writeregE = rtE;
         else writeregE = 5'b00000;
    end
endmodule
