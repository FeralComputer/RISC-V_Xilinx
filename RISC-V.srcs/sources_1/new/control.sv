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
import risc_structs::*;

module control( input int instruction,
                input br_ne, br_lt, // branch != and <
                output logic [ALU_INSTRUCTION_COUNT-1:0] alu_sel, //alu selection
                output logic pc_wsel, //selects pc increment or jump
                output logic reg_wen, //enables register write
                output logic alua_sel, //selects pc or adata going to alu
                output logic alub_sel, //selects imm or bdata going to alu
                output logic dram_wsel, //enables write to dram
                output logic [1:0] reg_wdata_sel, //selects between dram_output, alu_output, and pc
                output logic [ISA_TYPE_COUNT-1:0] instruction_type, //selects the imm sign extension
                output logic decode_error, //goes high when instruction did not match known instructions
                output logic unsign, //used by the banch gen for signed vs unsigned
                output logic dram_sign, // used by dram to determine if output should be signed or not
                output logic [2:0] dram_mem_size_a, //used by dram for determining write size
                output logic [2:0] dram_mem_size_b, //used by dram for determining read size
                output logic [2:0] csr_sel, //used to select instruction for csr
                output logic csr_data_sel, //used to select between adata and uimm for csr
                output logic alu_result_b0_clear //used to clear bit 0 of the alu result (JALR)
    );
    
    
   
    
    assign decode_error = instruction_type == NA ? 1 : 0;
    assign alu_sel = alu_select;

    
    
    always_comb begin
        //route info according to the instruction type
        
        alu_select = alu_NA;
        pc_wsel = pc_increment; //depends on instruction
        reg_wen = reg_write_noten; //depends on r, i
        alua_sel = alua_adata;
        alub_sel = alub_bdata;
        dram_wsel = dram_write_noten;
        reg_wdata_sel = reg_write_alu;
        unsign = 'bx;
        dram_sign = 1;
        dram_mem_size_a = ram_word;
        dram_mem_size_b = ram_word;
        csr_sel = csr_idle;
        csr_data_sel = 'bx;
        alu_result_b0_clear = 0;

        //determines instruction type and enables instruction flag relative to instruction
        casex(instruction) //: intruction_to_type_decoding
            LUI.instruct_compare:  begin //LUI
                instruction_type = LUI.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_LOAD_IMM_2_A;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end            
            AUIPC.instruct_compare:  begin 
                instruction_type = AUIPC.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_ADD;
                alua_sel = alua_pc;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;                
            end
            JAL.instruct_compare:  begin 
                instruction_type = JAL.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_pc;
                alu_select = alu_ADD;
                alua_sel = alua_pc;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_write;
            end            
            JALR.instruct_compare:  begin 
                instruction_type = JALR.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_pc;
                alu_select = alu_ADD;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_write;
                alu_result_b0_clear = 1;
            end            
            BEQ.instruct_compare:  begin 
                instruction_type = BEQ.isa_type;
                reg_wen = reg_write_noten;
                reg_wdata_sel = 'bx;
                alu_select = alu_ADD;
                alua_sel = alua_pc;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = br_ne ? pc_increment : pc_write;
            end            
            BNE.instruct_compare:  begin 
                instruction_type = BNE.isa_type;
                reg_wen = reg_write_noten;
                reg_wdata_sel = 'bx;
                alu_select = alu_ADD;
                alua_sel = alua_pc;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = br_ne ? pc_write : pc_increment;
            end            
            BLT.instruct_compare:  begin 
                instruction_type = BLT.isa_type;
                reg_wen = reg_write_noten;
                reg_wdata_sel = 'bx;
                alu_select = alu_ADD;
                alua_sel = alua_pc;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = br_lt ? pc_write : pc_increment;
                unsign = 0;
            end            
            BGE.instruct_compare:  begin 
                instruction_type = BGE.isa_type;
                reg_wen = reg_write_noten;
                reg_wdata_sel = 'bx;
                alu_select = alu_ADD;
                alua_sel = alua_pc;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = br_lt ? pc_increment : pc_write;
                unsign = 0;
            end            
            BLTU.instruct_compare:  begin //need to tell the branch module unsigned
                instruction_type = BLTU.isa_type;
                reg_wen = reg_write_noten;
                reg_wdata_sel = 'bx;
                alu_select = alu_ADD;
                alua_sel = alua_pc;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = br_lt ? pc_write : pc_increment;
                unsign = 1;
            end            
            BGEU.instruct_compare:  begin //need to tell the branch module unsigned
                instruction_type = BGEU.isa_type;
                reg_wen = reg_write_noten;
                reg_wdata_sel = 'bx;
                alu_select = alu_ADD;
                alua_sel = alua_pc;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = br_lt ? pc_increment : pc_write;
                unsign = 1;
            end            
            LB.instruct_compare: begin 
                instruction_type = LB.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_dram;
                alu_select = alu_ADD;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
                dram_mem_size_b = ram_byte;
            end
            LH.instruct_compare: begin 
                instruction_type = LH.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_dram;
                alu_select = alu_ADD;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
                dram_mem_size_b = ram_half_word;
            end
            LW.instruct_compare: begin 
                instruction_type = LW.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_dram;
                alu_select = alu_ADD;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
                dram_mem_size_b = ram_word;
            end
            LBU.instruct_compare: begin 
                instruction_type = LBU.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_dram;
                alu_select = alu_ADD;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
                dram_sign = 0;
                dram_mem_size_b = ram_byte;
            end
            LHU.instruct_compare: begin 
                instruction_type = LHU.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_dram;
                alu_select = alu_ADD;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
                dram_sign = 0;
                dram_mem_size_b = ram_half_word;
            end
            SB.instruct_compare: begin 
                instruction_type = SB.isa_type;
                reg_wen = reg_write_noten;
                reg_wdata_sel = 'bx;
                alu_select = alu_ADD;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_en;
                pc_wsel = pc_increment;
                dram_mem_size_a = ram_byte;
            end
            SH.instruct_compare: begin 
                instruction_type = SH.isa_type;
                reg_wen = reg_write_noten;
                reg_wdata_sel = 'bx;
                alu_select = alu_ADD;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_en;
                pc_wsel = pc_increment;
                dram_mem_size_a = ram_half_word;
            end
            SW.instruct_compare: begin 
                instruction_type = SW.isa_type;
                reg_wen = reg_write_noten;
                reg_wdata_sel = 'bx;
                alu_select = alu_ADD;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_en;
                pc_wsel = pc_increment;
                dram_mem_size_a = ram_word;
            end
            ADDI.instruct_compare: begin 
                instruction_type = ADDI.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_ADD;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            SLTI.instruct_compare: begin 
                instruction_type = SLTI.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_SLT;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            SLTIU.instruct_compare: begin 
                instruction_type = SLTIU.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_SLTU;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            XORI.instruct_compare: begin 
                instruction_type = XORI.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_XOR;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            ORI.instruct_compare: begin 
                instruction_type = ORI.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_OR;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            ANDI.instruct_compare: begin 
                instruction_type = ANDI.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_AND;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            SLLI.instruct_compare: begin 
                instruction_type = SLLI.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_SLL;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            SRLI.instruct_compare: begin 
                instruction_type = SRLI.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_SRL;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            SRAI.instruct_compare: begin 
                instruction_type = SRAI.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_SRA;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            ADD.instruct_compare: begin 
                instruction_type = ADD.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_ADD;
                alua_sel = alua_adata;
                alub_sel = alub_bdata;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            SUB.instruct_compare: begin 
                instruction_type = SUB.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_SUB;
                alua_sel = alua_adata;
                alub_sel = alub_bdata;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            SLL.instruct_compare: begin 
                instruction_type = SLL.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_SLL;
                alua_sel = alua_adata;
                alub_sel = alub_bdata;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            SLT.instruct_compare: begin 
                instruction_type = SLT.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_SLT;
                alua_sel = alua_adata;
                alub_sel = alub_bdata;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            SLTU.instruct_compare: begin 
                instruction_type = SLTU.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_SLT;
                alua_sel = alua_adata;
                alub_sel = alub_bdata;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            XOR_.instruct_compare: begin 
                instruction_type = XOR_.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_XOR;
                alua_sel = alua_adata;
                alub_sel = alub_bdata;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            SRL.instruct_compare: begin 
                instruction_type = SRL.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_SRL;
                alua_sel = alua_adata;
                alub_sel = alub_bdata;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            SRA.instruct_compare: begin 
                instruction_type = SRA.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_SRA;
                alua_sel = alua_adata;
                alub_sel = alub_bdata;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            OR_.instruct_compare: begin 
                instruction_type = OR_.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_OR;
                alua_sel = alua_adata;
                alub_sel = alub_bdata;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            AND_.instruct_compare: begin 
                instruction_type = AND_.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_AND;
                alua_sel = alua_adata;
                alub_sel = alub_bdata;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end
            CSRRW.instruct_compare: begin
                instruction_type = CSRRW.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_csr;
                csr_sel = csr_csrrw;
                csr_data_sel = csr_rs1_sel;
            end
            CSRRS.instruct_compare: begin
                instruction_type = CSRRS.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_csr;
                csr_sel = csr_csrrs;
                csr_data_sel = csr_rs1_sel;
            end
            CSRRC.instruct_compare: begin
                instruction_type = CSRRC.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_csr;
                csr_sel = csr_csrrc;
                csr_data_sel = csr_rs1_sel;
            end
            CSRRWI.instruct_compare: begin
                instruction_type = CSRRWI.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_csr;
                csr_sel = csr_csrrw;
                csr_data_sel = csr_uimm_sel;
            end
            CSRRSI.instruct_compare: begin
                instruction_type = CSRRWI.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_csr;
                csr_sel = csr_csrrs;
                csr_data_sel = csr_uimm_sel;
            end
            CSRRCI.instruct_compare: begin
                instruction_type = CSRRCI.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_csr;
                csr_sel = csr_csrrc;
                csr_data_sel = csr_uimm_sel;
            end
            default: begin
                instruction_type = NA;
                
            end
        endcase
            
        
        
    end
    
    
    
    
endmodule
