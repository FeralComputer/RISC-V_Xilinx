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
import isa_gen::*;


`define cycle(count) \
    repeat (count) @ (posedge clk); \
    #1ps;
    
parameter write_data = {32{1'b1}};
parameter int save_pointer = 10;

module control_tb(

    );
    
    logic clk, reset_n, enable;
    int data;
    logic debug_enable_write_dram, debug_enable_write_iram;
    int debug_write_data_dram, debug_write_data_iram;
    int debug_write_addr_dram, debug_write_addr_iram;
    int debug_read_addr_dram, debug_read_addr_iram;
    int debug_read_data_dram, debug_read_data_iram;

    control ctrl(clk, reset_n, enable,
                debug_enable_write_dram, debug_enable_write_iram,
                debug_write_data_dram, debug_write_data_iram,
                debug_write_addr_dram, debug_write_addr_iram,
                debug_read_addr_dram, debug_read_addr_iram,
                debug_read_data_dram, debug_read_data_iram,
                data );
                  
    int load_program [6];// = '{
//        `AND_(x1, x0, x1)  //set x1 to 0
//        `AND_(x2, x0, x2), //set x2 to 0 to act as base for load and write
//        `LUI(x1, {20{'b1}}), //load uppermost 20 bits to x1
//        `ADDI(x1, x1, {12{'b1}} ), // add the lower 12 bits to x1
//        `SW(x2, x1, 10), //store x1 to 10 offset from x2
//        `LW(x3, x2, 10) //load data from 10 offset from x2 to x3
//     };

    initial begin
        load_program[0] = `AND_(x1, x0, x1);  //set x1 to 0
        load_program[1] = `AND_(x2, x0, x2); //set x2 to 0 to act as base for load and write
        load_program[2] = `LUI(x1, write_data); //load uppermost 20 bits to x1
        load_program[3] = `ADDI(x1, x1, write_data ); // add the lower 12 bits to x1
        load_program[4] = `SW(x2, x1, save_pointer); //store x1 to 10 offset from x2
        load_program[5] = `LW(x3, x2, save_pointer); //load data from 10 offset from x2 to x3
    
        clk = 0;
        reset_n = 0;
        enable = 0;
        debug_enable_write_iram = 0;
        debug_enable_write_dram = 0;
        `cycle(5);
    
        //write program into idata
        reset_n = 1;
        debug_enable_write_iram = 1;
        for(int i = 0; i < 6; i += 1) begin
            debug_write_addr_iram = i;
            debug_write_data_iram = load_program[i];
            
            `cycle(1);
        end
        debug_enable_write_iram = 0;
        
        `cycle(1);
        enable = 1;
        
        `cycle(20);
        
        $stop;
        
             
    end
    
    always
        #5ps clk = ~clk;
endmodule
