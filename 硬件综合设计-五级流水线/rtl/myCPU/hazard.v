`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/01 18:31:34
// Design Name: 
// Module Name: hazard
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

module hazard(
    output wire stallF,
    output reg [31:0] newPC,
	output flushF,
    
    input wire [4:0] rsD,rtD,
    input wire branchD,jumpD,jrD,
    input wire [7:0] alucontrolD,
    output wire forwardaD,forwardbD,jrforwardaD,stallD,jrb_l_astall,jrb_l_bstall,
    output flushD,
    
    input wire [4:0] rsE,rtE,writeregE,
    input wire regwriteE,memtoregE,
    input wire hilo_signal,
    input wire [7:0] alucontrolE,
    input wire  div_ready,
    output wire [1:0]forwardaE,forwardbE,
    output wire flushE,stallE,
    
    input wire [4:0] writeregM,
    input wire regwriteM,memtoregM,
    input wire[31:0] exception_type,
    input wire overflowM,
    output wire flushM,
    input wire [31:0] epc,

    input wire [4:0] writeregW,
    input wire regwriteW,
    output wire flushW
    
    );

    wire lwstallD,branchstallD,jrstall;
    wire stall_divE;

    always@(*) begin   
        if(exception_type!=32'b0)
        begin 
            case (exception_type)
                32'h0000_0001,32'h0000_0004,32'h0000_0005,32'h0000_0008,32'h0000_0009,32'h0000_000a,32'h0000_000c:
                    newPC<=32'hbfc00380;
                32'h0000_000e:	newPC <= epc;
            endcase
        end

    end

    assign forwardaE =  (rsE && rsE==writeregM && regwriteM) ? 2'b10 :
					   	(rsE && rsE==writeregW && regwriteW) ? 2'b01 : 2'b00 ;
	assign forwardbE = 	(rtE && rtE==writeregM && regwriteM) ? 2'b10 :
					   	(rtE && rtE==writeregW && regwriteW) ? 2'b01 : 2'b00 ;

    assign stall_divE = ((alucontrolE == `EXE_DIV_OP)|(alucontrolE == `EXE_DIVU_OP)) & ~div_ready;  //div

    assign forwardaD = (rsD !=0 & rsD == writeregM & regwriteM);
    assign forwardbD = (rtD !=0 & rtD == writeregM & regwriteM); 

    //assign jrforwardaD = (rsD !=0 & rsD == writeregE & regwriteE);

    assign  lwstallD = memtoregE & (rtE == rsD | rtE == rtD) ;      //lw

    assign  branchstallD = (branchD & regwriteE & (writeregE == rsD | writeregE == rtD)) | (branchD & memtoregM &(writeregM == rsD | writeregM == rtD));       //branch

    assign jrstall = jrD && regwriteE && (writeregE==rsD);

    assign  stallD = lwstallD | branchstallD | stall_divE | jrstall | jrb_l_astall | jrb_l_bstall;
    assign  stallF = stallD;
    assign  flushE = lwstallD | branchstallD |(exception_type!=0) | jrb_l_astall | jrb_l_bstall;
    assign  stallE = stall_divE;

    assign jrb_l_astall = (jrD|branchD) && ((memtoregE && (writeregE==rsD)) || (memtoregM && (writeregM==rsD)));
	assign jrb_l_bstall = (jrD|branchD) && ((memtoregE && (writeregE==rtD)) || (memtoregM && (writeregM==rtD)));

    assign flushF=(exception_type!=0);
	assign flushD=(exception_type!=0);
	assign flushM=(exception_type!=0);
	assign flushW=(exception_type!=0);


endmodule
