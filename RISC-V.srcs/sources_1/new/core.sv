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
    logic alu_result_b0_clear;
    logic  pc_wsel, reg_wen;
    logic dram_wsel; 
    logic [1:0] reg_wdata_sel;
    logic alua_sel, alub_sel;
    logic unsign;
    logic dram_sign;
    logic [2:0] dram_mem_size_a, dram_mem_size_b;
    
    int csr_result, csr_data;
    logic [2:0] csr_sel;
    logic [11:0] csr_addr;
    logic csr_data_sel;
    
    int next_program_counter;
    
    //brains of the operation (hopefully)
    control ctrl(.instruction(instruction), .br_ne(br_ne), .br_lt(br_lt), .alu_sel(alu_sel), .pc_wsel(pc_wsel),
                    .reg_wen(reg_wen), .alua_sel(alua_sel), .alub_sel(alub_sel), .dram_wsel(dram_wsel), .reg_wdata_sel(reg_wdata_sel), 
                    .instruction_type(isa_type), .decode_error(decode_error), .unsign(unsign), .dram_sign(dram_sign), 
                    .dram_mem_size_b(dram_mem_size_b), .dram_mem_size_a(dram_mem_size_a), .csr_sel(csr_sel), .csr_data_sel(csr_data_sel),
                    .alu_result_b0_clear(alu_result_b0_clear));
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
    
    csr #(32) csr_ (.clk(clk), .reset_n(reset_n), .enable(enable), .csr_result(csr_result),
                    .csr_data(csr_data), .csr_sel(csr_sel), .csr_addr(csr_addr));
    
    assign alu_in1 = alua_sel == pc_write ? program_counter : adata; //selects alu input 1
    assign alu_in2 = alub_sel == alub_imm ? immediate : bdata; // selects alu input 2
    
    assign csr_addr = instruction[31:20];
    assign csr_data = csr_data_sel == csr_uimm_sel ? {27'b0, instruction[19:15]} : adata; //select input into csr (uimm or rs1)
    
    // assigns the register addresses (these may not be valid depending on instruction and needs to be checked in register module)
    assign rd = instruction[11:7];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    
    // selects between alu ,dram, csr, and pc to register
    always_comb begin
        case(reg_wdata_sel)
            reg_write_alu : reg_wdata = {alu_result[31:1], alu_result_b0_clear ? 1'b0 : alu_result[0]};// this needs a condition for jalr setting the first bit to 0
            reg_write_dram : reg_wdata = dram_dob;
            reg_write_pc : reg_wdata = program_counter + 4;// this should be redone to remove the redundant adder...
            reg_write_csr : reg_wdata = csr_result;
            default : reg_wdata = 'bx;
        endcase
    end
     
    `ifdef DEBUG
        always_ff @ (negedge clk) begin
            if(reset_n && enable) begin
//              prints out what the core is doing on the negedge to get all the current values for the instruction
                casex(instruction)
                    LUI.instruct_compare: $display("LUI: \tpc = %0d \trd = r%0d \timm = %0d \tresult = %0d", program_counter, rd, immediate, reg_wdata);
                    AUIPC.instruct_compare: $display("AUIPC: \trd = r%0d \timm = %0d \tpc = %0d \tresult = %0d", rd, immediate, program_counter, reg_wdata);
                    JAL.instruct_compare: $display("JAL: \tpc = %0d \trd = r%0d \toffset = %0d", program_counter, rd, immediate);
                    JALR.instruct_compare: $display("JALR: \tpc = %0d \trd = r%0d \trs1 = r%0d \toffset = %0d \tbase = %0d \tresult = %0d", program_counter, rd, rs1, alu_in2, alu_in1, alu_result);
                    BEQ.instruct_compare: $display("BEQ: \tpc = %0d \trs1 = r%0d \trs2 = r%0d \tadata = %0d \tbdata = %0d \toffset = %0d \tbr_ne = %0d \tbr_lt = %0d \tunsign = %0d", program_counter, rs1, rs2, adata, bdata, immediate, br_ne, br_lt, unsign);
                    BNE.instruct_compare: $display("BNE: \tpc = %0d \trs1 = r%0d \trs2 = r%0d \tadata = %0d \tbdata = %0d \toffset = %0d \tbr_ne = %0d \tbr_lt = %0d \tunsign = %0d", program_counter, rs1, rs2, adata, bdata, immediate, br_ne, br_lt, unsign);
                    BLT.instruct_compare: $display("BLT: \tpc = %0d \trs1 = r%0d \trs2 = r%0d \tadata = %0d \tbdata = %0d \toffset = %0d \tbr_ne = %0d \tbr_lt = %0d \tunsign = %0d", program_counter, rs1, rs2, adata, bdata, immediate, br_ne, br_lt, unsign);
                    BGE.instruct_compare: $display("BGE: \tpc = %0d \trs1 = r%0d \trs2 = r%0d \tadata = %0d \tbdata = %0d \toffset = %0d \tbr_ne = %0d \tbr_lt = %0d \tunsign = %0d", program_counter, rs1, rs2, adata, bdata, immediate, br_ne, br_lt, unsign);
                    BLTU.instruct_compare: $display("BLTU: \tpc = %0d \trs1 = r%0d \trs2 = r%0d \tadata = %0d \tbdata = %0d \toffset = %0d \tbr_ne = %0d \tbr_lt = %0d \tunsign = %0d", program_counter, rs1, rs2, adata, bdata, immediate, br_ne, br_lt, unsign);
                    BGEU.instruct_compare: $display("BGEU: \tpc = %0d \trs1 = r%0d \trs2 = r%0d \tadata = %0d \tbdata = %0d \toffset = %0d \tbr_ne = %0d \tbr_lt = %0d \tunsign = %0d", program_counter, rs1, rs2, adata, bdata, immediate, br_ne, br_lt, unsign);
                    LB.instruct_compare: $display("LB: \tpc = %0d \tbase = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", program_counter, rs1, immediate, alu_result, reg_wdata);
                    LH.instruct_compare: $display("LH: \tpc = %0d \tbase = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", program_counter, rs1, immediate, alu_result, reg_wdata);
                    LW.instruct_compare: $display("LW: \tpc = %0d \tbase = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", program_counter, rs1, immediate, alu_result, reg_wdata);
                    LBU.instruct_compare: $display("LBU: \tpc = %0d \tbase = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", program_counter, rs1, immediate, alu_result, reg_wdata);
                    LHU.instruct_compare: $display("LHU: \tpc = %0d \tbase = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", program_counter, rs1, immediate, alu_result, reg_wdata);
                    SB.instruct_compare: $display("SB: \tpc = %0d \tbase = r%0d \tsrc = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", program_counter, rs1, rs2, immediate, alu_result, bdata);
                    SH.instruct_compare: $display("SH: \tpc = %0d \tbase = r%0d \tsrc = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", program_counter, rs1, rs2, immediate, alu_result, bdata);
                    SW.instruct_compare: $display("SW: \tpc = %0d \tbase = r%0d \tsrc = r%0d \toffset = %0d \taddress = %0d \tvalue = %0d", program_counter, rs1, rs2, immediate, alu_result, bdata);
                    ADDI.instruct_compare: $display("ADDI: \tpc = %0d \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, alu_in1, alu_in2, reg_wdata);
                    SLTI.instruct_compare: $display("SLTI: \tpc = %0d \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, alu_in1, alu_in2, reg_wdata);
                    SLTIU.instruct_compare: $display("SLTIU: \tpc = %0d \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, alu_in1, alu_in2, reg_wdata);
                    XORI.instruct_compare: $display("XORI: \tpc = %0d \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, alu_in1, alu_in2, reg_wdata);
                    ORI.instruct_compare: $display("ORI: \tpc = %0d \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, alu_in1, alu_in2, reg_wdata);
                    ANDI.instruct_compare: $display("ANDI: \tpc = %0d \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, alu_in1, alu_in2, reg_wdata);
                    SLLI.instruct_compare: $display("SLLI: \tpc = %0d \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, alu_in1, alu_in2, reg_wdata);
                    SRLI.instruct_compare: $display("SRLI: \tpc = %0d \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, alu_in1, alu_in2, reg_wdata);
                    SRAI.instruct_compare: $display("SRAI: \tpc = %0d \trd = r%0d \trs1 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, alu_in1, alu_in2, reg_wdata);
                    ADD.instruct_compare: $display("ADD: \tpc = %0d \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    SUB.instruct_compare: $display("SUB: \tpc = %0d \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    SLL.instruct_compare: $display("SLL: \tpc = %0d \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    SLT.instruct_compare: $display("SLT: \tpc = %0d \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    SLTU.instruct_compare: $display("SLTU: \tpc = %0d \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    XOR_.instruct_compare: $display("XOR: \tpc = %0d \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    SRL.instruct_compare: $display("SRL: \tpc = %0d \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    SRA.instruct_compare: $display("SRA: \tpc = %0d \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    OR_.instruct_compare: $display("OR: \tpc = %0d \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    AND_.instruct_compare: $display("AND: \tpc = %0d \trd = r%0d \trs1 = r%0d \trs2 = r%0d \talu1 = %0d \talu2 = %0d \tresult = %0d", program_counter, rd, rs1, rs2, alu_in1, alu_in2, reg_wdata);
                    CSRRW.instruct_compare: $display("CSRRW: \tpc = %0d \trd = r%0d \trs1 = r%0d \tdata = %0d \tresult = %0d", program_counter, rd, rs1, csr_data, reg_wdata);
                    CSRRS.instruct_compare: $display("CSRRS: \tpc = %0d \trd = r%0d \trs1 = r%0d \tdata = %0d \tresult = %0d", program_counter, rd, rs1, csr_data, reg_wdata);
                    CSRRC.instruct_compare: $display("CSRRC: \tpc = %0d \trd = r%0d \trs1 = r%0d \tdata = %0d \tresult = %0d", program_counter, rd, rs1, csr_data, reg_wdata);
                    CSRRWI.instruct_compare: $display("CSRRWI: \tpc = %0d \trd = r%0d \trs1 = r%0d \tdata = %0d \tresult = %0d", program_counter, rd, rs1, csr_data, reg_wdata);
                    CSRRSI.instruct_compare: $display("CSRRSI: \tpc = %0d \trd = r%0d \trs1 = r%0d \tdata = %0d \tresult = %0d", program_counter, rd, rs1, csr_data, reg_wdata);
                    CSRRCI.instruct_compare: $display("CSRRCI: \tpc = %0d \trd = r%0d \trs1 = r%0d \tdata = %0d \tresult = %0d", program_counter, rd, rs1, csr_data, reg_wdata);
                    default: $display("Unknown instruction: %0h", instruction);
                endcase
            end
        end
    
    `endif

endmodule