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
    
    
    enum {pc_increment, pc_write} pc_mux;
    enum {dram_write_en, dram_write_noten} dram_write_sel;
    enum {reg_write_en, reg_write_noten} reg_wstatus;
    enum {alua_adata, alua_pc} alua_mux;
    enum {alub_bdata, alub_imm} alub_mux;
    enum {reg_write_alu, reg_write_dram, reg_write_pc} reg_write_sel;
    enum {
        alu_AND = 1'b1<<0,
        alu_ADD = 1'b1<<1,
        alu_OR = 1'b1<<2,
        alu_SLL = 1'b1<<3,
        alu_SRL = 1'b1<<4,
        alu_XOR = 1'b1<<5,
        alu_SRA = 1'b1<<6,
        alu_SUB = 1'b1<<7,
        alu_SLLU = 1'b1<<8,
        alu_SRLU = 1'b1<<9,
        alu_SLT = 1'b1<<10,
        alu_SLTU = 1'b1<<11,
        alu_LOAD_IMM_2_A = 1'b1<<12,
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