`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2020 01:36:45 PM
// Design Name: 
// Module Name: alu_tb
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

`define cycle(count) \
    repeat (count) @ (posedge clk); \
    #1ps;

module alu_tb();
    
    logic clk;
    logic [ALU_INSTRUCTION_COUNT-1:0] instruction_select;
    int result, adata, bdata;
    
    alu dut(.adata(adata), .bdata(bdata),
            .instruction_select(instruction_select),
            .result(result)           
            );
            
    int increment_a = $urandom_range(10000,1);
    int increment_b = $urandom_range(10000,1);
    
    initial begin
        clk = 0;
        adata = 0;
        bdata = 0;
        instruction_select = 0;
        
        `cycle(1);
        
        //test addition
        instruction_select = alu_ADD;
        for(int a = -100000; a < 100000 ; a += increment_a) begin
            adata = a;
            for(int b = -100000; b < 100000 ; b += increment_b) begin
                bdata = b;
                `cycle(1);
                assert (result == (a + b))
                else $error("alu_ADD failed with %d + %d equaling %d instead of %d",a , b, result, a+b);
            end
        end
        
        //test and
        instruction_select = alu_AND;
        for(int a = -100000; a < 100000 ; a += increment_a) begin
            adata = a;
            for(int b = -100000; b < 100000 ; b += increment_b) begin
                bdata = b;
                `cycle(1);
                assert (result == (a & b))
                else $error("alu_AND failed with %d & %d equaling %d instead of %d",a , b, result, a&b);
            end
        end   
        
        //test or
        instruction_select = alu_OR;
        for(int a = -100000; a < 100000 ; a += increment_a) begin
            adata = a;
            for(int b = -100000; b < 100000 ; b += increment_b) begin
                bdata = b;
                `cycle(1);
                assert (result == (a | b))
                else $error("alu_OR failed with %d | %d equaling %d instead of %d",a , b, result, a|b);
            end
        end 
        
        //test xor
        instruction_select = alu_XOR;
        for(int a = -100000; a < 100000 ; a += increment_a) begin
            adata = a;
            for(int b = -100000; b < 100000 ; b += increment_b) begin
                bdata = b;
                `cycle(1);
                assert (result == (a ^ b))
                else $error("alu_XOR failed with %d ^ %d equaling %d instead of %d",a , b, result, a^b);
            end
        end
        
        //test sub
        instruction_select = alu_SUB;
        for(int a = -100000; a < 100000 ; a += increment_a) begin
            adata = a;
            for(int b = -100000; b < 100000 ; b += increment_b) begin
                bdata = b;
                `cycle(1);
                assert (result == (a - b))
                else $error("alu_SUB failed with %d - %d equaling %d instead of %d",a , b, result, a - b);
            end
        end
        
        //test slt
        instruction_select = alu_SLT;
        for(int a = -100000; a < 100000 ; a += increment_a) begin
            adata = a;
            for(int b = -100000; b < 100000 ; b += increment_b) begin
                bdata = b;
                `cycle(1);
                assert (result == ($signed(a) < $signed(b)))
                else $error("alu_SLT failed with %d SLT %d equaling %d instead of %d",a , b, result, ($signed(a) < $signed(b)));
            end
        end
        
        //test sltu
        instruction_select = alu_SLTU;
        for(int a = -100000; a < 100000 ; a += increment_a) begin
            adata = a;
            for(int b = -100000; b < 100000 ; b += increment_b) begin
                bdata = b;
                `cycle(1);
                assert (result == (a < b))
                else $error("alu_SLTU failed with %d SLTU %d equaling %d instead of %d",a , b, result, a < b);
            end
        end
        
        
        $stop;
        // load_imm_2_a
        //sll, slr, sra, sllu, srlu, 
    end
    
    always
        #5ps clk = ~clk;
    
    
            
endmodule