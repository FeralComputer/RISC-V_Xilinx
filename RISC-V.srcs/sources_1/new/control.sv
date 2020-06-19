`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2020 10:28:41 AM
// Design Name: 
// Module Name: control
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


module control(input clk, reset_n, enable, write_instruction,
                input int write_instruct_addr, write_instruct_data,
                output int data
    );
    
    logic rd_enable;
    logic [4:0] rs1, rs2, rd;    int indata;
    int adata, bdata;
    
    int program_counter, instruction;
    
    logic dram_write;
    int dram_addra, dram_addrb, dram_dia, dram_dob;
    
    logic modify_pc;
    int modified_pc;
    

    register regs(.clk(clk), .reset_n(reset_n), .enable(enable), .rd_enable(rd_enable), .rs1(rs1), .rs2(rs2), .rd(rd), 
                .adata(adata), .bdata(bdata));
    ram iram(.clk(clk), .ena(write_instruction), .addrb(program_counter), .addra(write_instruct_addr), .dia(write_instruct_data), 
                .dob(instruction), .memory_sizea(3'b100), .memory_sizeb(3'b100) );
    ram dram(.clk(clk), .ena(dram_write), .addrb(dram_addrb), .addra(dram_addra), .dia(dram_dia), 
                .dob(dram_dob), .memory_sizea(3'b100), .memory_sizeb(3'b100)); // keep memory size at 32 bits for now...
    programcounter pc(.clk(clk), .reset_n(reset_n), .enable(enable), .modify_pc(modify_pc), .modified_pc(modified_pc),
                .program_counter(program_counter));
//    alu alu_();
    
endmodule