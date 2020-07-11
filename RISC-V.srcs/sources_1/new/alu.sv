`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2020 01:36:45 PM
// Design Name: 
// Module Name: alu
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

module alu( input int adata, bdata,
            input [ALU_INSTRUCTION_COUNT-1:0] instruction_select,
            output int result           
            );
    
    
    always_comb begin
        result = 0;
        case(instruction_select)
            alu_AND : #1ps result = adata & bdata;
            alu_ADD : #1ps result = adata + bdata; 
            alu_OR : #1ps result = adata | bdata;
            alu_SLL : #1ps result = adata << bdata[4:0];
            alu_SRL : #1ps result = adata >> bdata[4:0];
            alu_XOR : #1ps result = adata ^ bdata;
            alu_SRA : #1ps result = adata >>> bdata[4:0];
            alu_SUB : #1ps result = adata - bdata;
            alu_SLLU : #1ps result = $unsigned(adata) >> $unsigned(bdata[4:0]);
            alu_SRLU : #1ps result = $unsigned(adata) << $unsigned(bdata[4:0]);
            alu_SLT : #1ps result = $signed(adata) < $signed(bdata);
            alu_SLTU : #1ps result = $unsigned(adata) < $unsigned(bdata); 
            alu_LOAD_IMM_2_A : #1ps result = {bdata[31:12],12'b0};//return the 20 bits from imm as the highest and fill the rest with zero
            'b0 : #1ps result = 'b0; // default no operation state
            default: begin
                result = 'bx;
//                $error("ALU received invalid instruction selection");
            end
        
        endcase
    end
endmodule