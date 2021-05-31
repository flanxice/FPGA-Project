`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/30 08:54:09
// Design Name: 
// Module Name: tanqiu
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


module tanqiu(
	input mclk,    
	input rst,
	input to_left1,
	input to_right1,
	input to_left2,
	input to_right2,
	input [3:0] bar_move_speed,
	output HSync,         
	output [2:1] OutBlue,
	output [2:0] OutGreen, 
	output [2:0] OutRed,         
	output VSync);

wire lose;

VGA_Dispay dis(
	.clk(mclk),
	.to_left1(to_left1),
	.to_right1(to_right1),
	.bar_move_speed(bar_move_speed),
	.to_left2(to_left2),
    .to_right2(to_right2),
	.hs(HSync),
	.Blue(OutBlue),
	.Green(OutGreen),
	.Red(OutRed),
	.vs(VSync),
	.lose(lose));
	
endmodule

module seven_seg(
         input clk, 
         input rst, 
         input lose,
         output reg [3:0] select, 
         output reg [6:0] seg
        );
endmodule