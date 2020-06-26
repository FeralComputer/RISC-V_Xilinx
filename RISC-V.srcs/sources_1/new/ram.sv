`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2020 01:36:45 PM
// Design Name: 
// Module Name: ram
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

//currently ram stores all half words and bytes in each full word and does not do byte memory as risc wants

module ram#(N=64)(
    input clk, ena,
    input int dia, addra, addrb,
    input [2:0] memory_sizea, memory_sizeb,
    output int dob
    );
    localparam word = 3'b100;
    localparam half_word = 3'b010;
    localparam byte_ = 3'b001;
    logic [15:0] ram1[N-1], ram2[N-1];
    
    
    always_comb begin
        case(memory_sizeb)
            word: begin
                #1ps;
                if(addrb[0]) begin
                    dob = {ram1[addrb[31:1] + 1'b1], ram2[addrb[31:1]]};
                end else begin
                    dob = {ram2[addrb[31:1]], ram1[addrb[31:1]]};
                end
            end
            
            half_word: begin
                #1ps; 
                dob = {16'b0, (addrb[0]) ? ram2[addrb[31:1]] : ram1[addrb[31:1]]};
            end
            
            byte_: begin
                #1ps ;
                dob = {24'b0, (addrb[0]) ? ram2[addrb[31:1]][7:0] : ram1[addrb[31:1]][7:0]};
            end
            
            default: begin
                #1ps;
                dob = 'bx;
            end    
            
        endcase
    end
    
    always_ff @(posedge clk) begin
            if(ena) begin
                unique case(memory_sizea)
                    word: begin
                        //write 32 bits in 16 bit incremented ram
                        if(addra[0]) begin
                            {ram1[addra[31:1]+1], ram2[addra[31:1]]} <= dia;
                        end else begin
                            {ram2[addra[31:1]], ram1[addra[31:1]]} <= dia;
                        end
                    end
                    
                    half_word: begin
                        //write 16 bits
                        if(addra[0]) begin
                            ram2[addra[31:1]] <= dia[15:0];
                        end else begin
                            ram1[addra[31:1]] <= dia[15:0];
                        end
                    end
                    
                    byte_: begin
                        //not implemented
                        assert('b1=='b0);
                    end

                endcase
            end
    end
    
endmodule
