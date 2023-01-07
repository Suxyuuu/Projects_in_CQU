`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/29 22:08:36
// Design Name: 
// Module Name: alu
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
module alu(
    input wire [31:0] num1,
    input wire [31:0] num2,
    input wire [7:0] alucontrolE,
    input wire [4:0] sa,
    input wire [15:0] offsetE,
    output reg [31:0] result,
    input [63:0] hilo_in,
    output reg [63:0] hilo_out,
    output reg overflow
    //output reg [63:0] mult_result
    );

    wire div_ready,start_div,signed_div,stall_div;


    always @(*) begin
        //overflow <= 0;
        case(alucontrolE)

            //relu
            `EXE_RELU_OP: begin 
                if(num1[31]==0) begin
                    result <= num1;overflow <= 0;
                end
                else if(num1[31]==1)begin
                    result <= 32'b0;overflow <= 0;
                end
                    
            end
            //logic instr
            `EXE_AND_OP: begin result <= num1 & num2;   overflow <= 0; end  //and
            `EXE_OR_OP: begin result <= num1 | num2;      overflow <= 0; end //or
            `EXE_XOR_OP: begin result <= num1 ^ num2;     overflow <= 0; end //xor
            `EXE_NOR_OP: begin result <= ~(num1 | num2);      overflow <= 0; end //nor
            `EXE_ANDI_OP: begin result <= num1 & num2;        overflow <= 0; end //andi
            `EXE_XORI_OP:begin  result <= num1 ^ num2;        overflow <= 0; end //xori
            `EXE_LUI_OP: begin result <={ num2[15:0],16'b0 };     overflow <= 0; end //lui
            `EXE_ORI_OP: begin result <= num1 | num2;         overflow <= 0; end //ori

            //shift instr
            `EXE_SLL_OP: begin result <= num2 << sa;     overflow <= 0; end  //sll
            `EXE_SRL_OP: begin result <= num2 >> sa;      overflow <= 0; end //srl
            `EXE_SRA_OP: begin result <= ({32{num2[31]}} << (6'd32 -{1'b0,sa})) | num2 >> sa;      overflow <= 0; end  //sra
            `EXE_SLLV_OP: begin result <= num2 << num1[4:0];      overflow <= 0; end //sllv
            `EXE_SRLV_OP:begin  result <= num2 >> num1[4:0];      overflow <= 0; end //srlv
            `EXE_SRAV_OP: begin result <= ({32{num2[31]}} << (6'd32 -{1'b0,num1[4:0]})) | num2 >> num1[4:0];       overflow <= 0; end //srav

            //move instr
            `EXE_MTHI_OP: begin hilo_out <= {num1,hilo_in[31:0]};       overflow <= 0; end //mthi
            `EXE_MTLO_OP: begin hilo_out <= {hilo_in[31:0],num1};      overflow <= 0; end //mtlo
            `EXE_MFHI_OP: begin result <= hilo_in[63:32];             overflow <= 0; end //mfhi
            `EXE_MFLO_OP: begin result <= hilo_in[31:0];              overflow <= 0; end //mflo

            //ath instr
            `EXE_ADD_OP: begin result = num1 + num2; overflow = (~result[31] & num1[31] & num2[31]) | (result[31] & ~num1[31] & ~num2[31]); end //add
            `EXE_ADDU_OP: result = num1 + num2;  //addu
            `EXE_SUB_OP: begin result = num1 - num2; overflow = (~result[31] & num1[31] & ~num2[31]) | (result[31] & ~num1[31] & num2[31]); end //sub
            `EXE_SUBU_OP:  result = num1 - num2;  //subu
            `EXE_SLT_OP: begin result <= ($signed(num1) < $signed(num2))?1:0; overflow <= 0; end //slt
            `EXE_SLTU_OP: begin result <= num1<num2; overflow <= 0; end //stlu
            `EXE_MULT_OP: begin hilo_out <= $signed(num1)*$signed(num2); overflow <= 0; end //mult
            `EXE_MULTU_OP: begin hilo_out <= $unsigned(num1)*$unsigned(num2); overflow <= 0; end //multu
//            `EXE_MULT_OP: begin mult_result <= $signed(num1)*$signed(num2); overflow <= 0; end //mult
//            `EXE_MULTU_OP: begin mult_result <= $unsigned(num1)*$unsigned(num2); overflow <= 0; end //multu
            
            `EXE_ADDI_OP:begin result <= num1 + num2; overflow = (~result[31] & num1[31] & num2[31]) | (result[31] & ~num1[31] & ~num2[31]); end //addi
            `EXE_ADDIU_OP: begin result <= num1 + num2; overflow <= 0; end //addiu
            `EXE_SLTI_OP: begin result <= ($signed(num1) < $signed(num2))?1:0; overflow <= 0; end //slti
            `EXE_SLTIU_OP: begin result <= num1 < num2; overflow <= 0; end //sltiu

            //memory instr
            `EXE_LB_OP: begin result = num1 + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //lb
            `EXE_LBU_OP: begin result = num1 + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //lbu
            `EXE_LH_OP: begin result = num1 + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //lh
            `EXE_LHU_OP: begin result = num1 + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //lhu
            `EXE_LW_OP: begin result = num1 + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //lw
            `EXE_SB_OP: begin result = num1 + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //sb
            `EXE_SH_OP: begin result = num1 + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //sh
            `EXE_SW_OP: begin result = num1 + {{16{offsetE[15]}}, offsetE };  overflow <= 0; end //sw
            

        default: begin result <= 32'h00000000; overflow <= 0; hilo_out <= 0;end 
        endcase
    end

    
            
endmodule

