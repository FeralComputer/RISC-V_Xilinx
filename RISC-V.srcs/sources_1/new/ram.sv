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

import risc_structs::*;

module ram#(N=64)(
    input clk, ena, sign,
    input int dia, addra, addrb,
    input logic [2:0] memory_sizea, memory_sizeb,
    output int dob
    );

    logic [7:0] ram1[N-3], ram2[N-3], ram3[N-3], ram4[N-3];
    
    //read value from ram
    always_comb begin
        case(memory_sizeb)
            ram_word: begin
                #1ps;
                //ordering the ram correctly for full 32 bits
                case(addrb[1:0])
                    2'b00: dob = {ram4[addrb[31:2]], ram3[addrb[31:2]], ram2[addrb[31:2]], ram1[addrb[31:2]]};
                    2'b01: dob = {ram1[addrb[31:2] + 1'b1], ram4[addrb[31:2]], ram3[addrb[31:2]], ram2[addrb[31:2]]};
                    2'b10: dob = {ram2[addrb[31:2] + 1'b1], ram1[addrb[31:2] + 1'b1], ram4[addrb[31:2]], ram3[addrb[31:2]]};
                    2'b11: dob = {ram3[addrb[31:2] + 1'b1], ram2[addrb[31:2] + 1'b1], ram1[addrb[31:2] + 1'b1], ram4[addrb[31:2]]};
                endcase
            end
            
            ram_half_word: begin
                #1ps; 
                //ordering ram for 16 bits
                case(addrb[1:0])
                    2'b00: dob = {sign ? {16{ram2[addrb[31:2]][7]}} : 16'b0, ram2[addrb[31:2]], ram1[addrb[31:2]]};
                    2'b01: dob = {sign ? {16{ram3[addrb[31:2]][7]}} : 16'b0, ram3[addrb[31:2]], ram2[addrb[31:2]]};
                    2'b10: dob = {sign ? {16{ram4[addrb[31:2]][7]}} : 16'b0, ram4[addrb[31:2]], ram3[addrb[31:2]]};
                    2'b11: dob = {sign ? {16{ram1[addrb[31:2] + 1'b1][7]}} : 16'b0, ram1[addrb[31:2] + 1'b1], ram4[addrb[31:2]]};
                endcase                
            end
            
            ram_byte: begin
                #1ps ;
                case(addrb[1:0])
                    2'b00: dob = {sign ? {24{ram1[addrb[31:2]][7]}} : 24'b0, ram1[addrb[31:2]]};
                    2'b01: dob = {sign ? {24{ram2[addrb[31:2]][7]}} : 24'b0, ram2[addrb[31:2]]};
                    2'b10: dob = {sign ? {24{ram3[addrb[31:2]][7]}} : 24'b0, ram3[addrb[31:2]]};
                    2'b11: dob = {sign ? {24{ram4[addrb[31:2]][7]}} : 24'b0, ram4[addrb[31:2]]};
                endcase
            end
            
            default: begin
                #1ps;
                dob = 'bx;
            end    
            
        endcase
    end
    
    //write value into ram
    always_ff @(posedge clk) begin
            if(ena) begin
                case(memory_sizea)
                    ram_word: begin
                        //write 32 bits in 8 bit incremented ram
                        case(addra[1:0])
                            2'b00: {ram4[addra[31:2]], ram3[addra[31:2]], ram2[addra[31:2]], ram1[addra[31:2]]} <= dia;
                            2'b01: {ram1[addra[31:2] + 1'b1], ram4[addra[31:2]], ram3[addra[31:2]], ram2[addra[31:2]]} <= dia;
                            2'b10: {ram2[addra[31:2] + 1'b1], ram1[addra[31:2] + 1'b1], ram4[addra[31:2]], ram3[addra[31:2]]} <= dia;
                            2'b11: {ram3[addra[31:2] + 1'b1], ram2[addra[31:2] + 1'b1], ram1[addra[31:2] + 1'b1], ram4[addra[31:2]]} <= dia;
                        endcase
                    end
                    
                    ram_half_word: begin
                        //write 16 bits
                        case(addra[1:0])
                            2'b00: {ram2[addra[31:2]], ram1[addra[31:2]]} <= dia[15:0];
                            2'b01: {ram3[addra[31:2]], ram2[addra[31:2]]} <= dia[15:0];
                            2'b10: {ram4[addra[31:2]], ram3[addra[31:2]]} <= dia[15:0];
                            2'b11: {ram1[addra[31:2] + 1'b1], ram4[addra[31:2]]} <= dia[15:0];
                        endcase  
                    end
                    
                    ram_byte: begin
                        //write 8 bits
                        case(addra[1:0])
                            2'b00: ram1[addra[31:2]] <= dia[7:0];
                            2'b01: ram2[addra[31:2]] <= dia[7:0];
                            2'b10: ram3[addra[31:2]] <= dia[7:0];
                            2'b11: ram4[addra[31:2]] <= dia[7:0];
                        endcase
                    end

                endcase
            end
    end
    
endmodule
