`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2020 12:37:50 PM
// Design Name: 
// Module Name: programcounter_tb
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


module programcounter_tb(

    );
    
    logic clk, reset_n, enable, modify_pc;
    int modified_pc, program_counter;
    
    programcounter dut(.clk(clk), .reset_n(reset_n), .enable(enable), .modify_pc(modify_pc), 
        .modified_pc(modified_pc), .program_counter(program_counter));
        
    initial begin
        //reset
        reset_n = 0;
        clk = 0;
        enable = 0;
        modify_pc = 0;
        repeat (1) @ (posedge clk);
        #1ps 
        reset_n = 1;
        repeat (1) @ (posedge clk);
        #1ps
        enable = 1;
        
        repeat (5) @ (posedge clk);
        #1ps
        assert(program_counter == 5*4);
        
        modified_pc = 'h1000;
        modify_pc = 1;
        
        repeat (1) @ (posedge clk);
        #1ps
        modify_pc = 0;
        assert(program_counter == 'h1000);
        
        repeat (1) @ (posedge clk);
        #1ps
        assert(program_counter == 'h1004);
        $stop;
        
    end
        
    always
        #5ps clk = ~clk;
endmodule
