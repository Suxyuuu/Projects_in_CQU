`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/30 23:23:34
// Design Name: 
// Module Name: flopenr
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


module flopenr #(parameter WIDTH = 8)(
    input wire clk,rst,enable,
    input wire[WIDTH-1:0] d,
    output reg[WIDTH-1:0] q
    );
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            q<=0;
            end
        else if (enable) begin
            q<=d;
            end
     end
endmodule
