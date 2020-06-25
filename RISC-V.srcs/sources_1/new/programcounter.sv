`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2020 01:36:45 PM
// Design Name: 
// Module Name: programcounter
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

//currently ram stores all half words and bytes in each full word and does not do byte memory as risc wants

module programcounter(input clk, enable, reset_n, modify_pc,
                        input int modified_pc,
                        output int program_counter
                        );
    
    localparam pc_increment = 2;//change to 4 when ram stores in blocks of 8 bits
    
    int next_pc;
    
    assign next_pc = program_counter + pc_increment;
    
    always_ff @ (posedge clk) begin
        if (~reset_n) begin
            program_counter <= 0;
        end else if( enable) begin
            if(modify_pc) begin
                program_counter <= modified_pc;
            end else begin
                program_counter <= next_pc;
            end
        end
    end

endmodule