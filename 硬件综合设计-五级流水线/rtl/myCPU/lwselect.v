`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/19 15:45:04
// Design Name: 
// Module Name: lwselect
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
module lwselect(
    input wire adelM,
    input wire [31:0] aluoutW,
    input [7:0] alucontrolW,
    input [31:0] lwresultW,
    output reg [31:0] result2W
    //output reg adel
    );

    always@ (*) begin
    if(~adelM) begin
        case(alucontrolW)
            `EXE_LB_OP: case(aluoutW[1:0])
                2'b00: result2W = {{24{lwresultW[7]}},lwresultW[7:0]};
                2'b01: result2W = {{24{lwresultW[15]}},lwresultW[15:8]};
                2'b10: result2W = {{24{lwresultW[23]}},lwresultW[23:16]};
                2'b11: result2W = {{24{lwresultW[31]}},lwresultW[31:24]};
                default: result2W = lwresultW;
            endcase
            `EXE_LBU_OP: case(aluoutW[1:0])
                2'b00: result2W = {{24{1'b0}},lwresultW[7:0]};
                2'b01: result2W = {{24{1'b0}},lwresultW[15:8]};
                2'b10: result2W = {{24{1'b0}},lwresultW[23:16]};
                2'b11: result2W = {{24{1'b0}},lwresultW[31:24]};
                default: result2W = lwresultW;
            endcase
            `EXE_LH_OP: case(aluoutW[1:0])
                2'b00: result2W = {{16{lwresultW[15]}},lwresultW[15:0]};
                2'b10: result2W = {{16{lwresultW[31]}},lwresultW[31:16]};
                default: result2W = lwresultW;  //adel = 1;
            endcase
            `EXE_LHU_OP:case(aluoutW[1:0])
                2'b00: result2W = {{16{1'b0}},lwresultW[15:0]};
                2'b10: result2W = {{16{1'b0}},lwresultW[31:16]};
                default: result2W = lwresultW;  //adel = 1;   
            endcase
            // `EXE_LW_OP: if(aluoutW[1:0] == 2'b00) 
            //                 result2W = lwresultW;
            //             else adel = 1;
        default: result2W = lwresultW;
        endcase
    end
    end
endmodule
