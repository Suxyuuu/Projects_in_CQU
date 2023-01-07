`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	input wire [31:0] instrD,
	input wire[5:0] opD,functD,
	input wire [4:0] rt,               
	output wire pcsrcD,
	output wire branchD,
	input equalD,
	output jumpD,jalD,jrD,balD,memenD,hiloD,
	output breakD,syscallD,reserveD,eretD,
	output cp0weD,cp0selD,
	output wire[7:0] alucontrolD,
	input wire stallD,
	
	//execute stage
	input wire flushE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	
	output wire[7:0] alucontrolE,
	output wire jumpE,jalE,jrE,balE,memenE,hiloE,cp0selE,
	output wire [3:0] memwriteE,

	//mem stage
	input wire flushM,
	output wire memtoregM,
	output wire [3:0] memwriteM,
	output wire	regwriteM,hiloM,memenM,cp0selM,
	//write back stage
	input wire flushW,
	output wire memtoregW,regwriteW,hiloW
    );
	
	//decode stage
	//wire[1:0] aluopD;
	wire memtoregD;
	wire [3:0] memwriteD;
	wire alusrcD,regdstD,regwriteD;
	

	//execute stage
	//wire [3:0] memwriteE;

	maindec md(
		instrD,
		opD,
		functD,
		rt,
		memtoregD,memwriteD,
		branchD,alusrcD,
		regdstD,regwriteD,
		jumpD,
		jalD,jrD,balD,memenD,hiloD,
		breakD,syscallD,reserveD,eretD,
		cp0weD,cp0selD
		);
	aludec ad(opD,rt,functD,alucontrolD);   //new

	assign pcsrcD = branchD & equalD;

	//pipeline registers
	flopenrc #(22) regE(
		clk,
		rst,~stallD,flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD,jumpD,jalD,jrD,balD,memenD,cp0selD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE,jumpE,jalE,jrE,balE,memenE,cp0selE}
		);
	flopr #(1) reghiloE(clk,rst,hiloD,hiloE);
	floprc #(9) regM(
		clk,rst,flushM,
		{memtoregE,memwriteE,regwriteE,hiloE,memenE,cp0selE},
		{memtoregM,memwriteM,regwriteM,hiloM,memenM,cp0selM}
		);
	floprc #(6) regW(
		clk,rst,flushW,
		{memtoregM,regwriteM,hiloM},
		{memtoregW,regwriteW,hiloW}
		);
endmodule
