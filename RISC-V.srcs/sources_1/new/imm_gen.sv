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

module imm_gen(input logic [ISA_TYPE_COUNT-1:0] isa_type,
                input int instruction,
                output int result
    );
    
    //creates immediate depending on the instruction (might be worth while to change this to be dependant on the isa type
    always_comb begin
        
        case(isa_type)
            J : #1ps result = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            U : #1ps result = {instruction[31:12], 12'b0};
            I : #1ps result = {{21{instruction[31]}}, instruction[30:20]};
            B: #1ps result = {{20{instruction[31]}}, instruction[7],  instruction[30:25], instruction[11:8], 1'b0};
            S: #1ps result = {{21{instruction[31]}}, instruction[30:25], instruction[11:7]};
            default: #1ps result = 32'bx;
        endcase
    end

endmodule
