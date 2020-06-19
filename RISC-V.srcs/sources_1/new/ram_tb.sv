`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2020 01:36:45 PM
// Design Name: 
// Module Name: ram_tb
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

module ram_tb();
    logic clk, ena;
    int dia, addra, addrb;
    logic [2:0] memory_sizea, memory_sizeb;
    int dob;
    
    localparam word = 3'b100;
    localparam half_word = 3'b010;
    localparam byte_ = 3'b001;
    
    ram dut (.*);
    
    initial begin
        clk = 0;
        ena = 0;
        addra = 0;
        addrb = 0;
        memory_sizea = word;
        memory_sizeb = word;
        
        repeat (1) @ (posedge clk);
        #1ps;
        
        ena = 1;
        //write words to ram
        for(int i=0; i < 64; i+=2) begin
            addra = i;
            dia = i+1;
            
            repeat (1) @ (posedge clk);
            
            #1ps;
            
        end
        
        ena =0;
        
        //read words from ram
        for(int i=0; i < 64; i+=2) begin
            addrb = i;
            
            repeat (1) @ (posedge clk);
            
            #1ps;
            
            assert (dob == i+1);      
            
        end
        
        //test read write
        ena = 1;
        for (int i = 0; i < 64; i+=2) begin
            addra = i;
            dia = (i + 1) * 2;
            addrb = i;
            repeat (1) @ (posedge clk);
            #1ps;
            assert (dob == i+1);
        end
        
        ena = 0;
        
        //check values written during read write
        for( int i =0; i < 64; i+=2) begin
            addrb = i;
            
            repeat (1) @ (posedge clk);
            #1ps;
            
            assert (dob == (i + 1) * 2);
        end
        
        //test half_words
        
        ena = 1;
        //write half_words to ram
        memory_sizea = half_word;
        memory_sizeb = half_word;
        for(int i=0; i < 64; i+=1) begin
            addra = i;
            dia = i+1;
            
            repeat (1) @ (posedge clk);
            
            #1ps;
            
        end
        
        ena =0;
        
        //read words from ram
        for(int i=0; i < 64; i+=1) begin
            addrb = i;
            
            repeat (1) @ (posedge clk);
            
            #1ps;
            
            assert (dob == i+1);      
            
        end
        
        //test read write
        ena = 1;
        for (int i = 0; i < 64; i+=1) begin
            addra = i;
            dia = (i + 1) * 2;
            addrb = i;
            repeat (1) @ (posedge clk);
            #1ps;
            assert (dob == i+1);
        end
        
        ena = 0;
        
        //check values written during read write
        for( int i =0; i < 64; i+=1) begin
            addrb = i;
            
            repeat (1) @ (posedge clk);
            #1ps;
            
            assert (dob == (i + 1) * 2);
        end
        $stop;
        
    end
    
    always
        #5ps clk = ~clk;
    
endmodule