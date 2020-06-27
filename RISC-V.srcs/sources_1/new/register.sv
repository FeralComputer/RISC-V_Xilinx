`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2020 10:28:41 AM
// Design Name: 
// Module Name: register
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

module register(input clk, reset_n, enable, rd_enable,
                input [4:0] rs1, rs2, rd,
                input int indata,
                output int adata, bdata
    );
    
    int registers [31:1];
    
    always_comb begin
        case (rs1)
            x0: #1ps adata = 0;
            default: #1ps adata = registers[rs1];
        endcase
    end
        
    always_comb begin
        case (rs2)
            x0: #1ps bdata = 0;
            default: #1ps bdata = registers[rs2];
        endcase
    end
    
    always_ff @ (posedge clk) begin
        if(enable && reset_n) begin
            $display("reg[%0d] = %0d, reg[%0d] = %0d, reg[2] = %0d", rs1, adata, rs2, bdata, registers[2]);
            //only save to registers when told to
            if(rd_enable) begin
                case (rd)
                    x0: begin end
                    default: registers[rd] <= indata;
                endcase
            end
        end
    end
    
endmodule
