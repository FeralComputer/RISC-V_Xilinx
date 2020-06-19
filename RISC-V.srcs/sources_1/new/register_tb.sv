`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2020 10:28:41 AM
// Design Name: 
// Module Name: register_tb
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
`define cycle(count) \
    repeat (count) @ (posedge clk); \
    #1ps;

module register_tb();
    logic clk, reset_n, enable, rd_enable;
    logic [4:0] rs1, rs2, rd;
    int indata;
    int adata, bdata;
    
    register dut(.*);
    
    initial begin
        clk = 0;
        reset_n = 0;
        enable = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        rd_enable = 0;
        
        `cycle(1);
        
        
        reset_n = 1;
        
        `cycle(1);
        
        //write values into registers
        enable = 1;
        rd_enable = 1;
        for(int i = 0; i < 32; i+=1) begin
            rd = i;
            indata = (i+1) * 2;
            
            `cycle(1);
            
        end
        
        rd_enable = 0;
        //read values back
        for(int i=0;i<16;i+=1) begin
            rs1 = i*2;
            rs2 = i*2 + 1;
            
            `cycle(1);
            
            assert (adata == (2*i+1)*2 ) 
                else $display("Read from register %d failed with a value of %d expected is %d",i*2, adata, (2*i+1)*2);
            assert (bdata == (2*i+2)*2 ) 
                else $display("Read from register %d failed with a value of %d expected is %d",i*2 + 1, bdata, (2*i+2)*2);
        end
        
        
        
        $stop;
    end

    always
        #5ps clk = ~clk;

endmodule