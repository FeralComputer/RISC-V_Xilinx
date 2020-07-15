`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2020 04:07:08 PM
// Design Name: 
// Module Name: csr_tb
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

module csr_tb(

    );
    
    logic clk, reset_n, enable;
    int csr_result, csr_data;
    logic [2:0] csr_sel;
    logic [11:0] csr_addr;
    
    csr #(32) csr_ (.clk(clk), .reset_n(reset_n), .enable(enable), .csr_result(csr_result),
                    .csr_data(csr_data), .csr_sel(csr_sel), .csr_addr(csr_addr));
    
    initial begin
        clk = 0;
        reset_n = 0;
        enable = 0;
        csr_sel = csr_idle;
        csr_addr = 0;
        csr_data = 0;
        
        `cycle(2);
        
        reset_n = 1;
        csr_sel = csr_csrrw;
        csr_data = 'haaaa_aaaa;
        csr_addr = CSR_TEST;
        
        `cycle(1);
        
        assert(csr_result == 0)
        else $error("CSR result is not zero (enable not working)");
        
        enable = 1;
        
        `cycle(1);
        
        assert(csr_result == 'haaaa_aaaa)
        else $error("CSRRW did not work, returned %d", csr_result);
        
        csr_sel = csr_csrrs;
        csr_data = 'h0000_ffff;
        
        `cycle(1);
        
        assert(csr_result == 'haaaa_ffff)
        else $error("CSRRS did not work, returned %d", csr_result);
        
        csr_sel = csr_csrrc;
        csr_data = 'hffff_0000;
        
        `cycle(1);
        
        assert(csr_result == 'h0000_ffff)
        else $error("CSRRC did not work, returned %d", csr_result);
        
        csr_sel = csr_idle;
        
        `cycle(100);
        
        csr_sel = csr_csrrs;
        csr_addr = CSR_RDCYCLE;
        
        `cycle(1);
        
        assert(csr_result == 104)
        else $error("CSR_RDCYCLE returned %d but expected %d", csr_result, 104);
        
        csr_addr = CSR_RDTIMER;
        
        `cycle(1);
        
        assert(csr_result == $floor(105/FREQUENCY))
        else $error("CSR_RDTIME returned %d but expected %d", csr_result, $floor(105/FREQUENCY));
        
        csr_addr = CSR_RDINSTRET;
        
        `cycle(1);
        
        assert(csr_result == 106)
        else $error("CSR_RDINSTRET returned %d but expected %d", csr_result, 106);
        
        $stop;
    end
    
    always
        #5ps clk = ~clk;
    
    
    
    
    
endmodule
