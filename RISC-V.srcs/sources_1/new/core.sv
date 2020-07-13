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

`define DEBUG = 1;

module core(input logic clk, reset_n, enable,
            input logic debug_enable_write_iram, debug_enable_write_dram,
            input int debug_read_addr_iram, debug_read_addr_dram,
            input int debug_write_addr_iram, debug_write_addr_dram,
            input int debug_write_data_iram, debug_write_data_dram,
            output int dram_dob, instruction, program_counter,
            output logic decode_error
            );
    
    logic [4:0] rs1, rs2, rd;    
    

    int dram_addra, dram_addrb, dram_dia;
    
    
    logic [ISA_TYPE_COUNT-1:0] isa_type;
    int immediate;
    int alu_result;
    logic [ALU_INSTRUCTION_COUNT-1:0] alu_sel;
    
    logic br_ne, br_lt;
    int adata, bdata;
    int reg_wdata, alu_in1, alu_in2;
    logic  pc_wsel, reg_wen;
    logic dram_wsel; 
    logic [1:0] reg_wdata_sel;
    logic alua_sel, alub_sel;
    logic unsign;
    logic dram_sign;
    logic [2:0] dram_mem_size_a, dram_mem_size_b;
    
    int next_program_counter;
    
    //brains of the operation (hopefully)
    control ctrl(.instruction(instruction), .br_ne(br_ne), .br_lt(br_lt), .alu_sel(alu_sel), .pc_wsel(pc_wsel),
                    .reg_wen(reg_wen), .alua_sel(alua_sel), .alub_sel(alub_sel), .dram_wsel(dram_wsel), .reg_wdata_sel(reg_wdata_sel), 
                    .instruction_type(isa_type), .decode_error(decode_error), .unsign(unsign), .dram_sign(dram_sign), 
                    .dram_mem_size_b(dram_mem_size_b), .dram_mem_size_a(dram_mem_size_a));
    //
    register regs(.clk(clk), .reset_n(reset_n), .enable(enable), .rd_enable(reg_wen == reg_write_en), .rs1(rs1), .rs2(rs2), .rd(rd), 
                .adata(adata), .bdata(bdata), .indata(reg_wdata));
                
    ram iram(.clk(clk), .ena(debug_enable_write_iram ), .addrb(enable ? program_counter : debug_read_addr_iram), .addra(debug_write_addr_iram), 
                .dia(debug_write_data_iram ), .dob(instruction), .memory_sizea(ram_word), .memory_sizeb(ram_word), .sign(0) ); // keep memory size at 32 bits for now...
                
    ram dram(.clk(clk), .ena(dram_wsel == dram_write_en | debug_enable_write_dram), .addrb(enable ? alu_result : debug_read_addr_dram), .addra(enable ? alu_result : debug_write_addr_dram), 
                .dia(enable ? bdata : debug_write_data_dram), .dob(dram_dob), .memory_sizea(dram_mem_size_a), .memory_sizeb(dram_mem_size_b), .sign(dram_sign)); // keep memory size at 32 bits for now...
                
    programcounter pc(.clk(clk), .reset_n(reset_n), .enable(enable), .modify_pc(pc_wsel), .modified_pc(alu_result),
                .program_counter(program_counter), .next_program_counter(next_program_counter));
                
    alu alu_(.adata(alu_in1), .bdata(alu_in2), .instruction_select(alu_sel), .result(alu_result));
    
    imm_gen imm_gen_ (.isa_type(isa_type), .instruction(instruction), .result(immediate));
    
    branch_gen branch (.adata(adata), .bdata(bdata), .ne(br_ne), .lt(br_lt), .unsign(unsign));
    
    assign alu_in1 = alua_sel == pc_write ? program_counter : adata; //selects alu input 1
    assign alu_in2 = alub_sel == alub_imm ? immediate : bdata; // selects alu input 2
    
    // assigns the register addresses (these may not be valid depending on instruction and needs to be checked in register module)
    assign rd = instruction[11:7];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    
    // selects between alu ,dram, and pc to register
    always_comb begin
        case(reg_wdata_sel)
            reg_write_alu : reg_wdata = alu_result;
            reg_write_dram : reg_wdata = dram_dob;
            reg_write_pc : reg_wdata = next_program_counter;
            default : reg_wdata = 'bx;
        endcase
    end
     
    `ifdef DEBUG
        always_ff @ (negedge clk) begin
            if(reset_n && enable) begin
//              prints out what the core is doing on the negedge to get all the current values for the instruction
                casex(instruction)
                    LUI.instruct_compare: $display("LUI: \trd = r%0d \timm = %0d \tresult = %0d", rd, immediate, reg_wdata);
                    AUIPC.instruct_compare: $display("AUIPC: \trd = r%0d \timm = %0d \tpc = %0d \tresult = %0d", rd, immediate, program_counter, reg_wdata);
                    JAL.instruct_compare: $display("JAL: \trd = r%0d \toffset = %0d", rd, immediate);
                    JALR.instruct_compare: $display("JALR: \trd = r%0d \trs1 = r%0d \toffset = %0d \tbase = %0d", rd, rs1, immediate, alu_result);
                    BEQ.instruct_compare: $display("BEQ: \trs1 = r%0d \trs2 = r%0d \tadata = %0d \tbdata = %0d \toffset = %0d \tbr_ne = %0d \tbr_lt = %0d \tunsign = %0d", rs1, rs2, adata, bdata, immediate, br_ne, br_lt, unsign);
                    BNE.instruct_compare: $display("BNE: \trs1 = r%0d \trs2 = r%0d \tadata = %0d \tbdata = %0d \toffset = %0d \tbr_ne = %0d \tbr_lt = %0d \tunsign = %0d", rs1, rs2, adata, bdata, immediate, br_ne, br_lt, unsign);
                    BLT.instruct_compare: $display("BLT: \trs1 = r%0d \trs2 = r%0d \tadata = %0d \tbdata = %0d \toffset = %0d \tbr_ne = %0d \tbr_lt = %0d \tunsign = %0d", rs1, rs2, adata, bdata, immediate, br_ne, br_lt, unsign);
                    BGE.instruct_compare: $display("BGE: \trs1 = r%0d \trs2 = r%0d \tadata = %0d \tbdata = %0d \toffset = %0d \tbr_ne = %0d \tbr_lt = %0d \tunsign = %0d", rs1, rs2, adata, bdata, immediate, br_ne, br_lt, unsign);
                    BLTU.instruct_compare: $display("BLTU: \trs1 = r%0d \trs2 = r%0d \tadata = %0d \tbdata = %0d \toffset = %0d \tbr_ne = %0d \tbr_lt = %0d \tunsign = %0d", rs1, rs2, adata, bdata, immediate, br_ne, br_lt, unsign);
                    BGEU.instruct_compare: $display("BGEU: \trs1 = r%0d \trs2 = r%0d \tadata = %0d \tbdata = %0d \toffset = %0d \tbr_ne = %0d \tbr_lt = %0d \tunsign = %0d", rs1, rs2, adata, bdata, immediate, br_ne, br_lt, unsign);
                    LB.instruct_compare: $display("LB: \tbase = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", rs1, immediate, alu_result, reg_wdata);
                    LH.instruct_compare: $display("LH: \tbase = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", rs1, immediate, alu_result, reg_wdata);
                    LW.instruct_compare: $display("LW: \tbase = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", rs1, immediate, alu_result, reg_wdata);
                    LBU.instruct_compare: $display("LBU: \tbase = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", rs1, immediate, alu_result, reg_wdata);
                    LHU.instruct_compare: $display("LHU: \tbase = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", rs1, immediate, alu_result, reg_wdata);
                    SB.instruct_compare: $display("SB: \tbase = r%0d \tsrc = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", rs1, rs2, immediate, alu_result, bdata);
                    SH.instruct_compare: $display("SH: \tbase = r%0d \tsrc = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", rs1, rs2, immediate, alu_result, bdata);
                    SW.instruct_compare: $display("SW: \tbase = r%0d \tsrc = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", rs1, rs2, immediate, alu_result, bdata);
                    ADDI.instruct_compare: $display("ADDI: \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, alu_in1, alu_in2, reg_wdata);
                    SLTI.instruct_compare: $display("SLTI: \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, alu_in1, alu_in2, reg_wdata);
                    SLTIU.instruct_compare: $display("SLTIU: \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, alu_in1, alu_in2, reg_wdata);
                    XORI.instruct_compare: $display("XORI: \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, alu_in1, alu_in2, reg_wdata);
                    ORI.instruct_compare: $display("ORI: \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, alu_in1, alu_in2, reg_wdata);
                    ANDI.instruct_compare: $display("ANDI: \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, alu_in1, alu_in2, reg_wdata);
                    SLLI.instruct_compare: $display("SLLI: \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, alu_in1, alu_in2, reg_wdata);
                    SRLI.instruct_compare: $display("SRLI: \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, alu_in1, alu_in2, reg_wdata);
                    SRAI.instruct_compare: $display("SRAI: \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, alu_in1, alu_in2, reg_wdata);
                    ADD.instruct_compare: $display("ADD: \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    SUB.instruct_compare: $display("SUB: \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    SLL.instruct_compare: $display("SLL: \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    SLT.instruct_compare: $display("SLT: \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    SLTU.instruct_compare: $display("SLTU: \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    XOR_.instruct_compare: $display("XOR: \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    SRL.instruct_compare: $display("SRL: \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    SRA.instruct_compare: $display("SRA: \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    OR_.instruct_compare: $display("OR: \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    AND_.instruct_compare: $display("AND: \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    default: $display("Unknown instruction: %0b", instruction);
                endcase
            end
        end
    
    `endif

endmodule