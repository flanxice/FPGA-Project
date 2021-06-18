`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:56:29 05/26/2016 
// Design Name: 
// Module Name:    SBgame 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module SBgame(
	input mclk,    
	input rst,
	input to_left1,
	input to_right1,
	input to_left2,
	input to_right2,
	input [3:0] bar_move_speed,
	output HSync,         
	output [3:0] OutBlue,
	output [3:0] OutGreen, 
	output [3:0] OutRed,         
	output VSync,
	output [3:0] seg_select,
	output [6:0] seg_LED);

wire [1:0] lose1; 
wire [1:0] lose2;

VGA_Dispay u_VGA_Disp(
	.clk(mclk),
	.to_left1(to_left1),
	.to_right1(to_right1),
	.to_left2(to_left2),
    .to_right2(to_right2),
	.bar_move_speed(bar_move_speed),
	.hs(HSync),
	.Blue(OutBlue),
	.Green(OutGreen),
	.Red(OutRed),
	.vs(VSync),
	.lose1(lose1),
	.lose2(lose2),
	.rst(rst));
	
seg score_board(
	.clk(mclk),
	.rst(rst),
	.lose1(lose1),
	.lose2(lose2),
	.select(seg_select),
	.seg(seg_LED)
	);
	
endmodule
