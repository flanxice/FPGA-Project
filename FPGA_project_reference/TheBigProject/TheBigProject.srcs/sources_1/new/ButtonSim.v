`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/09 22:33:42
// Design Name: 
// Module Name: ButtonSim
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


module ButtonSim();
    reg sys_clk;
    reg sys_rst_n;
    reg button_in;
    wire stable_out;

    Button ButtonTest(sys_clk,sys_rst_n,button_in,stable_out);
    
    initial begin 
    #50;
    sys_clk =1'b0;
    button_in = 1'b0;
    sys_rst_n = 1'b1;
    #50;
    sys_rst_n = 1'b0;
    #50;
    
    button_in = 1'b1;
    #20;
    button_in = 1'b0;
    #50;    
    
    end
    always begin
        #5;
        sys_clk = ~sys_clk;
    end 

endmodule
