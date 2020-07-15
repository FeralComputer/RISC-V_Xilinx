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
import risc_structs::*;

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
        blt_prog[5] = `LUI_corrected(x2, compare_val);// set x2 to compare value
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
    
    task csr_and_timers_test();
        // program tests the csr and timers
        // x1 contains value to compare against rdtime which is then stored
        // x10 contains value to be written into csr_test
        // x11 contains mask to set bits in csr_test
        // x12 contains maks to clear bits in csr_test 
        static int write_x1 = 'd1245;
        static int test_mem_rw = 20;
        static int test_val_rw = 'haaaa_aaaa;
        static int test_mem_rs = 24;
        static int test_mask_rs = 'h0000_ffff;
        static int test_mem_rc = 28;
        static int test_mask_rc = 'hffff_0000;
        static int test_mem_rdcycle = 32;
        static int test_mem_rdinstret = 36;
        static int test_mem_rdtimer = 40;
        static int read_value;
        localparam PROG_LENGTH = 24;
        int prog[PROG_LENGTH];
        prog[0] = `LUI_corrected(x1, write_x1); //load x1 with compare value to leave loop 
        prog[1] = `ADDI(x1, x1, write_x1);
        prog[2] = `LUI_corrected(x10, test_val_rw); //load value to be loaded into csr_test
        prog[3] = `ADDI(x10, x10, test_val_rw);
        prog[4] = `LUI_corrected(x11, test_mask_rs); //load mask for csrrs test
        prog[5] = `ADDI(x11, x11, test_mask_rs);
        prog[6] = `LUI_corrected(x12, test_mask_rc); //load mask for csrrc test
        prog[7] = `ADDI(x12, x12, test_mask_rc);
        prog[8] = `CSRRW(x13, x10, CSR_TEST); //load value in x10 into csr_test and write original into x13
        prog[9] = `CSRRS(x13, x11, CSR_TEST); //mask csr_test with value in x11 and write rw result into x13
        prog[10] = `SW(x0, x13, test_mem_rw); //store rw result into memory
        prog[11] = `CSRRC(x13, x12, CSR_TEST); //mask csr_test with value in x12 and write rs result into x13
        prog[12] = `SW(x0, x13, test_mem_rs); //store rs result into memory
        prog[13] = `CSRRC(x13, x0, CSR_TEST); //mask csr_test with x0 as to not modify and write rc result into x13
        prog[14] = `SW(x0, x13, test_mem_rc); //store rc result into memory
        prog[15] = `CSRRS(x13, x0, CSR_RDCYCLE); //put cycle count into x13
        prog[16] = `SW(x0, x13, test_mem_rdcycle); //store cycle count into memory
        prog[17] = `CSRRS(x13, x0, CSR_RDINSTRET); //put instret count into x13
        prog[18] = `SW(x0, x13, test_mem_rdinstret); //store instret into memory
        prog[19] = `ADD_(x0, x0, x0); //nop
        prog[20] = `ADD_(x0, x0, x0); //nop
        prog[21] = `CSRRS(x13, x0, CSR_RDTIMER); //store timer into x13
        prog[22] = `SW(x0, x13, test_mem_rdtimer); //store timer into memory
        prog[23] = 32'hffff_ffff;

        for(int i = 0; i < PROG_LENGTH; i += 1) begin
            $display("Instruction %d: %b", i, prog[i]);
            SET_INSTRUCTION(prog[i], 4*i);
        end
        $display("Running CSR and timer test");
        enable = 1;
        
        while(prog_count < PROG_LENGTH * 4) begin
            `cycle(1);
            #1ps; //need this or vivado becomes angry
        end
        $display("End Running... pc: %d", prog_count);
        
        enable = 0;

        GET_DRAM_VALUE(test_mem_rw, read_value);
        assert(read_value == test_val_rw) $display("CSRRW assert success with %d", read_value);
        else $display("CSRRW assert failed expected: %d received: %d", test_val_rw, read_value);

        GET_DRAM_VALUE(test_mem_rs, read_value);
        assert(read_value == test_mask_rs | test_val_rw) $display("CSRRS assert success with %d", read_value);
        else $display("CSRRS assert failed expected: %d received: %d", test_mask_rs | test_val_rw, read_value);

        GET_DRAM_VALUE(test_mem_rc, read_value);
        assert(read_value == ~test_mask_rc & (test_mask_rs | test_val_rw)) $display("CSRRC assert success with %d", read_value);
        else $display("CSRRC assert failed expected: %d received: %d", ~test_mask_rc & (test_mask_rs | test_val_rw), read_value);

        GET_DRAM_VALUE(test_mem_rdcycle, read_value);
        assert(read_value == 15) $display("RDCYCLE assert success with %d", read_value);
        else $display("RDCYCLE assert failed expected: %d received: %d", 15, read_value);

        GET_DRAM_VALUE(test_mem_rdinstret, read_value);
        assert(read_value == 17) $display("RDINSTRET assert success with %d", read_value);
        else $display("RDINSTRET assert failed expected: %d received: %d", 17, read_value);

        GET_DRAM_VALUE(test_mem_rdtimer, read_value);
        assert(read_value == 2) $display("RDTIMER assert success with %d", read_value);
        else $display("RDTIMER assert failed expected: %d received: %d", 2, read_value);

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

        reset_n = 0;
        `cycle(1);
        
        reset_n = 1;
        
        `cycle(1);

        csr_and_timers_test();

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
