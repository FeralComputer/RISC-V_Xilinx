`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2020 08:12:45 AM
// Design Name: 
// Module Name: core_tb
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
   
`define DEBUG = 1;

localparam int PROGRAM_LENGTH = 6;
localparam int BLT_PROG_LEN = 15;
localparam int write_data = {32{1'b1}};
localparam int save_pointer = 10;

module core_tb(

    );
    logic clk, reset_n, enable;
    logic debug_enable_write_iram, debug_enable_write_dram;
    int debug_read_addr_iram, debug_read_addr_dram;
    int debug_write_addr_iram, debug_write_addr_dram;
    int debug_write_data_iram, debug_write_data_dram;
    int dram_dob, instruction, prog_count;
    logic decode_error;
    
    core dut (.clk(clk), .reset_n(reset_n), .enable(enable),
            .debug_enable_write_iram(debug_enable_write_iram), .debug_enable_write_dram(debug_enable_write_dram),
            .debug_read_addr_iram(debug_read_addr_iram), .debug_read_addr_dram(debug_read_addr_dram),
            .debug_write_addr_iram(debug_write_addr_iram), .debug_write_addr_dram(debug_write_addr_dram),
            .debug_write_data_iram(debug_write_data_iram), .debug_write_data_dram(debug_write_data_dram),
            .dram_dob(dram_dob), .instruction(instruction), .program_counter(prog_count),
            .decode_error(decode_error)
            );

        
        int load_program [6];
    
    int read_value;

    int init_increment = 0;
    int compare_value = 20;
    int inc_amount = 1;
    int shift_amount = 1;
    int jump_to_end = 5;
    int jump_amount = -8;
    int mem_inc = 4;
    
    //write instruction into iram
    task SET_INSTRUCTION(input int instruction, address);
        enable = 0;
        debug_enable_write_iram = 1;
        debug_write_addr_iram = address;
        debug_write_data_iram = instruction;
        `cycle(1);
        debug_enable_write_iram = 0;
    endtask
    
    //read value from dram
    task GET_DRAM_VALUE(input int address, output int data);
        enable = 0;
        debug_read_addr_dram = address;
        `cycle(1);
        data = dram_dob;
    endtask
    
    //write value to dram
    task SET_DRAM_VALUE(input int address, data);
        enable = 0;
        debug_enable_write_dram = 1;
        debug_write_addr_dram = address;
        debug_write_data_dram = data;
        `cycle(1);
        debug_enable_write_dram = 0;
    endtask
    
    task TEST_FOR_LOOP(input int compare_val, initial_val, increment_val, save_pointer);
        int blt_prog[BLT_PROG_LEN];
        static int jump_val = -16, mem_val =4, jump_end_val = 10 ;
        
        // x1 = increment, x2 = compare, x3 = increment amount, x4 = result of operation inside loop
        blt_prog[0] = `AND_(x1, x0, x1);// set x1 to 0
        blt_prog[1] = `AND_(x2, x0, x2);// set x2 to 0
        blt_prog[2] = `AND_(x3, x0, x3);// set x3 to 0
        blt_prog[3] = `ADDI(x4, x0, increment_val);// set x4 to 0
        blt_prog[4] = `ADDI(x1, x1, initial_val);// set x1 to initial value
        blt_prog[5] = `LUI(x2, compare_val);// set x2 to compare value
        blt_prog[6] = `ADDI(x2, x2, compare_val);
        blt_prog[7] = `ADDI(x3, x3, increment_val);// set x3 to increment amount
        blt_prog[8] = `BLT(x2, x1, jump_end_val);// check condition
        blt_prog[9] = `SLL(x5, x4, x1);// run something
        blt_prog[10] = `SW(x6, x5, save_pointer);// store value in dram to be checked by assert
        blt_prog[11] = `ADDI(x6, x6, mem_val); //increment memory pointer by 4
        blt_prog[12] = `ADD_(x1, x3, x1);// increment increment
        blt_prog[13] = `BLT(x1, x2, jump_val);// check branch condition
        blt_prog[14] = 'hffff_ffff;// end
        
        for(int i = 0; i < BLT_PROG_LEN; i += 1) begin
            $display("Instruction %d: %b", i, blt_prog[i]);
            SET_INSTRUCTION(blt_prog[i], 4*i);
        end
        $display("Running BLT prog test");
        enable = 1;
        
        while(prog_count < 14 * 4) begin
            `cycle(1);
            #1ps;
        end
        $display("End Running... pc: %d", prog_count);
        
        enable = 0;

        for(int i = 0; i < (compare_val - initial_val)/increment_val * 4; i+= 4) begin
            GET_DRAM_VALUE(i+save_pointer, read_value);
            assert(read_value == ('b1 << (i/4))) $display("BLT PROG assert success with %d", read_value);
            else $display("BLT PROG assert failed expected: %d received: %d", ('b1 << (i/4)),read_value);
        end
    endtask
            
    initial begin
        
        $display("Program to binary:");
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
        
        `cycle(1);
        
        reset_n = 1;
        
        //load program
        `cycle(1);
        
        TEST_FOR_LOOP(20,0,1,10);

        //validating read and write from dram
        $display("Attempt to read and write from dram");
        SET_DRAM_VALUE(20, 'haaaa_aaaa);
        GET_DRAM_VALUE(20, read_value);
        assert(read_value == 'haaaa_aaaa) $display("Set and Get dram succeeded");
        else $display("Set and Get dram failed with %d sent and %d received", 'haaaa_aaaa, read_value);
        
        `cycle (1);
        
        $display("Run core");
        enable = 1;
        
        `cycle(7);
        $stop;
        
        
    end
    
    always
        #5ps clk = ~clk;
endmodule
