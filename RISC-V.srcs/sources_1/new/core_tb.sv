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

// automate error and pass messages
// error message format is "[operation]" and will result in "[operation] assert failed expected [expected_value] got [actual_value]"
// pass message format it "[operation]" and will result it "[operation] assert passed with [actual_value]"
`define assert_test(actual_value, expected_value, error_message, pass_message, error_count) \
    assert(actual_value == expected_value) $display("%s assert passed with %0d", pass_message, actual_value); \
    else begin \
        $display("%s assert failed expected %0d got %0d", error_message, expected_value, actual_value); \
        error_count += 1; \
    end
   
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
        // program tests the csr and timers: csrrw, csrrs, csrrc, csrrwi, csrrsi, csrrci
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
        static int test_mem_rwi = 44;
        static int test_mem_rsi = 48;
        static int test_mem_rci = 52;
        static int test_imm_rw = 'h0000_000a;
        static int test_imm_rs = 'h0000_0003;
        static int test_imm_rc = 'h0000_000c;
        static int error_count = 0;
        static int read_value;
        localparam PROG_LENGTH = 31;
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
        prog[23] = `CSRRWI(x0, test_imm_rw, CSR_TEST); //write immediate to csr_test
        prog[24] = `CSRRSI(x13, test_imm_rs, CSR_TEST); //set imm to csr_test
        prog[25] = `SW(x0, x13, test_mem_rwi); //store immediate write result
        prog[26] = `CSRRCI(x13, test_imm_rc, CSR_TEST); //clear imm to csr_test
        prog[27] = `SW(x0, x13, test_mem_rsi); //store imm set result
        prog[28] = `CSRRC(x13, x0, CSR_TEST); //clear x0 and get imm clear result
        prog[29] = `SW(x0, x13, test_mem_rci); //store imm clear result
        prog[30] = 32'hffff_ffff;

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
        else begin
            $display("CSRRW assert failed expected: %d received: %d", test_val_rw, read_value);
            error_count += 1;
        end

        GET_DRAM_VALUE(test_mem_rs, read_value);
        `assert_test(read_value, test_mask_rs | test_val_rw, "CSRRS", "CSRRS", error_count);

        GET_DRAM_VALUE(test_mem_rc, read_value);
        assert(read_value == ~test_mask_rc & (test_mask_rs | test_val_rw)) $display("CSRRC assert success with %d", read_value);
        else begin
            $display("CSRRC assert failed expected: %d received: %d", ~test_mask_rc & (test_mask_rs | test_val_rw), read_value);
            error_count += 1;
        end

        GET_DRAM_VALUE(test_mem_rdcycle, read_value);
        assert(read_value == 15) $display("RDCYCLE assert success with %d", read_value);
        else begin
            $display("RDCYCLE assert failed expected: %d received: %d", 15, read_value);
            error_count += 1;
        end

        GET_DRAM_VALUE(test_mem_rdinstret, read_value);
        assert(read_value == 17) $display("RDINSTRET assert success with %d", read_value);
        else begin
            $display("RDINSTRET assert failed expected: %d received: %d", 17, read_value);
            error_count += 1;
        end

        GET_DRAM_VALUE(test_mem_rdtimer, read_value);
        assert(read_value == 2) $display("RDTIMER assert success with %d", read_value);
        else begin
            $display("RDTIMER assert failed expected: %d received: %d", 2, read_value);
            error_count += 1;
        end

        GET_DRAM_VALUE(test_mem_rwi, read_value);
        assert(read_value == test_imm_rw) $display("CSRRWI assert success with %d", read_value);
        else begin
            $display("CSRRWI assert failed expected: %d received: %d", test_imm_rw, read_value);
            error_count += 1;
        end

        GET_DRAM_VALUE(test_mem_rsi, read_value);
        assert(read_value == test_imm_rs | test_imm_rw) $display("CSRRSI assert success with %d", read_value);
        else begin
            $display("CSRRSI assert failed expected: %d received: %d", test_imm_rs | test_imm_rw, read_value);
            error_count += 1;
        end

        GET_DRAM_VALUE(test_mem_rci, read_value);
        assert(read_value == (~test_imm_rc & (test_imm_rs | test_imm_rw))) $display("CSRRCI assert success with %d", read_value);
        else begin
            $display("CSRRCI assert failed expected: %d received: %d", ~test_imm_rc & (test_imm_rs | test_imm_rw), read_value);
            error_count += 1;
        end

        if(error_count > 0) $error("CSR and Timer test failed %0d times", error_count);
        else $display("PASS: CSR and Timer test");
        
    endtask
    
    
    
    //branch test: beq, bne, blt, bge, bltu, bgeu
    task branch_test();
        // x1 contains value to compare against x2, x3
        // x2 contains value to compare against x1, x3
        // x3 contains value to compare against x1, x2
        // x4 contains value to write to regs for a success
        // x5 contains value to write to regs for a failure
        static int write_x1 = 'haaaa_aaaa;
        static int write_x2 = 'h0aaa_aaaa;
        static int write_x3 = 'haaaa_aaaa;
        static int bne_addr_valid = 20;
        static int beq_addr_valid = 24;
        static int blt_addr_valid = 28;
        static int bge_addr_valid = 32;
        static int bltu_addr_valid = 36;
        static int bgeu_addr_valid = 40;
        static int bne_addr_invalid = 44;
        static int beq_addr_invalid = 48;
        static int blt_addr_invalid = 52;
        static int bge_addr_invalid = 56;
        static int bltu_addr_invalid = 60;
        static int bgeu_addr_invalid = 64;
        static int error_count = 0;
        static int success_value = 'haaaa_aaaa;
        static int fail_value = 'h5555_5555;
        static int branch_success = 12;
        static int branch_fail = 8;
        static int read_value;
        localparam PROG_LENGTH = 58;
        int prog[PROG_LENGTH];
        prog[0] = `LUI_corrected(x1, write_x1); //load x1 compare value
        prog[1] = `ADDI(x1, x1, write_x1);
        prog[2] = `LUI_corrected(x2, write_x2); //load x2 compare value
        prog[3] = `ADDI(x2, x2, write_x2);
        prog[4] = `LUI_corrected(x3, write_x3); //load x3 compare value
        prog[5] = `ADDI(x3, x3, write_x3);
        prog[6] = `LUI_corrected(x4, success_value); //load x4 with success value
        prog[7] = `ADDI(x4, x4, success_value);
        prog[8] = `LUI_corrected(x5, fail_value); //load x5 with fail value
        prog[9] = `ADDI(x5, x5, fail_value);

        prog[10] = `BEQ(x1, x3, branch_success); //test valid beq
        prog[11] = `SW(x0, x5, beq_addr_valid); //store fail in beq
        prog[12] = `JAL(x0, branch_fail); //jump to next test
        prog[13] = `SW(x0, x4, beq_addr_valid); //store pass in beq if branched

        prog[14] = `BEQ(x1, x2, branch_success); //test invalid beq
        prog[15] = `SW(x0, x4, beq_addr_invalid); //store pass
        prog[16] = `JAL(x0, branch_fail); //jump to next test
        prog[17] = `SW(x0, x5, beq_addr_invalid); //store fail if branched

        prog[18] = `BNE(x1, x2, branch_success); //test valid bne
        prog[19] = `SW(x0, x5, bne_addr_valid); //store fail 
        prog[20] = `JAL(x0, branch_fail); //jump to next test
        prog[21] = `SW(x0, x4, bne_addr_valid); //store pass

        prog[22] = `BNE(x1, x3, branch_success); //test invalid bne
        prog[23] = `SW(x0, x4, bne_addr_invalid); //store pass
        prog[24] = `JAL(x0, branch_fail); //jump to next test
        prog[25] = `SW(x0, x5, bne_addr_invalid); //store fail if branched

        prog[26] = `BLT(x1, x2, branch_success); //test valid blt
        prog[27] = `SW(x0, x5, blt_addr_valid); //store fail 
        prog[28] = `JAL(x0, branch_fail); //jump to next test
        prog[29] = `SW(x0, x4, blt_addr_valid); //store pass

        prog[30] = `BLT(x2, x1, branch_success); //test invalid blt
        prog[31] = `SW(x0, x4, blt_addr_invalid); //store pass
        prog[32] = `JAL(x0, branch_fail); //jump to next test
        prog[33] = `SW(x0, x5, blt_addr_invalid); //store fail if branched

        prog[34] = `BGE(x2, x1, branch_success); //test valid bge
        prog[35] = `SW(x0, x5, bge_addr_valid); //store fail 
        prog[36] = `JAL(x0, branch_fail); //jump to next test
        prog[37] = `SW(x0, x4, bge_addr_valid); //store pass

        prog[38] = `BGE(x1, x2, branch_success); //test invalid bge
        prog[39] = `SW(x0, x4, bge_addr_invalid); //store pass
        prog[40] = `JAL(x0, branch_fail); //jump to next test
        prog[41] = `SW(x0, x5, bge_addr_invalid); //store fail if branched

        prog[42] = `BLTU(x2, x1, branch_success); //test valid bltu
        prog[43] = `SW(x0, x5, bltu_addr_valid); //store fail 
        prog[44] = `JAL(x0, branch_fail); //jump to next test
        prog[45] = `SW(x0, x4, bltu_addr_valid); //store pass

        prog[46] = `BLTU(x1, x2, branch_success); //test invalid bltu
        prog[47] = `SW(x0, x4, bltu_addr_invalid); //store pass
        prog[48] = `JAL(x0, branch_fail); //jump to next test
        prog[49] = `SW(x0, x5, bltu_addr_invalid); //store fail if branched

        prog[50] = `BGEU(x1, x2, branch_success); //test valid bgeu
        prog[51] = `SW(x0, x5, bgeu_addr_valid); //store fail 
        prog[52] = `JAL(x0, branch_fail); //jump to next test
        prog[53] = `SW(x0, x4, bgeu_addr_valid); //store pass

        prog[54] = `BGEU(x2, x1, branch_success); //test invalid bgeu
        prog[55] = `SW(x0, x4, bgeu_addr_invalid); //store pass
        prog[56] = `JAL(x0, branch_fail); //jump to next test
        prog[57] = `SW(x0, x5, bgeu_addr_invalid); //store fail if branched

        for(int i = 0; i < PROG_LENGTH; i += 1) begin
            $display("Instruction %d: %b", i, prog[i]);
            SET_INSTRUCTION(prog[i], 4*i);
        end
        $display("Running Branch test");
        enable = 1;
        
        while(prog_count < PROG_LENGTH * 4) begin
            `cycle(1);
            #1ps; //need this or vivado becomes angry
        end
        $display("End Running... pc: %d", prog_count);
        
        enable = 0;

        GET_DRAM_VALUE(beq_addr_valid, read_value);
        `assert_test(read_value, success_value, "BEQ valid", "BEQ valid", error_count);

        GET_DRAM_VALUE(beq_addr_invalid, read_value);
        `assert_test(read_value, success_value, "BEQ invalid", "BEQ invalid", error_count);

        GET_DRAM_VALUE(bne_addr_valid, read_value);
        `assert_test(read_value, success_value, "BNE valid", "BNE valid", error_count);

        GET_DRAM_VALUE(bne_addr_invalid, read_value);
        `assert_test(read_value, success_value, "BNE invalid", "BNE invalid", error_count);

        GET_DRAM_VALUE(blt_addr_valid, read_value);
        `assert_test(read_value, success_value, "BLT valid", "BLT valid", error_count);

        GET_DRAM_VALUE(blt_addr_invalid, read_value);
        `assert_test(read_value, success_value, "BLT invalid", "BLT invalid", error_count);

        GET_DRAM_VALUE(bltu_addr_valid, read_value);
        `assert_test(read_value, success_value, "BLTU valid", "BLTU valid", error_count);

        GET_DRAM_VALUE(bltu_addr_invalid, read_value);
        `assert_test(read_value, success_value, "BLTU invalid", "BLTU invalid", error_count);

        GET_DRAM_VALUE(bge_addr_valid, read_value);
        `assert_test(read_value, success_value, "BGE valid", "BGE valid", error_count);

        GET_DRAM_VALUE(bge_addr_invalid, read_value);
        `assert_test(read_value, success_value, "BGE invalid", "BGE invalid", error_count);

        GET_DRAM_VALUE(bgeu_addr_valid, read_value);
        `assert_test(read_value, success_value, "BGEU valid", "BGEU valid", error_count);

        GET_DRAM_VALUE(bgeu_addr_invalid, read_value);
        `assert_test(read_value, success_value, "BGEU invalid", "BGEU invalid", error_count);
        
        if(error_count > 0) $error("Branch test failed %0d times", error_count);
        else $display("PASS: Branch test");

    endtask
    
    //load and store test: lb, lh, lw, lbu, lhu, sb, sh, sw
    task load_store_test();
        // addr1 and addr2 contain addresses of the value to be read from ram
        // x3 is used to load the value and is subsequently stored back in ram
        static int lsb1_1 = 20;//1-4 are used to read addrx + i to ensure each address works and not just steps of 4
        static int lsb2_1 = 24;
        static int lsb1_2 = 28;
        static int lsb2_2 = 32;
        static int lsb1_3 = 36;
        static int lsb2_3 = 40;
        static int lsb1_4 = 44;
        static int lsb2_4 = 48;
        static int lsbu1 = 68;
        static int lsbu2 = 72;
        static int lsh1_1 = 52;
        static int lsh2_1 = 56;
        static int lsh1_2 = 60;
        static int lsh2_2 = 64;
        static int lsw1 = 84;
        static int lsw2 = 88;
        static int lshu1 = 76;
        static int lshu2 = 80;
        static int error_count = 0;
        static int addr1 = 12;
        static int addr1_1 = 13;
        static int addr1_2 = 14;
        static int addr1_3 = 15;
        static int addr2 = 16;
        static int addr2_1 = 17;
        static int addr2_2 = 18;
        static int addr2_3 = 19;
        static int read_value;
        static int mem_inc = 4;
        static int clear_branch = -8;
        static int zero_offset = 0;
        static int expected = 'h0000_00aa;
        localparam PROG_LENGTH = 43;
        int prog[PROG_LENGTH];
        prog[0] = `AND_(x1, x1, x0);//clear x1 to act as itterator
        prog[1] = `LUI_corrected(x10,lsw2); //load compare value for itterator
        prog[2] = `ADDI(x10, x10, lsw2);
        prog[3] = `ADDI(x1, x1, lsb1_1); //load offset into itterator to reach lsb1_1
        prog[4] = `SW(x1, x0, zero_offset); //clear memory
        prog[5] = `ADDI(x1, x1, mem_inc); //increment itterator
        prog[6] = `BLT(x1, x10, clear_branch); //keep going until lsw2 has been zeroed

        prog[7] = `LB(x3, x0, addr1); //load byte from addr1
        prog[8] = `SB(x0, x3, lsb1_1); //store byte

        prog[9] = `LB(x3, x0, addr1_1);
        prog[10] = `SB(x0, x3, lsb1_2); //store byte 

        prog[11] = `LB(x3, x0, addr1_2);
        prog[12] = `SB(x0, x3, lsb1_3); //store byte 

        prog[13] = `LB(x3, x0, addr1_3);
        prog[14] = `SW(x0, x3, lsb1_4); //store byte 

        prog[15] = `LB(x3, x0, addr2);
        prog[16] = `SB(x0, x3, lsb2_1); //store byte 
        
        prog[17] = `LB(x3, x0, addr2_1);
        prog[18] = `SB(x0, x3, lsb2_2); //store byte 

        prog[19] = `LB(x3, x0, addr2_2);
        prog[20] = `SB(x0, x3, lsb2_3); //store byte 

        prog[21] = `LB(x3, x0, addr2_3);
        prog[22] = `SW(x0, x3, lsb2_4); //store byte 

        prog[23] = `LBU(x3, x0, addr1);// unsigned 
        prog[24] = `SW(x0, x3, lsbu1); //store byte 

        prog[25] = `LBU(x3, x0, addr2);
        prog[26] = `SW(x0, x3, lsbu2);

        prog[27] = `LH(x3, x0, addr1);// signed half words
        prog[28] = `SH(x0, x3, lsh1_1);

        prog[29] = `LH(x3, x0, addr1_2);
        prog[30] = `SW(x0, x3, lsh1_2);

        prog[31] = `LH(x3, x0, addr2);
        prog[32] = `SH(x0, x3, lsh2_1);

        prog[33] = `LH(x3, x0, addr2_2);
        prog[34] = `SW(x0, x3, lsh2_2);

        prog[35] = `LHU(x3, x0, addr1); //unsigned half words
        prog[36] = `SW(x0, x3, lshu1);

        prog[37] = `LHU(x3, x0, addr2);
        prog[38] = `SW(x0, x3, lshu2);

        prog[39] = `LW(x3, x0, addr1);
        prog[40] = `SW(x0, x3, lsw1);

        prog[41] = `LW(x3, x0, addr2);
        prog[42] = `SW(x0, x3, lsw2);


        SET_DRAM_VALUE(addr1, 'haaaa_aaaa);
        SET_DRAM_VALUE(addr2, 'h5555_5555);

        for(int i = 0; i < PROG_LENGTH; i += 1) begin
            $display("Instruction %d: %b", i, prog[i]);
            SET_INSTRUCTION(prog[i], 4*i);
        end
        $display("Running Load and Store test");
        enable = 1;
        
        while(prog_count < PROG_LENGTH * 4) begin
            `cycle(1);
            #1ps; //need this or vivado becomes angry
        end
        $display("End Running... pc: %d", prog_count);
        
        enable = 0;
        

        GET_DRAM_VALUE(lsb1_1, read_value);
        `assert_test(read_value, expected, "LSB1_1", "LSB1_1", error_count);

        GET_DRAM_VALUE(lsb1_2, read_value);
        `assert_test(read_value, expected, "LSB1_2", "LSB1_2", error_count);

        GET_DRAM_VALUE(lsb1_3, read_value);
        `assert_test(read_value, expected, "LSB1_3", "LSB1_3", error_count);

        expected = 'hffff_ffaa;
        GET_DRAM_VALUE(lsb1_4, read_value);
        `assert_test(read_value, expected, "LSB1_4", "LSB1_4", error_count);

        expected = 'h0000_0055;
        GET_DRAM_VALUE(lsb2_1, read_value);
        `assert_test(read_value, expected, "LSB2_1", "LSB2_1", error_count);

        GET_DRAM_VALUE(lsb2_2, read_value);
        `assert_test(read_value, expected, "LSB2_2", "LSB2_2", error_count);

        GET_DRAM_VALUE(lsb2_3, read_value);
        `assert_test(read_value, expected, "LSB2_3", "LSB2_3", error_count);

        expected = 'h0000_0055;
        GET_DRAM_VALUE(lsb2_4, read_value);
        `assert_test(read_value, expected, "LSB2_4", "LSB2_4", error_count);

        expected = 'h0000_00aa;
        GET_DRAM_VALUE(lsbu1, read_value);
        `assert_test(read_value, expected, "LSBU1", "LSBU1", error_count);

        expected = 'h0000_0055;
        GET_DRAM_VALUE(lsbu2, read_value);
        `assert_test(read_value, expected, "LSBU2", "LSBU2", error_count);

        expected = 'h0000_aaaa;
        GET_DRAM_VALUE(lsh1_1, read_value);
        `assert_test(read_value, expected, "LSH1_1", "LSH1_1", error_count);

        expected = 'hffff_aaaa;
        GET_DRAM_VALUE(lsh1_2, read_value);
        `assert_test(read_value, expected, "LSH1_2", "LSH1_2", error_count);

        expected = 'h0000_5555;
        GET_DRAM_VALUE(lsh2_1, read_value);
        `assert_test(read_value, expected, "LSH2_1", "LSH2_1", error_count);

        expected = 'h0000_5555;
        GET_DRAM_VALUE(lsh2_2, read_value);
        `assert_test(read_value, expected, "LSH2_2", "LSH2_2", error_count);

        expected = 'h0000_aaaa;
        GET_DRAM_VALUE(lshu1, read_value);
        `assert_test(read_value, expected, "LSHU1", "LSHU1", error_count);

        expected = 'h0000_5555;
        GET_DRAM_VALUE(lshu2, read_value);
        `assert_test(read_value, expected, "LSHU2", "LSHU2", error_count);

        expected = 'haaaa_aaaa;
        GET_DRAM_VALUE(lsw1, read_value);
        `assert_test(read_value, expected, "LSW1", "LSW1", error_count);

        expected = 'h5555_5555;
        GET_DRAM_VALUE(lsw2, read_value);
        `assert_test(read_value, expected, "LSW2", "LSW2", error_count);
        
        if(error_count > 0) $error("Load and Store test failed %0d times", error_count);
        else $display("PASS: Load and Store test");
    endtask

    //jump and pc test: jal, jalr, auipc
    task jump_pc_test();
        // jump forward with jal and write value, then jump backwards and write another value
        // then repeat with jalr
        static int jal_for = 40;
        static int jal_rev = -24;
        static int jalr_for = 4;
        static int jalr_rev = -24;
        static int jal_for_mem = 20;
        static int jal_rev_mem = 24;
        static int jalr_for_mem = 28;
        static int jalr_rev_mem = 32;
        static int jal_auipc = 60;
        static int auipc_for_offset = 'h0aaa_afff;
        static int auipc_rev_offset = 'hffff_f000;
        static int auipc_for_mem = 36;
        static int auipc_rev_mem = 40;
        static int error_count = 0;
        static int jal_for_expect = 4;
        static int jal_rev_expect = 48;
        static int jalr_for_expect = 28;
        static int jalr_rev_expect = 60;
        static int auipc_for_expect = 68 + (auipc_for_offset & 'hffff_f000);
        static int auipc_rev_expect = 76 + (auipc_rev_offset & 'hffff_f000);
        localparam PROG_LENGTH = 22;
        int prog[PROG_LENGTH];
        prog[0] = `JAL(x1, jal_for);// jump to pc = 40
        prog[1] = `SW(x0, x1, jalr_rev_mem);// store return value for jalr rev
        prog[2] = `JAL(x1, jal_auipc);// jump to test auipc
        prog[3] = 'hffff_ff03;
        prog[4] = 'hffff_ff04;
        prog[5] = `SW(x0, x1, jal_rev_mem); //store return value for jal rev
        prog[6] = `JALR(x1, x1, jalr_for); //jump relative to jal_rev
        prog[7] = 'hffff_ff07;
        prog[8] = 'hffff_ff08;
        prog[9] = 'hffff_ff09;

        prog[10] = `SW(x0, x1, jal_for_mem); //store return value for jal for
        prog[11] = `JAL(x1, jal_rev); // jump to pc 12
        prog[12] = 'hffff_ff0a;
        prog[13] = `SW(x0, x1, jalr_for_mem); //store return value for jalr for
        prog[14] = `JALR(x1, x1, jalr_rev); //jump to pc 4
        prog[15] = 'hffff_ff0f;
        prog[16] = 'hffff_ff10;
        prog[17] = `AUIPC(x2, auipc_for_offset);//test forward auipc (from jal_auipc)
        prog[18] = `SW(x0, x2, auipc_for_mem);
        prog[19] = `AUIPC(x2, auipc_rev_offset);

        prog[20] = `SW(x0, x2, auipc_rev_mem);
        prog[21] = 'haaaa_aaaa;

        for(int i = 0; i < PROG_LENGTH; i += 1) begin
            $display("Instruction %d: %b", i, prog[i]);
            SET_INSTRUCTION(prog[i], 4*i);
        end
        $display("Running jump and pc test");
        enable = 1;
        
        while(prog_count < PROG_LENGTH * 4) begin
            `cycle(1);
            #1ps; //need this or vivado becomes angry
        end
        $display("End Running... pc: %d", prog_count);
        
        enable = 0;

        GET_DRAM_VALUE(jal_for_mem, read_value);
        `assert_test(read_value, jal_for_expect, "JAL for", "JAL for", error_count);
        
        GET_DRAM_VALUE(jal_rev_mem, read_value);
        `assert_test(read_value, jal_rev_expect, "JAL rev", "JAL rev", error_count);

        GET_DRAM_VALUE(jalr_for_mem, read_value);
        `assert_test(read_value, jalr_for_expect, "JALR for", "JALR for", error_count);
        
        GET_DRAM_VALUE(jalr_rev_mem, read_value);
        `assert_test(read_value, jalr_rev_expect, "JALR rev", "JALR rev", error_count);

        GET_DRAM_VALUE(auipc_for_mem, read_value);
        `assert_test(read_value, auipc_for_expect, "AUIPC for", "AUIPC for", error_count);
        
        GET_DRAM_VALUE(auipc_rev_mem, read_value);
        `assert_test(read_value, auipc_rev_expect, "AUIPC rev", "AUIPC rev", error_count);
        
        if(error_count > 0) $error("Jump and pc test failed %0d times", error_count);
        else $display("PASS: Jump and pc test");

    endtask

    //alu test immediate test: slti, sltiu, xori, ori, andi, slli, slri, srai (addi has been tested extensively for loading values)
    task alu_imm_test();
        // test the various immediate alu instructions
        static int slti_1 = 5;
        static int slti_2 = -4;
        static int boolean_1 = 'hffff_fca3;//used for xor, or, and as they test each binary condition
        static int boolean_2 = 'hffff_fc53;
        static int slli_reg = 'haaaa_aaaa;
        static int slli_imm = 'h0000_0008;
        static int slti_true_mem = 20;
        static int slti_false_mem = 24;
        static int sltiu_true_mem = 28;
        static int sltiu_false_mem = 32;
        static int xori_mem = 36;
        static int ori_mem = 40;
        static int andi_mem = 44;
        static int error_count = 0;
        static int slli_mem = 48;
        static int slri_mem = 52;
        static int srai_mem = 56;
        static int slti_equal_mem = 60;
        static int sltiu_equal_mem = 64;
        static int srai_result = 'hffaa_aaaa;
        localparam PROG_LENGTH = 32;
        int prog[PROG_LENGTH];
        prog[0] = `LUI_corrected(x1,slti_1);//test slti adata = 5, imm = -4
        prog[1] = `ADDI(x1, x1, slti_1);
        prog[2] = `SLTI(x2, x1, slti_2);
        prog[3] = `SW(x0, x2, slti_false_mem);
        prog[4] = `SLTIU(x2, x1, slti_2); // test sltiu adata = 5, imm = -4
        prog[5] = `SW(x0, x2, sltiu_true_mem);
        prog[6] = `SLTI(x2, x1, slti_1); // test slti when equal
        prog[7] = `SW(x0, x2, slti_equal_mem);
        prog[8] = `SLTIU(x2, x1, slti_1); // test sltiu when equal
        prog[9] = `SW(x0, x2, sltiu_equal_mem);

        prog[10] = `LUI_corrected(x1,slti_2);//test slti adata = -4, imm = 5
        prog[11] = `ADDI(x1, x1, slti_2);
        prog[12] = `SLTI(x2, x1, slti_1)
        prog[13] = `SW(x0, x2, slti_true_mem);
        prog[14] = `SLTIU(x2, x1, slti_1); //test sltiu adata = -4, imm = 5
        prog[15] = `SW(x0, x2, sltiu_false_mem);
        prog[16] = `AND_(x1, x0, x1); // clear x1 (kinda cheating with untested instruction... shhh)
        prog[17] = `ADDI(x1, x1, boolean_1);
        prog[18] = `XORI(x2, x1, boolean_2); // test xori
        prog[19] = `SW(x0, x2, xori_mem);

        prog[20] = `ORI(x2, x1, boolean_2); // test ori
        prog[21] = `SW(x0, x2, ori_mem);
        prog[22] = `ANDI(x2, x1, boolean_2); // test andi
        prog[23] = `SW(x0, x2, andi_mem);
        prog[24] = `LUI_corrected(x1, slli_reg);
        prog[25] = `ADDI(x1, x1, slli_reg);
        prog[26] = `SLLI(x2, x1, slli_imm); // test slli
        prog[27] = `SW(x0, x2, slli_mem);
        prog[28] = `SRLI(x2, x1, slli_imm); // test slri
        prog[29] = `SW(x0, x2, slri_mem);

        prog[30] = `SRAI(x2, x1, slli_imm); // test srai
        prog[31] = `SW(x0, x2, srai_mem);

        for(int i = 0; i < PROG_LENGTH; i += 1) begin
            $display("Instruction %d: %b", i, prog[i]);
            SET_INSTRUCTION(prog[i], 4*i);
        end
        $display("Running immediate alu test");
        enable = 1;
        
        while(prog_count < PROG_LENGTH * 4) begin
            `cycle(1);
            #1ps; //need this or vivado becomes angry
        end
        $display("End Running... pc: %d", prog_count);
        
        enable = 0;

        GET_DRAM_VALUE(slti_true_mem, read_value);
        `assert_test(read_value, 1, "SLTI true", "SLTI true", error_count);

        GET_DRAM_VALUE(slti_false_mem, read_value);
        `assert_test(read_value, 0, "SLTI false", "SLTI false", error_count);

        GET_DRAM_VALUE(slti_equal_mem, read_value);
        `assert_test(read_value, 0, "SLTI equal", "SLTI equal", error_count);

        GET_DRAM_VALUE(sltiu_true_mem, read_value);
        `assert_test(read_value, 1, "SLTIU true", "SLTIU true", error_count);

        GET_DRAM_VALUE(sltiu_false_mem, read_value);
        `assert_test(read_value, 0, "SLTIU false", "SLTIU false", error_count);

        GET_DRAM_VALUE(sltiu_equal_mem, read_value);
        `assert_test(read_value, 0, "SLTIU equal", "SLTIU equal", error_count);

        GET_DRAM_VALUE(xori_mem, read_value);
        `assert_test(read_value, (boolean_1 ^ {{21{boolean_2[11]}},boolean_2[10:0]}), "XORI", "XORI", error_count);

        GET_DRAM_VALUE(ori_mem, read_value);
        `assert_test(read_value, (boolean_1 | {{21{boolean_2[11]}},boolean_2[10:0]}), "ORI", "ORI", error_count);

        GET_DRAM_VALUE(andi_mem, read_value);
        `assert_test(read_value, (boolean_1 & {{21{boolean_2[11]}},boolean_2[10:0]}), "ANDI", "ANDI", error_count);

        GET_DRAM_VALUE(slli_mem, read_value);
        `assert_test(read_value, (slli_reg << {slli_imm[4:0]}), "SLLI", "SLLI", error_count);

        GET_DRAM_VALUE(slri_mem, read_value);
        `assert_test(read_value, (slli_reg >> {slli_imm[4:0]}), "SLRI", "SLRI", error_count);

        GET_DRAM_VALUE(srai_mem, read_value);
        `assert_test(read_value, srai_result, "SRAI", "SRAI", error_count);
        
        if(error_count > 0) $error("ALU immediates test failed %0d times", error_count);
        else $display("PASS: ALU immediates test");

    endtask
    //alu test (non immediate): add, sub, sll, slt, sltu, xor, srl, sta, or, and
            
    initial begin
        clk = 0;
        reset_n = 0;
        enable = 0;
        debug_enable_write_iram = 0;
        debug_enable_write_dram = 0;
        
        `cycle(1);
        
        reset_n = 1;
        
        //load program
        `cycle(1);

        jump_pc_test();

        reset_n = 0;
        `cycle(1);
        
        reset_n = 1;
        
        `cycle(1);

        load_store_test();

        reset_n = 0;
        `cycle(1);
        
        reset_n = 1;
        
        `cycle(1);

        alu_imm_test();

        reset_n = 0;
        `cycle(1);
        
        reset_n = 1;
        
        `cycle(1);

        branch_test();

        reset_n = 0;
        `cycle(1);
        
        reset_n = 1;
        
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
