`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/29 22:04:23
// Design Name: 
// Module Name: mux2
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


module mux2
    #(parameter WIDTH=8)
    (
input [WIDTH-1:0] num1,
input [WIDTH-1:0] num2,
input sw,
output [WIDTH-1:0] result
);
assign result = sw ? num2 : num1;
endmodule

