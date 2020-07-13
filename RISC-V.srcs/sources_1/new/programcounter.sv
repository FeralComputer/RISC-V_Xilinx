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

module programcounter(input clk, enable, reset_n, modify_pc,
                        input int modified_pc,
                        output int program_counter, next_program_counter
                        );
    
    localparam pc_increment = 4;
    
    int next_pc;
    
    assign #1ps next_pc = program_counter + pc_increment;
    
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