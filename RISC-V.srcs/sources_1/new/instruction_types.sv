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


package isa_types;
    typedef struct packed {
        logic [6:0] funct7;
        logic [4:0] rs2;
        logic [4:0] rs1;
        logic [2:0] funct3;
        logic [4:0] rd;
        logic [6:0] opcode;
    } rtype;
    
    typedef struct packed {
        logic [11:0] funct7;
        logic [4:0] rs1;
        logic [2:0] funct3;
        logic [4:0] rd;
        logic [6:0] opcode;
    } itype;
    
    typedef struct packed {
        logic [6:0] imm2;
        logic [4:0] rs2;
        logic [4:0] rs1;
        logic [2:0] funct3;
        logic [4:0] imm;
        logic [6:0] opcode;
    } stype;
    
    typedef struct packed {
        logic imm4;
        logic [5:0] imm2;
        logic [4:0] rs2;
        logic [4:0] rs1;
        logic [2:0] funct3;
        logic [4:0] imm;
        logic imm3;
        logic [6:0] opcode;
    } btype;
    
    typedef struct packed {
        logic [19:0] imm;
        logic [4:0] rd;
        logic [6:0] opcode;
    } utype;
    
    typedef struct packed {
        logic imm4;
        logic [9:0] imm;
        logic imm2;
        logic [7:0] imm3;
        logic [4:0] rd;
        logic [6:0] opcode;
    } jtype;
endpackage