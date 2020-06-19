`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2020 01:37:15 PM
// Design Name: 
// Module Name: instruction_types
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: maybe change these to interfaces but cannot have interface of interfaces
// 
//////////////////////////////////////////////////////////////////////////////////
import isa_types::*;

parameter lui = 'b0110111;
parameter op_imm = 'b0010011;
parameter addi = 'b000;

module decoder(input logic clk, input logic reset_n, input int instruction);
    
    typedef enum { B, I, J, R, S, U } isa_type;
    always_ff @ (posedge clk) begin
        if(~reset_n) begin
        
        end else begin
            case(instruction[6:0])
                'b0010011:
                    case(instruction[14:12])
                        'b000: begin
                            //addi
                        end
                        
                        'b010: begin
                            //slti
                        end
                        
                        'b011: begin
                            //sltiu
                        end
                        
                        'b100: begin
                            //xori
                        end
                        
                        'b110: begin
                            //ori
                        end
                        
                        'b111: begin
                            //andi
                        end
                        
                        'b001: begin
                            //slli
                        end
                        
                        'b101: begin
                            //srli or srai
                        end
                    endcase
            endcase
        end
    end

endmodule