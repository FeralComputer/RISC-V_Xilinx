`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2020 10:28:41 AM
// Design Name: 
// Module Name: core
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

module core();
    
    logic rd_enable;
    logic [4:0] rs1, rs2, rd;    int indata;
    int adata, bdata, register_write;
    
    int program_counter, instruction;
    
    logic dram_write;
    int dram_addra, dram_addrb, dram_dia, dram_dob;
    
    logic modify_pc;
    int modified_pc;
    
    logic [number_of_instructions-1:0] instruct_select;
    logic [5:0] instruction_type;
    logic instruction_decode_fault;
    int immediate;
    int alu_result;
    
    
    

    register regs(.clk(clk), .reset_n(reset_n), .enable(enable), .rd_enable(rd_enable), .rs1(rs1), .rs2(rs2), .rd(rd), 
                .adata(adata), .bdata(bdata), .indata(register_write));
    ram iram(.clk(clk), .ena(debug_enable_write_iram ), .addrb(enable ? program_counter : debug_read_addr_iram), .addra(debug_write_addr_iram), 
                .dia(debug_write_data_iram ), .dob(instruction), .memory_sizea(3'b100), .memory_sizeb(3'b100) ); // keep memory size at 32 bits for now...
    ram dram(.clk(clk), .ena(dram_write | debug_write_data_dram), .addrb(enable ? dram_addrb : debug_read_addr_dram), .addra(enable ? dram_addra : debug_write_addr_dram), .dia(enable ? dram_dia : debug_write_addr_dram), 
                .dob(dram_dob), .memory_sizea(3'b100), .memory_sizeb(3'b100)); // keep memory size at 32 bits for now...
    programcounter pc(.clk(clk), .reset_n(reset_n), .enable(enable), .modify_pc(modify_pc), .modified_pc(modified_pc),
                .program_counter(program_counter));
    alu #(number_of_instructions)alu_(clk, reset_n, enable, rs1, rs2, immediate, instruction_select, alu_result);
    
    // assigns the register addresses (these may not be valid depending on instruction and needs to be checked in register module)
    assign rd = instruction[11:7];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];

endmodule