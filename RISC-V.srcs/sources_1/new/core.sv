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
import risc_structs::*;

module core(input logic clk, reset_n, enable,
            input logic debug_enable_write_iram, debug_enable_write_dram,
            input int debug_read_addr_iram, debug_read_addr_dram,
            input int debug_write_addr_iram, debug_write_addr_dram,
            output int dram_dob, instruction,
            output logic decode_error
            );
    
    logic rd_enable;
    logic [4:0] rs1, rs2, rd;    
    int adata, bdata, register_write;
    
    int program_counter;
    
    logic dram_write;
    int dram_addra, dram_addrb, dram_dia;
    
    
    logic [ISA_TYPE_COUNT-1:0] isa_type;
    int immediate;
    int alu_result;
    logic [ALU_INSTRUCTION_COUNT-1:0] alu_sel;
    
    logic br_ne, br_lt;
    logic pc_wsel;
    
    int alu_in1, alu_in2;
    logic reg_wdata, pc_wsel;
    logic dram_wsel; 
    logic [1:0] reg_wdata_sel;
    logic alua_sel, alub_sel;
    
    //brains of the operation (hopefully)
    control ctrl(.instruction(instruction), .br_ne(br_ne), .br_lt(br_lt), .alu_sel(alu_sel), .pc_wsel(pc_wsel),
                    .reg_wen(reg_wen), .alua_sel(alua_sel), .alub_sel(alub_sel), .dram_wsel(dram_wsel), .reg_wdata_sel(reg_wdata_sel), 
                    .instruction_type(isa_type), .decode_error(decode_error));
    //
    register regs(.clk(clk), .reset_n(reset_n), .enable(enable), .rd_enable(reg_wen), .rs1(rs1), .rs2(rs2), .rd(rd), 
                .adata(adata), .bdata(bdata), .indata(reg_wdata));
                
    ram iram(.clk(clk), .ena(debug_enable_write_iram ), .addrb(enable ? program_counter : debug_read_addr_iram), .addra(debug_write_addr_iram), 
                .dia(debug_write_data_iram ), .dob(instruction), .memory_sizea(3'b100), .memory_sizeb(3'b100) ); // keep memory size at 32 bits for now...
                
    ram dram(.clk(clk), .ena(dram_wsel | debug_write_data_dram), .addrb(enable ? bdata : debug_read_addr_dram), .addra(enable ? bdata : debug_write_addr_dram), .dia(enable ? alu_result : debug_write_addr_dram), 
                .dob(dram_dob), .memory_sizea(3'b100), .memory_sizeb(3'b100)); // keep memory size at 32 bits for now...
                
    programcounter pc(.clk(clk), .reset_n(reset_n), .enable(enable), .modify_pc(pc_wsel), .modified_pc(alu_result),
                .program_counter(program_counter));
                
    alu alu_(.adata(alu_in1), .bdata(alu_in2), .instruction_select(alu_sel), .result(alu_result));
    
    imm_gen imm_gen_ (.isa_type(isa_type), .instruction(instruction), .result(immediate));
    
    assign alu_in1 = alua_sel == pc_write ? program_counter : adata; //selects alu input 1
    assign alu_in2 = alub_sel == alub_imm ? immediate : bdata; // selects alu input 2
    
    // assigns the register addresses (these may not be valid depending on instruction and needs to be checked in register module)
    assign rd = instruction[11:7];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    
    // selects between alu ,dram, and pc to register
    always_comb begin
        unique case(reg_wdata_sel)
            reg_write_alu : reg_wdata = alu_result;
            reg_write_dram : reg_wdata = dram_dob;
            reg_write_pc : reg_wdata = program_counter;
        endcase
    end

endmodule