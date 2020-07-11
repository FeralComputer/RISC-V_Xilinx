`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2020 05:48:39 PM
// Design Name: 
// Module Name: branch_gen
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


module branch_gen(  input int adata, bdata,
                    input logic unsign,
                    output logic lt, ne);//lessthan and not equal
    
    assign #1ps ne = ~(adata == bdata);
    
    assign #1ps lt = unsign ? $unsigned(adata) < $unsigned(bdata) : $signed(adata) < $signed(bdata);
    

endmodule