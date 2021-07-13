`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:47:08 11/17/2014 
// Design Name: 
// Module Name:    Tetris_top 
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
module Tetris_top(
	clk,
	btnL,
	btnR,
	btnD,
	btnS,
	HSync,
	VSync,
	R,
	G,
	B,
	Seg,
	An,
	t
    );
	
	input clk, btnL, btnR, btnD, btnS;
	output HSync, VSync;
	output [3:0] R;
	output [3:0] G;
	output [3:0] B;
	output [7:0] Seg;
	output [3:0] An;
	output reg t;
	
	wire [199:0] gridA;
	wire [199:0] gridB;
	wire [12:0] score;
	
	tetris_main M_TET(clk, btnL, btnR, btnD, btnS, gridA, gridB, score);
	tetris_vga2 M_VGA(clk, gridA, gridB, HSync, VSync, R, G, B);
	tetris_seg  M_SEG(clk, score, Seg, An);
	always @(posedge clk) begin
		if (score > 100) t <= 1;
		else t <= 0;
	end

endmodule
