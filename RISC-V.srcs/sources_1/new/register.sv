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


module register(input clk, reset_n, enable, rd_enable,
                input [4:0] rs1, rs2, rd,
                input int indata,
                output int adata, bdata
    );
    
    int registers [31:1];
    
    localparam x0 = 0;
    localparam x1 = 0;
    localparam x2 = 0;
    localparam x3 = 0;
    localparam x4 = 0;
    localparam x5 = 0;
    localparam x6 = 0;
    localparam x7 = 0;
    localparam x8 = 0;
    localparam x9 = 0;
    localparam x10 = 0;
    localparam x11 = 0;
    localparam x12 = 0;
    localparam x13 = 0;
    localparam x14 = 0;
    localparam x15 = 0;
    localparam x16 = 0;
    localparam x17 = 0;
    localparam x18 = 0;
    localparam x19 = 0;
    localparam x20 = 0;
    localparam x21 = 0;
    localparam x22 = 0;
    localparam x23 = 0;
    localparam x24 = 0;
    localparam x25 = 0;
    localparam x26 = 0;
    localparam x27 = 0;
    localparam x28 = 0;
    localparam x29 = 0;
    localparam x30 = 0;
    localparam x31 = 0;
    localparam x32 = 0;
    
    always_comb begin
        case (rs1)
            x0: #1ps adata <= 0;
            default: #1ps adata <= registers[rs1];
        endcase
        
        case (rs2)
            x0: #1ps bdata <= 0;
            default: #1ps bdata <= registers[rs2];
        endcase
    end
    
    always_ff @ (posedge clk) begin
        if(enable && reset_n) begin
            
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
