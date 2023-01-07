`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22
// Design Name: 
// Module Name: datapath
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

module datapath(
	input wire clk,rst,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire pcsrcD,branchD,
	input wire jumpD,jalD,jrD,balD,memenD,
	input wire breakD,syscallD,reserveD,eretD,cp0weD,
	output wire equalD,
	output wire[5:0] opD,functD,
	output wire[4:0] rtD,
	input wire[7:0] alucontrolD,
	output wire [31:0] instrD,
	output wire stallD,
	//execute stage
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,
	input wire[7:0] alucontrolE,
	output wire flushE,stallE,
	input wire jumpE,jalE,jrE,balE,memenE,hiloE,
	input wire [3:0] memwriteE,
	//mem stage
	input wire memtoregM,
	input wire regwriteM,
	input wire cp0selM,
	output wire[31:0] aluout2M,writedata2M,
	input wire[31:0] readdataM,
	output wire [3:0] memwrite2M,
	output wire flushM,
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,
	output wire flushW,
	output wire [31:0] pcW,
	output wire [4:0] writereg2W,
	output wire [31:0] result2W
    );
	
	wire [63:0] hilo_in,hilo_out;		//hilo register
	
	wire div_start,div_signed,div_annul;
	wire div_ready;
		

	//fetch stage
	wire stallF,flushF;
	wire branchjumpF;
	wire [31:0] newPC;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcplus8F;
	//decode stage
	wire [31:0] pcbranchD,pcD,pcplus8D,pcnextbrFD2;
	wire [31:0] pcplus4D;
	wire forwardaD,forwardbD,jrforwardaD;
	wire branchjumpD,jrb_l_astall,jrb_l_bstall;
	wire [7:0] exceptioncollectD;
	wire [4:0] rsD,rdD;
	wire [4:0] saD;
	wire flushD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D,srca2jD,srca3D,srcb3D;
	wire [15:0] offsetD;
	//execute stage
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] saE;
	wire [4:0] writeregE,writeregjalrE,writereg2E;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE,aluout2E;
	wire [31:0] pcE,pcplus4E,pcplus8E;
	wire [31:0] instrE;
	wire [15:0] offsetE;
	wire overflowE,cp0weE,branchjumpE;
	wire [63:0] div_result;
	wire [3:0] memwrite2E;
	wire [7:0] exceptioncollectE;
	//mem stage
	wire [4:0] writeregM,writereg2M,rdM;
	wire [7:0] alucontrolM;
	wire overflowM,cp0weM,branchjumpM,adelM,adesM,memwriteM;
	wire [31:0] writedataM,aluoutM,pcM,aluout1M,srcbM;
	wire [31:0] cp0out_data;
	wire [7:0] exceptioncollectM;
	wire [31:0] status_o;
	wire [31:0] cause_o;
	wire [31:0] excepttype_i;
	wire [31:0] bad_addr_i;
	wire [31:0] count_o;
	wire [31:0] compare_o;
	wire [31:0] epc_o;
	wire [31:0] config_o;
	wire [31:0] prid_o;
	wire [31:0] badvaddr;
	wire [31:0] timer_int_o;
	//writeback stage
	wire adelW;
	wire [4:0] writeregW;
	wire [31:0] aluout2W,readdataW,lwresult2W,aluoutW;
	wire [7:0] alucontrolW;
	//wire flushW;



	//hazard detection
	hazard h(
		//fetch stage
		stallF,
		newPC,
		flushF,
		//decode stage
		rsD,rtD,
		branchD,
		jumpD,jrD,
		alucontrolD,
		forwardaD,forwardbD,jrforwardaD,
		stallD,jrb_l_astall,jrb_l_bstall,
		flushD,
		//execute stage
		rsE,rtE,
		writeregE,
		regwriteE,
		memtoregE,
		hiloE,
		alucontrolE,div_ready,
		forwardaE,forwardbE,
		flushE,stallE,
		//mem stage
		writereg2M,
		regwriteM,
		memtoregM,
		excepttype_i,
		overflowM, 
		flushM,
		epc_o,
		//write back stage
		writereg2W,
		regwriteW,
		flushW
		);

	//next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
	mux2 #(32) pcjrmux(pcnextbrFD,srca2D,jrD,pcnextbrFD2);//xiuga
	mux2 #(32) pcmux(pcnextbrFD2,{pcplus4D[31:28],instrD[25:0],2'b00},jumpD | jalD,pcnextFD);

	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writereg2W,result2W,srcaD,srcbD);

	//fetch stage logic
	pcflopenrc #(32) pcflopF(clk,rst,~stallF,flushF,pcnextFD,newPC,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	adder pcadd3(pcplus4F,32'b100,pcplus8F);
	assign branchjumpF =branchD | jumpD | jalD | jrD;
	

	//decode stage
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,~stallD,flushD,pcF,pcD);
	flopenrc #(32) r4D(clk,rst,~stallD,flushD,pcplus8F,pcplus8D);
	flopenrc #(1) r5D(clk,rst,~stallD,flushD,branchjumpF,branchjumpD);

	signext se(instrD[15:0],instrD[29:28],signimmD);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	// mux2 #(32) forwardamux(srcaD,aluout2M,forwardaD,srca2jD);
	// mux2 #(32) jrforwardmux(srca2jD,aluout2E,jrforwardaD,srca2D);
	// mux2 #(32) forwardbmux(srcbD,aluout2M,forwardbD,srcb2D);
	mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	mux2 #(32) forwardbjrb_lamux(srca2D,readdataM,jrb_l_astall,srca3D);
	mux2 #(32) forwardbjrb_lbmux(srcb2D,readdataM,jrb_l_bstall,srcb3D);
	compare comp(srca3D,srcb3D,alucontrolD,equalD);

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign saD = instrD[10:6];
	assign offsetD = instrD[15:0];

	assign exceptioncollectD[0]=eretD;
	assign exceptioncollectD[1]=syscallD;
	assign exceptioncollectD[2]=breakD;
	assign exceptioncollectD[3]=reserveD;

	//execute stage
	flopenrc #(32) 	pcflopE(clk,rst,~stallE,flushE,pcD,pcE);
	flopenrc #(32) 	instrflopE(clk,rst,~stallE,flushE,instrD,instrE);
	flopenrc #(32) 	pcplusflopE(clk,rst,~stallE,flushE,pcplus4D,pcplus4E);
	flopenrc #(32) 	pcplusflopE2(clk,rst,~stallE,flushE,pcplus8D,pcplus8E);
	flopenrc #(1) 	cp0weflopE(clk,rst,~stallE,flushE,cp0weD,cp0weE);
	flopenrc #(1) 	delayslotflopE(clk,rst,~stallE,flushE,branchjumpD,branchjumpE);
	flopenrc #(4) 	exceptionflopE(clk,rst,~stallE,flushE,exceptioncollectD[3:0],exceptioncollectE[3:0]);
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(5) r7E(clk,rst,~stallE,flushE,saD,saE);
	
	flopenr #(16) r8E(clk,rst,~stallE,offsetD,offsetE);

	mux3 #(32) forwardaemux(srcaE,result2W,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,result2W,aluoutM,forwardbE,srcb2E);
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);

	divdec divdec(alucontrolE,div_ready,flushM,div_start, div_signed, div_annul);
	div div(clk,rst,div_signed,srca2E,srcb3E,div_start,1'b0,div_result,div_ready);

	alu alu(srca2E,srcb3E,alucontrolE,saE,offsetE,aluoutE,hilo_in,hilo_out,overflowE);	

	assign exceptioncollectE[4]=overflowE;		
	
	hilo_reg hilo(clk,rst,hiloE,div_ready,alucontrolE,hilo_out[63:32],hilo_out[31:0],div_result,hilo_in[63:32],hilo_in[31:0],flushE);
	choosewritereg wrchoose(rtE,rdE,regwriteE,regdstE,writeregE);
	jalrselect jalrsel(writeregE,alucontrolE,writeregjalrE);
	mux2 #(5) wrmux2(writeregjalrE,5'b11111,jalE | balE,writereg2E);
	mux2 #(32) wrmux23(aluoutE,pcplus8E,jalE|jrE|balE,aluout2E);
	
	//swselect swsel(adesM,aluout2E,alucontrolE,memwriteE,memwrite2E);

	//mem stage
	floprc #(32) r1M(clk,rst,flushM,srcb2E,writedataM);
	floprc #(32) r2M(clk,rst,flushM,aluout2E,aluout2M);
	floprc #(5) r3M(clk,rst,flushM,writereg2E,writereg2M);
	floprc #(1) r4M(clk,rst,flushM,overflowE,overflowM);
	floprc #(8) r5M(clk,rst,flushM,alucontrolE,alucontrolM);
	floprc #(4) r6M(clk,rst,flushM,memwriteE,memwriteM);
	//floprc #(32) r7M(clk,rst,flushM,aluoutE,aluout1M);
	floprc #(5) r8M(clk,rst,flushM,rdE,rdM);
	floprc #(32) r9M(clk,rst,flushM,srcb3E,srcbM);
	floprc #(32) pcflopM(clk,rst,flushM,pcE,pcM);
	floprc #(1) cp0weflopM(clk,rst,flushM,cp0weE,cp0weM);
	floprc #(1) delayslotflopM(clk,rst,flushM,branchjumpE,branchjumpM);
	floprc #(5) exceptionflopM(clk,rst,flushM,exceptioncollectE[4:0],exceptioncollectM[4:0]);

	mux2 #(32) cp0selmux(aluout2M,cp0out_data,cp0selM,aluoutM);
	
	swselect swsel(adesM,aluout2M,alucontrolM,memwriteM,memwrite2M);

	lwswexcept lsexcept(aluoutM,alucontrolM,adelM,adesM);

	assign exceptioncollectM[5]=adelM;
	assign exceptioncollectM[6]=adesM;

	writedatacorrect wdct(writedataM,alucontrolM,writedata2M);

	exception_type exception_type(rst,pcM,exceptioncollectM,status_o,cause_o,aluoutM,excepttype_i,bad_addr_i);

	cp0_reg cp0reg(
			.clk(clk),  
			.rst(rst),
			.we_i(cp0weM),
			.waddr_i(rdM),
			.raddr_i(rdM),
			.data_i(srcbM),

			.int_i(0),
			.excepttype_i(excepttype_i),
			.current_inst_addr_i(pcM),
			.is_in_delayslot_i(branchjumpM),
			.bad_addr_i(bad_addr_i),

			.data_o(cp0out_data),
			.count_o(count_o),
			.compare_o(compare_o),
			.status_o(status_o),
			.cause_o(cause_o),
			.epc_o(epc_o),
			.config_o(config_o),
			.prid_o(prid_o),
			.badvaddr(badvaddr),
			.timer_int_o(timer_int_o)
			);

	//writeback stage
	//floprc #(32) r1W(clk,rst,flushW,aluout2M,aluout2W);
	floprc #(32) r2W(clk,rst,flushW,readdataM,readdataW);
	floprc #(5) r3W(clk,rst,flushW,writereg2M,writereg2W);
	floprc #(8) r4W(clk,rst,flushW,alucontrolM,alucontrolW);
	floprc #(32) r5W(clk,rst,flushW,aluoutM,aluoutW);
	floprc #(32) r6W(clk,rst,flushW,pcM,pcW);
	floprc #(1) r7W(clk,rst,flushW,adelM,adelW);

	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,lwresult2W);	

	lwselect lwsel(adelW,aluoutW,alucontrolW,lwresult2W,result2W);
endmodule
