`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2020 05:48:39 PM
// Design Name: 
// Module Name: branch_gen_tb
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

module branch_gen_tb(

    );
    
    int adata, bdata;
    logic ne, lt, unsign;
    
    logic clk;
    
    branch_gen dut (.adata(adata), .bdata(bdata), .ne(ne), .lt(lt), .unsign(unsign));
    
    initial begin
        clk = 0;
        adata = 0;
        bdata = 0;
        unsign = 0;
        
        `cycle(1);
        
        //a and b are zero so ne == 0
        assert(ne == 0)
        else $display("adata: %d, bdata: %d, ne failed unsigned",adata, bdata);
        assert(lt == 0)
        else $display("adata: %d, bdata: %d, lt failed unsigned",adata, bdata);
        
        adata = 'haaaa_aaaa;
        bdata = 'haaaa_aaaa;
        
        `cycle(1);
        assert(ne == 0)
        else $display("adata: %d, bdata: %d, ne failed unsigned",adata, bdata);
        assert(lt == 0)
        else $display("adata: %d, bdata: %d, lt failed unsigned",adata, bdata);
        
        bdata = 'h0aaa_aaaa;
        
        `cycle(1);
        assert(ne == 1)
        else $display("adata: %d, bdata: %d, ne failed unsigned",adata, bdata);
        assert(lt == 1)
        else $display("adata: %d, bdata: %d, lt failed unsigned",adata, bdata);
        
        unsign = 1;
        
        `cycle(1);
        assert(ne == 1)
        else $display("adata: %d, bdata: %d, ne failed signed",adata, bdata);
        assert(lt == 0)
        else $display("adata: %d, bdata: %d, lt failed signed",adata, bdata);
        
        bdata = 'haaaa_aaaf;
        
        `cycle(1);
        assert(ne == 1)
        else $display("adata: %d, bdata: %d, ne failed signed",adata, bdata);
        assert(lt == 1)
        else $display("adata: %d, bdata: %d, lt failed signed",adata, bdata);
        
        $stop;
    end
    
    always
        #5ps clk = ~clk;
endmodule
