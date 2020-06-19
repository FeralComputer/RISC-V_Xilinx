`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2020 03:47:56 PM
// Design Name: 
// Module Name: control_tb
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


module control_tb(

    );
    
    logic clk, reset_n, enable, write_instruction;
    int write_instruct_addr, write_instruct_data;
    int data;

    control ctrl(clk, reset_n, enable, write_instruction,
                  write_instruct_addr, write_instruct_data, data );
endmodule
