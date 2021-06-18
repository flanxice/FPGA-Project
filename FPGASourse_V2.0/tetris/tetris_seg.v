`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:48:15 12/09/2014 
// Design Name: 
// Module Name:    tetris_seg 
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
module tetris_seg(clk, num, seg, an);
	input clk;
	input [12:0] num;
	output reg [7:0] seg;
	output reg [3:0] an;
	
	reg [12:0] divider;
	wire scan_clk = divider[12];
	
	reg [15:0] bcd;
	reg [3:0] dec_bcd;
	
	always @(posedge clk)
		divider <= divider + 1'b1;
	
	always @(posedge scan_clk) begin
		bcd[3:0] <= num % 10;
		bcd[7:4] <= (num / 10) % 10;
		bcd[11:8] <= (num / 100) % 10;
		bcd[15:12] <= (num / 1000) % 10;
	end
	
	always @(posedge scan_clk) begin
		case (an)
			4'b1110: begin
				an <= 4'b1101;
				dec_bcd <= bcd[7:4];
			end
			4'b1101: begin
				an <= 4'b1011;
				dec_bcd <= bcd[11:8];
			end
			4'b1011: begin
				an <= 4'b0111;
				dec_bcd <= bcd[15:12];
			end
			default: begin
				an <= 4'b1110;
				dec_bcd <= bcd[3:0];
			end
		endcase
	end
	
	always @(dec_bcd) begin
		case (dec_bcd)
			4'h0 : seg = {1'b1,7'b1000000};
			4'h1 : seg = {1'b1,7'b1111001};
			4'h2 : seg = {1'b1,7'b0100100};
			4'h3 : seg = {1'b1,7'b0110000};
			4'h4 : seg = {1'b1,7'b0011001};
			4'h5 : seg = {1'b1,7'b0010010};
			4'h6 : seg = {1'b1,7'b0000010};
			4'h7 : seg = {1'b1,7'b1111000};
			4'h8 : seg = {1'b1,7'b0000000};
			4'h9 : seg = {1'b1,7'b0010000};
			default : seg = {1'b1,7'b1111111};
		endcase
	end
endmodule
