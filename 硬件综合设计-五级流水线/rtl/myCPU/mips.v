`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
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


module mips(
	// input wire clk,resetn,
	// output wire[31:0] pcF,
	// input wire[31:0] instrF,
	// output wire [3:0] memwrite2M,
	// output wire[31:0] aluoutM,writedataM,
	// output wire memenM,
	// input wire[31:0] readdataM 
	input wire clk,resetn,
	input wire [5:0] int,

	output wire inst_sram_en,
	output wire [3:0] inst_sram_wen,
	output wire [31:0] inst_sram_addr,
	output wire [31:0] inst_sram_wdata,
	input wire [31:0] inst_sram_rdata,

	output wire data_sram_en,
	output wire [3:0] data_sram_wen,
	output wire [31:0] data_sram_addr,
	output wire [31:0] data_sram_wdata,
	input wire [31:0] data_sram_rdata,

	output wire [31:0] debug_wb_pc,
	output wire [3:0] debug_wb_rf_wen,
	output wire [4:0] debug_wb_rf_wnum,
	output wire [31:0] debug_wb_rf_wdata
    );
	
	wire [31:0] pcF,instrF;

	wire [5:0] opD,functD;
	wire [4:0] rtD;
	wire [7:0] alucontrolD;
	wire [31:0] instrD;	
	wire jumpD,jalD,jrD,balD,memenD,hiloD,equalD,stallD;
	wire branchD;
	wire breakD,syscallD,reserveD,eretD,cp0weD,cp0selD,pcsrcD;

	wire regdstE,alusrcE,memtoregE,regwriteE;
	wire jumpE,jalE,jrE,balE,memenE,hiloE,cp0selE;
	wire flushE,stallE;
	wire [3:0] memwriteE;
	wire [7:0] alucontrolE;

	wire hiloM,memtoregM,regwriteM,memenM;
	wire [3:0] memwriteM,memwrite2M;
	wire cp0selM,flushM;
	wire [31:0] aluoutM,writedataM,readdataM;
	
	wire flushW,hiloW,regwriteW,memtoregW;
	wire [31:0] pcW,result2W;
	wire [4:0] writereg2W;

	assign	inst_sram_en		= 1;
	assign	inst_sram_wen		= 4'b0; 
	assign	inst_sram_addr		= pcF;
	assign	inst_sram_wdata		= 32'b0;
	assign	instrF				= inst_sram_rdata;

	assign	data_sram_en		= memenM;
	assign	data_sram_wen		= memwrite2M;
	//assign	data_sram_addr		= aluoutM;
	assign  data_sram_addr       =(aluoutM[31:16]!=16'hbfaf)?aluoutM:{16'h1faf,aluoutM[15:0]};
	assign	data_sram_wdata		= writedataM;
	assign	readdataM			= data_sram_rdata;

	assign	debug_wb_pc			= pcW;
	assign	debug_wb_rf_wen		= {4{regwriteW}};
	assign	debug_wb_rf_wnum	= writereg2W;
	assign	debug_wb_rf_wdata	= result2W;

	controller c(
		clk,resetn,
		//decode stage
		instrD,
		opD,functD,rtD,
		pcsrcD,branchD,equalD,
		jumpD,jalD,jrD,balD,memenD,hiloD,
		breakD,syscallD,reserveD,eretD,
		cp0weD,cp0selD,
		alucontrolD,
		stallD,
		//execute stage
		flushE,
		memtoregE,alusrcE,
		regdstE,regwriteE,	
		alucontrolE,
		jumpE,jalE,jrE,balE,memenE,hiloE,cp0selE,
		memwriteE,
		//mem stage
		flushM,
		memtoregM,memwriteM,
		regwriteM,hiloM,memenM,cp0selM,
		//write back stage
		flushW,
		memtoregW,regwriteW,hiloW

		);
	datapath dp(
		clk,resetn,
		//fetch stage
		pcF,
		instrF,
		//decode stage
		pcsrcD,branchD,
		jumpD,jalD,jrD,balD,memenD,
		breakD,syscallD,reserveD,eretD,cp0weD,
		equalD,
		opD,functD,rtD,
		alucontrolD,
		instrD,
		stallD,
		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,
		alucontrolE,
		flushE,stallE,
		jumpE,jalE,jrE,balE,memenE,hiloE,
		memwriteE,
		//mem stage
		memtoregM,
		regwriteM,
		cp0selM,
		aluoutM,writedataM,
		readdataM,
		memwrite2M,
		flushM,
		//writeback stage
		memtoregW,
		regwriteW,
		flushW,
		pcW,
		writereg2W,
		result2W
	    );
	
endmodule
