`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/29 22:05:41
// Design Name: 
// Module Name: maindec
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
module maindec(
    input wire [31:0] instrD,
    input wire [5:0] op,
    input wire [5:0] funct,
    input wire [4:0] rt,
    output memtoreg, 
    output [3:0] memwrite,
    output branch, alusrc,
    output regdst, regwrite,
    output jump,jal,jr,bal,memen,hilo,
    output  break,syscall,reserve,eret,
    output  cp0we,cp0selD
    );
    reg [20:0] controls;
    assign {regwrite, regdst, alusrc,branch,memwrite[3:0],memtoreg,jump,jal,jr,bal,memen,hilo,break,syscall,reserve,eret,cp0we,cp0selD}=controls;
    always @ (*) begin
        case(op)
            //I-type instr in logic instr
            `EXE_ANDI: controls <= 21'b101000000000000000000; //andi
            `EXE_XORI: controls <= 21'b101000000000000000000; //xori
            `EXE_LUI: controls <= 21'b101000000000000000000; //lui
            `EXE_ORI: controls <= 21'b101000000000000000000; //ori
            
            //Arithmatic_Instr
            `EXE_ADDI: controls <= 21'b101000000000000000000; //ADDI
            `EXE_ADDIU: controls <= 21'b101000000000000000000; //ADDIU
            `EXE_SLTI: controls <= 21'b101000000000000000000; //SLTI
            `EXE_SLTIU: controls <= 21'b101000000000000000000; //SLTIU

            //j,jal
            `EXE_J: controls <= 21'b000000000100000000000; //j
            `EXE_JAL: controls <= 21'b100000000010000000000; //jal

            //b-type
            `EXE_BEQ: controls <= 21'b000100000000000000000; //beq
            `EXE_BGTZ: controls <= 21'b000100000000000000000; //bgtz
            `EXE_BLEZ: controls <= 21'b000100000000000000000; //blez
            `EXE_BNE: controls <= 21'b000100000000000000000; //bne
            `EXE_REGIMM_INST:case(rt) 
                    `EXE_BLTZ: controls <= 21'b000100000000000000000; //bltz
                    `EXE_BLTZAL: controls <= 21'b100100000000100000000; //bltzal
                    `EXE_BGEZ: controls <= 21'b000100000000000000000; //bgez
                    `EXE_BGEZAL: controls <= 21'b100100000000100000000; //bgezal
                     default: controls <= 21'b0;
                endcase
            
            //memory instr
            `EXE_LB: controls <= 21'b1010_0000_1000010000000; //lb
            `EXE_LBU: controls <= 21'b1010_0000_1000010000000; //lbu
            `EXE_LH: controls <= 21'b1010_0000_1000010000000; //lh
            `EXE_LHU: controls <= 21'b1010_0000_1000010000000; //lhu
            `EXE_LW: controls <= 21'b1010_0000_1000010000000; //lw
            `EXE_SB: controls <= 21'b0010_0001_0000010000000; //sb
            `EXE_SH: controls <= 21'b0010_0011_0000010000000; //sh
            `EXE_SW: controls <= 21'b0010_1111_0000010000000; //sw

            //test relu
            `EXE_RELU: controls <= 21'b1100_0000_0000_0000_0000_0;

            //op为000000
            `EXE_NOP:case(funct)
                //move instr
                `EXE_MTHI: controls <= 21'b000000000000001000000;    //mthi
                `EXE_MTLO: controls <= 21'b000000000000001000000;    //mtlo
                `EXE_MFHI: controls <= 21'b110000000000001000000;    //mfhi
                `EXE_MFLO: controls <= 21'b110000000000001000000;    //mflo

                //mult instr
                `EXE_MULT: controls <= 21'b000000000000001000000;    //mult
                `EXE_MULTU: controls <= 21'b000000000000001000000;   //multu
                //div instr
                `EXE_DIV: controls <= 21'b000000000000001000000;     //div
                `EXE_DIV: controls <= 21'b000000000000001000000;     //divu
                //jr,jalr
                `EXE_JR: controls <= 21'b000000000001000000000;      //jr
                `EXE_JALR: controls <= 21'b110000000001000000000;    //jalr
                //break,syscall
                `EXE_BREAK: controls <= 21'b000000000000000100000;  //break
                `EXE_SYSCALL: controls <= 21'b000000000000000010000;    //syscall
                
                default: controls <= 21'b110000000000000000000;       //r-type
            endcase

            //op为010000,mtco,mfco
            6'b010000: begin
                if (instrD == `EXE_ERET)
                    controls <= 21'b000000000000000000100;      //eret
                else if (instrD[25:21]==5'b00100 && instrD[10:3]==0)
                    controls <= 21'b000000000000000000010;      //mtc0
                else if (instrD[25:21]==5'b00000 && instrD[10:3]==0)
                    controls <= 21'b100000000000000000001;      //mfc0
                else
                    controls <= 21'b000000000000000001000;      //未识别保存指令
            end

        default: controls <= 21'b000000000000000001000;     //未识别保存指令
  
        endcase
    end
endmodule

