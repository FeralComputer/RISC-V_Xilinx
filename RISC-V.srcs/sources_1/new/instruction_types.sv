`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2020 01:37:15 PM
// Design Name: 
// Module Name: instruction_types
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: maybe change these to interfaces but cannot have interface of interfaces
// 
//////////////////////////////////////////////////////////////////////////////////


package risc_structs;
    
    //enums for control module to other modules
    parameter ALU_INSTRUCTION_COUNT = 13;
    parameter IMM_GEN_SIZE = 4;
    parameter ISA_TYPE_COUNT = 6;
    
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
    
    enum {pc_increment, pc_write} pc_mux;
    enum {dram_write_en = 1, dram_write_noten = 0} dram_write_sel;
    enum {reg_write_en = 1, reg_write_noten = 0} reg_wstatus;
    enum {alua_adata = 0, alua_pc = 1} alua_mux;
    enum {alub_bdata = 0, alub_imm = 1} alub_mux;
    enum {reg_write_alu = 0, reg_write_dram = 1, reg_write_pc = 2} reg_write_sel;
    enum {
        alu_AND = 1,
        alu_ADD = 2,
        alu_OR = 4,
        alu_SLL = 8,
        alu_SRL = 16,
        alu_XOR = 32,
        alu_SRA = 64,
        alu_SUB = 128,
        alu_SLLU = 256,
        alu_SRLU = 512,
        alu_SLT = 1024,
        alu_SLTU = 2048,
        alu_LOAD_IMM_2_A = 4096,
        alu_NA = 0
        // AND_ = 1'b1<<12,
    } alu_select;
    
    //NA is used for idle(NOP?) and for error in decoding
    enum {R = 'b000001, I = 'b000010, S = 'b000100, B = 'b001000, U = 'b010000, J = 'b100000, NA = 'b0} isa_types;
    
    typedef struct {
        logic [31:0] instruct_compare;
        logic [5:0] isa_type;
        //string name;
    } instruct_template;
    
    
endpackage