`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/30 23:25:42
// Design Name: 
// Module Name: flopenrc
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


module flopenrc #(parameter WIDTH = 8)(
    input wire clk,rst,enable,clear,
    input wire[WIDTH-1:0] d,
    output reg[WIDTH-1:0] q
    );
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            q<=#1 0;
            end
        else if (clear) begin
            q<=#1 0;
            end
        else if (enable) begin
            q<=#1 d;
            end
     end
endmodule
