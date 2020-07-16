`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2020 09:27:34 AM
// Design Name: 
// Module Name: instruction_gen
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

package isa_gen;
//    enum {
//        x0 = 0, x1 = 1,
//        x2 = 2, x3 = 3,
//        x4 = 4, x5 = 5,
//        x6 = 6, x7 = 7,
//        x8 = 8, x9 = 9,
//        x10 = 10, x11 = 11,
//        x12 = 12, x13 = 13,
//        x14 = 14, x15 = 15,
//        x16 = 16, x17 = 17,
//        x18 = 18, x19 = 19,
//        x20 = 20, x21 = 21,
//        x22 = 22, x23 = 23,
//        x24 = 24, x25 = 25,
//        x26 = 26, x27 = 27,
//        x28 = 28, x29 = 29,
//        x30 = 30, x31 = 31
//    } registers ;

    

    parameter op_LUI = 'b0110111; 
    parameter op_AUIPC = 'b0010111;
    parameter op_JAL = 'b1101111;
    parameter op_JALR = 'b1100111;
    parameter op_BEQ = 'b1100011;
    parameter op_BNE = 'b1100011;
    parameter op_BLT = 'b1100011;
    parameter op_BGE = 'b1100011;
    parameter op_BLTU = 'b1100011;
    parameter op_BGEU = 'b1100011;
    parameter op_LB = 'b0000011;
    parameter op_LH = 'b0000011;
    parameter op_LW = 'b0000011;
    parameter op_LBU = 'b0000011;
    parameter op_LHU = 'b0000011;
    parameter op_SB = 'b0100011;
    parameter op_SH = 'b0100011;
    parameter op_SW = 'b0100011;
    parameter op_ADDI = 'b0010011;
    parameter op_SLTI = 'b0010011;
    parameter op_SLTIU = 'b0010011;
    parameter op_XORI = 'b0010011;
    parameter op_ORI = 'b0010011;
    parameter op_ANDI = 'b0010011;
    parameter op_SLLI = 'b0010011;
    parameter op_SRLI = 'b0010011;
    parameter op_SRAI = 'b0010011;
    parameter op_ADD = 'b0110011;
    parameter op_SUB = 'b0110011;
    parameter op_SLL = 'b0110011;
    parameter op_SLT = 'b0110011;
    parameter op_SLTU = 'b0110011;
    parameter op_XOR = 'b0110011;
    parameter op_SRL = 'b0110011;
    parameter op_SRA = 'b0110011;
    parameter op_OR = 'b0110011;
    parameter op_AND = 'b0110011;
    parameter op_CSRRW = 'b1110011;
    parameter op_CSRRS = 'b1110011;
    parameter op_CSRRC = 'b1110011;
    parameter op_CSRRWI = 'b1110011;
    parameter op_CSRRSI = 'b1110011;
    parameter op_CSRRCI = 'b1110011;


    //instructions not defined here have not been tested 
    `define LUI(rd,imm) {imm[31:12], rd[4:0], op_LUI[6:0]};
    `define LUI_corrected(rd,imm) {(imm[11] ? imm[31:12] + 1 : imm[31:12]), rd[4:0], op_LUI[6:0]}; //used for lui addi combo for loading values from instructions
    `define AUIPC(rd,imm) {imm[19:0], rd[4:0], op_AUIPC[6:0]};
    `define JAL(rd, imm) {imm[20], imm[10:1], imm[11], imm[19:12], rd[4:0], op_JAL[6:0]};
    `define JALR(rd, rs1, imm) {imm[11:0], rs1[4:0], 3'b000, rd[4:0], op_JALR[6:0]};
    `define BEQ(rs1, rs2, imm) {imm[12], imm[10:5], rs2[4:0], rs1[4:0], 3'b000, imm[4:1], imm[11], op_BEQ[6:0]};
    `define BNE(rs1, rs2, imm) {imm[12], imm[10:5], rs2[4:0], rs1[4:0], 3'b001, imm[4:1], imm[11], op_BNE[6:0]};
    `define BLT(rs1, rs2, imm) {imm[12], imm[10:5], rs2[4:0], rs1[4:0], 3'b100, imm[4:1], imm[11], op_BLT[6:0]};
    `define BGE(rs1, rs2, imm) {imm[12], imm[10:5], rs2[4:0], rs1[4:0], 3'b101, imm[4:1], imm[11], op_BGE[6:0]};
    `define BLTU(rs1, rs2, imm) {imm[12], imm[10:5], rs2[4:0], rs1[4:0], 3'b110, imm[4:1], imm[11], op_BLTU[6:0]};
    `define BGEU(rs1, rs2, imm) {imm[12], imm[10:5], rs2[4:0], rs1[4:0], 3'b111, imm[4:1], imm[11], op_BGEU[6:0]};
    `define LB(rd, base, offset) {offset[11:0], base[4:0], 3'b000, rd[4:0], op_LB[6:0]};
    `define LH(rd, base, offset) {offset[11:0], base[4:0], 3'b001, rd[4:0], op_LH[6:0]};
    `define LW(rd, base, offset) {offset[11:0], base[4:0], 3'b010, rd[4:0], op_LW[6:0]};
    `define LBU(rd, base, offset) {offset[11:0], base[4:0], 3'b100, rd[4:0], op_LBU[6:0]};
    `define LHU(rd, base, offset) {offset[11:0], base[4:0], 3'b101, rd[4:0], op_LHU[6:0]};
    `define SB(base, src, offset) {offset[11:5], src[4:0], base[4:0], 3'b000, offset[4:0], op_SB[6:0]}; //src == rs2
    `define SH(base, src, offset) {offset[11:5], src[4:0], base[4:0], 3'b001, offset[4:0], op_SH[6:0]}; //src == rs2
    `define SW(base, src, offset) {offset[11:5], src[4:0], base[4:0], 3'b010, offset[4:0], op_SW[6:0]}; //src == rs2
    `define ADDI(rd, rs1, imm) {imm[11:0], rs1[4:0], 3'b000, rd[4:0], op_ADDI[6:0]};
    `define SLTI(rd, rs1, imm) {imm[11:0], rs1[4:0], 3'b010, rd[4:0], op_SLTI[6:0]};
    `define SLTIU(rd, rs1, imm) {imm[11:0], rs1[4:0], 3'b011, rd[4:0], op_SLTIU[6:0]};
    `define XORI(rd, rs1, imm) {imm[11:0], rs1[4:0], 3'b100, rd[4:0], op_XORI[6:0]};
    `define ORI(rd, rs1, imm) {imm[11:0], rs1[4:0], 3'b110, rd[4:0], op_ORI[6:0]};
    `define ANDI(rd, rs1, imm) {imm[11:0], rs1[4:0], 3'b111, rd[4:0], op_ANDI[6:0]};    
    `define SLLI(rd, rs1, shamt) {7'b0, shamt[4:0], rs1[4:0], 3'b001, rd[4:0], op_SLLI[6:0]};
    `define SRLI(rd, rs1, shamt) {7'b0, shamt[4:0], rs1[4:0], 3'b101, rd[4:0], op_SRLI[6:0]};
    `define SRAI(rd, rs1, shamt) {7'b0100000, shamt[4:0], rs1[4:0], 3'b101, rd[4:0], op_SRAI[6:0]};
    `define ADD_(rd, rs1, rs2) {7'b0000000, rs2[4:0], rs1[4:0], 3'b000, rd[4:0], op_ADD[6:0]};
    `define SUB(rd, rs1, rs2) {7'b0100000, rs2[4:0], rs1[4:0], 3'b000, rd[4:0], op_SUB[6:0]};
    `define SLL(rd, rs1, rs2) {7'b0000000, rs2[4:0], rs1[4:0], 3'b001, rd[4:0], op_SLL[6:0]};
    `define SLT(rd, rs1, rs2) {7'b0000000, rs2[4:0], rs1[4:0], 3'b010, rd[4:0], op_SLT[6:0]};
    `define SLTU(rd, rs1, rs2) {7'b0000000, rs2[4:0], rs1[4:0], 3'b011, rd[4:0], op_SLTU[6:0]};
    `define XOR_(rd, rs1, rs2) {7'b0000000, rs2[4:0], rs1[4:0], 3'b100, rd[4:0], op_XOR[6:0]};
    `define SRL(rd, rs1, rs2) {7'b0000000, rs2[4:0], rs1[4:0], 3'b101, rd[4:0], op_SRL[6:0]};
    `define SRA(rd, rs1, rs2) {7'b0100000, rs2[4:0], rs1[4:0], 3'b101, rd[4:0], op_SRA[6:0]};
    `define OR_(rd, rs1, rs2) {7'b0000000, rs2[4:0], rs1[4:0], 3'b110, rd[4:0], op_OR[6:0]};
    `define AND_(rd, rs1, rs2) {7'b0000000, rs2[4:0], rs1[4:0], 3'b111, rd[4:0], op_AND[6:0]};
    //fence
    //fence.i
    //ecall
    //ebreak    
    `define CSRRW(rd, rs1, addr) {addr[11:0], rs1[4:0], 3'b001, rd[4:0], op_CSRRW[6:0]};
    `define CSRRS(rd, rs1, addr) {addr[11:0], rs1[4:0], 3'b010, rd[4:0], op_CSRRS[6:0]};
    `define CSRRC(rd, rs1, addr) {addr[11:0], rs1[4:0], 3'b011, rd[4:0], op_CSRRC[6:0]};
    `define CSRRWI(rd, zimm, addr) {addr[11:0], zimm[4:0], 3'b101, rd[4:0], op_CSRRWI[6:0]};
    `define CSRRSI(rd, zimm, addr) {addr[11:0], zimm[4:0], 3'b110, rd[4:0], op_CSRRSI[6:0]};
    `define CSRRCI(rd, zimm, addr) {addr[11:0], zimm[4:0], 3'b111, rd[4:0], op_CSRRCI[6:0]};
    

endpackage

