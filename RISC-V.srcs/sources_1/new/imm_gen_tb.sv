`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2020 08:40:29 AM
// Design Name: 
// Module Name: imm_gen
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

module imm_gen_tb();
    
    logic clk;
    logic [ISA_TYPE_COUNT-1:0] isa_type;
    int instruction, result;
    imm_gen dut (.isa_type(isa_type),
                .instruction(instruction),
                .result(result)
    );
    
    /*
    imm_gen_20_20_1 : #1ps result = {{11{1'b1}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
    imm_gen_20_high : #1ps result = {instruction[31:12], 12'b0};
    imm_gen_12_low_signed : #1ps result = {{21{instruction[31]}}, instruction[30:20]};
    imm_gen_12_12_1_signed
    */
    
    initial begin
        clk = 0;
        isa_type = J;
        instruction = 'b1_1010101010_0_01010101_xxxxx_xxxxxxx;// j type
        
        `cycle(1)
        assert(result == 'b11111111111_101010101010101010100)
        else $error("Imm_gen_J returned the wrong result, %b (expected %b)", result,'b11111111111_101010101010101010100); 
        
        isa_type = U;
        instruction = 'b10101010101010101010_xxxxx_xxxxxxx;// u type
        
        `cycle(1)
        assert(result == 'b10101010101010101010_000000000000)
        else $error("Imm_gen_U returned the wrong result, %b (expected %b)", result,'b10101010101010101010_000000000000);
        
        isa_type = I;
        instruction = 'b101010101010_xxxxxxxxxx_xxxxxxxxxx;// i type
        
        `cycle(1)
        assert(result == 'b1111111111_1111111111_101010101010)
        else $error("Imm_gen_I returned the wrong result, %b (expected %b)", result,'b1111111111_1111111111_101010101010); 
        
        isa_type = S;
        instruction = 'b1010101_xxxxx_xxxxx_xxx_01010_xxxxxxx;// s type
        
        `cycle(1)
        assert(result == 'b1111111111_1111111111_101010101010)
        else $error("Imm_gen_S returned the wrong result, %b (expected %b)", result,'b1111111111_1111111111_101010101010);
        
        isa_type = B;
        instruction = 'b1_101010_xxxxx_xxxxx_xxx_1010_0_xxxxxxx;// b type
        
        `cycle(1)
        assert(result == 'b1111111111_111111111_101010101010_0)
        else $error("Imm_gen_B returned the wrong result, %b (expected %b)", result,'b1111111111_111111111_101010101010_0);
        
        $stop;
    end
    
    always
        #5ps clk = ~clk;
    
endmodule