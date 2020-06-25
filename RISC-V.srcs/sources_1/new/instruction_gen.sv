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
    enum {
        x0 = 0, x1 = 1,
        x2 = 2, x3 = 3,
        x4 = 4, x5 = 5,
        x6 = 6, x7 = 7,
        x8 = 8, x9 = 9,
        x10 = 10, x11 = 11,
        x12 = 12, x13 = 13,
        x14 = 14, x15 = 15,
        x16 = 16, x17 = 17,
        x18 = 18, x19 = 19,
        x20 = 20, x21 = 21,
        x22 = 22, x23 = 23,
        x24 = 24, x25 = 25,
        x26 = 26, x27 = 27,
        x28 = 28, x29 = 29,
        x30 = 30, x31 = 31
    } registers ;


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


    `define LUI(rd,imm) {imm[19:0], rd[4:0], op_LUI};
    `define AUIPC(rd,imm) {imm[19:0], rd[4:0], op_AUIPC};
    `define ADDI(rd, rs1, imm) {imm[11:0], rs1[4:0], 'b000, rd[4:0], op_ADDI};
    `define LW(rd, base, offset) {offset[11:0], base[4:0], 'b010, rd[4:0], op_LW};
    `define SW(base, src, offset) {offset[11:5], src[4:0], base[4:0], 'b010, offset[4:0], op_SW};
    `define AND_(rd, rs1, rs2) {7'b0, rs2[4:0], rs1[4:0], 3'b111, rd[4:0], op_AND};

endpackage

