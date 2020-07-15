`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2020 04:07:08 PM
// Design Name: 
// Module Name: csr
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

module csr#(CSR_MEM_SIZE=32)(input clk, reset_n, enable,
                input int csr_data, 
                input logic [2:0] csr_sel,
                input logic [11:0] csr_addr,
                output int csr_result
    );
    
    function int csr_modification(input int mask, original_data, input [2:0] sel);
        case(sel)
            csr_csrrw: return mask;
            csr_csrrs: return original_data | mask;
            csr_csrrc: return original_data & (~mask);
            default: return original_data;
        endcase
    endfunction
    
    logic [63:0] rdcycle, rdcycle_next;
    logic [63:0] rdtimer, rdtimer_next;
    logic [$rtoi($floor($clog2(FREQUENCY)))+1:0] rdtimer_count, rdtimer_count_next;
    logic [63:0] rdinstret, rdinstret_next;
    
    int test, test_next; //testing values until real csrs exist
    
    
    
    //returns the value requested (is also used for determining the new write value)
    //TODO not too happy about the implementation (revisit this later)
    always_comb begin
        csr_result = 'bx;
        //CSR_RDCYCLE - not modifiable
        rdcycle_next = rdcycle + 1;
        
        //CSR_RDTIME - not modifiable
        if(rdtimer_count >= (FREQUENCY - 1)) begin
            rdtimer_count_next = 0;
            rdtimer_next = rdtimer + 1;
        end else begin
            rdtimer_count_next = rdtimer_count + 1;
            rdtimer_next = rdtimer;
        end
        
        //CSR_RDINSTRET - not modifiable 
        //TODO currently increments every clk and will need to be changed once pipelining and more advanced features exist
        rdinstret_next = rdinstret + 1;
        
        //CSR_TEST - modifiable 
        //TODO exists for testing purpose only and should be removed once other modifiable csrs exist
        test_next = test;
        
        //output result and modify value if able
        case(csr_addr)
            CSR_RDCYCLE: csr_result = rdcycle[31:0];
            CSR_RDCYCLEH: csr_result = rdcycle[63:32];
            CSR_RDTIMER: csr_result = rdtimer[31:0];
            CSR_RDTIMERH: csr_result = rdtimer[63:32];
            CSR_RDINSTRET: csr_result = rdinstret[31:0];
            CSR_RDINSTRETH: csr_result = rdinstret[63:32];
            CSR_TEST: begin
                test_next = csr_modification(csr_data, test, csr_sel);
                csr_result = test;
            end
        endcase           
    end
    
    //writes new values into csr_array
    always_ff @ (posedge clk) begin
        if(~reset_n) begin
            //reset array
            rdcycle <= 0;
            rdtimer <= 0;
            rdinstret <= 0;
            test <= 0;
            rdtimer_count <= 0;
        end else if(enable) begin
            rdcycle <= rdcycle_next;
            rdtimer <= rdtimer_next;
            rdtimer_count <= rdtimer_count_next;
            rdinstret <= rdinstret_next;
            test <= test_next;
        end
    end
    
    
    
    
endmodule