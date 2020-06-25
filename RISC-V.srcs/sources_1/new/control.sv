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






instruct_template LUI = '{32'b???????_?????_?????_???_?????_0110111, U/*, "LUI"*/};
instruct_template AUIPC = '{32'b???????_?????_?????_???_?????_0010111, U/*, "AUIPC"*/};
instruct_template JAL = '{32'b???????_?????_?????_???_?????_1101111, J/*, "JAL"*/};
instruct_template JALR = '{32'b???????_?????_?????_000_?????_1100111, I/*, "JALR"*/};
instruct_template BEQ = '{32'b???????_?????_?????_000_?????_1100011, B/*, "BEQ"*/};
instruct_template BNE = '{32'b???????_?????_?????_001_?????_1100011, B/*, "BNE"*/};
instruct_template BLT = '{32'b???????_?????_?????_100_?????_1100011, B/*, "BLT"*/};
instruct_template BGE = '{32'b???????_?????_?????_101_?????_1100011, B/*, "BGE"*/};
instruct_template BLTU = '{32'b???????_?????_?????_110_?????_1100011, B/*, "BLTU"*/};
instruct_template BGEU = '{32'b???????_?????_?????_111_?????_1100011, B/*, "BGEU"*/};
instruct_template LB = '{32'b???????_?????_?????_000_?????_0000011, I/*, "LB"*/};
instruct_template LH = '{32'b???????_?????_?????_001_?????_0000011, I/*, "LH"*/};
instruct_template LW = '{32'b???????_?????_?????_010_?????_0000011, I/*, "LW"*/};
instruct_template LBU = '{32'b???????_?????_?????_100_?????_0000011, I/*, "LBU"*/};
instruct_template LHU = '{32'b???????_?????_?????_101_?????_0000011, I/*, "LHU"*/};
instruct_template SB = '{32'b???????_?????_?????_000_?????_0100011, S/*, "SB"*/};
instruct_template SH = '{32'b???????_?????_?????_001_?????_0100011, S/*, "SH"*/};
instruct_template SW = '{32'b???????_?????_?????_010_?????_0100011, S/*, "SW"*/};
instruct_template ADDI = '{32'b???????_?????_?????_000_?????_0010011, I/*, "ADDI"*/};
instruct_template SLTI = '{32'b???????_?????_?????_010_?????_0010011, I/*, "SLTI"*/};
instruct_template SLTIU = '{32'b???????_?????_?????_011_?????_0010011, I/*, "SLTIU"*/};
instruct_template XORI = '{32'b???????_?????_?????_100_?????_0010011, I/*, "XORI"*/};
instruct_template ORI = '{32'b???????_?????_?????_110_?????_0010011, I/*, "ORI"*/};
instruct_template ANDI = '{32'b???????_?????_?????_111_?????_0010011, I/*, "ANDI"*/};
instruct_template SLLI = '{32'b0000000_?????_?????_001_?????_0010011, I/*, "SLLI"*/};
instruct_template SRLI = '{32'b0000000_?????_?????_101_?????_0010011, I/*, "SRLI"*/};
instruct_template SRAI = '{32'b0100000_?????_?????_111_?????_0010011, I/*, "SRAI"*/};
instruct_template ADD = '{32'b0000000_?????_?????_000_?????_0110011, I/*, "ADD"*/};
instruct_template SUB = '{32'b0100000_?????_?????_000_?????_0110011, I/*, "SUB"*/};
instruct_template SLL = '{32'b0000000_?????_?????_001_?????_0110011, I/*, "SLL"*/};
instruct_template SLT = '{32'b0000000_?????_?????_010_?????_0110011, I/*, "SLT"*/};
instruct_template SLTU = '{32'b0000000_?????_?????_011_?????_0110011, I/*, "SLTU"*/};
instruct_template XOR_ = '{32'b0000000_?????_?????_100_?????_0110011, I/*, "XOR"*/};
instruct_template SRL = '{32'b0000000_?????_?????_101_?????_0110011, I/*, "SRL"*/};
instruct_template SRA = '{32'b0100000_?????_?????_101_?????_0110011, I/*, "SRA"*/};
instruct_template OR_ = '{32'b0000000_?????_?????_110_?????_0110011, I/*, "OR"*/};
instruct_template AND_ = '{32'b0000000_?????_?????_111_?????_0110011, I/*, "AND"*/};    


module control( input reset_n, enable,
                input int instruction,
                input br_ne, br_lt, // branch != and <
                output logic [ALU_INSTRUCTION_COUNT-1:0] alu_sel, //alu selection
                output logic pc_wsel, //selects pc increment or jump
                output logic reg_wen, //enables register write
                output logic alua_sel, //selects pc or adata going to alu
                output logic alub_sel, //selects imm or bdata going to alu
                output logic dram_wsel, //enables write to dram
                output logic [1:0] reg_wdata_sel, //selects between dram_output, alu_output, and pc
                output logic [1:0] imm_gen_sel, //selects the imm sign extension
                output logic decode_error //goes high when instruction did not match known instructions
    );
    
    
    logic [5:0] instruction_type;
    
    assign decode_error = instruction_type == NA ? 1 : 0;


    
    
    always_comb begin
        //route info according to the instruction type
        
        alu_select = alu_NA;
        pc_wsel = pc_increment; //depends on instruction
        reg_wen = reg_write_noten; //depends on r, i
        alua_sel = alua_adata;
        alub_sel = alub_bdata;
        dram_wsel = dram_write_noten;
        reg_wdata_sel = reg_write_alu;

        //determines instruction type and enables instruction flag relative to instruction
        case(instruction) //: intruction_to_type_decoding
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
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_ADD;
                alua_sel = alua_pc;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
            end            
            JALR.instruct_compare:  begin 
                instruction_type = JALR.isa_type;
                reg_wen = reg_write_en;
                reg_wdata_sel = reg_write_alu;
                alu_select = alu_ADD;
                alua_sel = alua_adata;
                alub_sel = alub_imm;
                dram_wsel = dram_write_noten;
                pc_wsel = pc_increment;
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
            default: begin
                instruction_type = NA;
                
            end
        endcase
            
        
        
    end
    
    
    
    
endmodule
