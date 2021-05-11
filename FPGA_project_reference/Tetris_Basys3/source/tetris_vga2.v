`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:22:56 11/26/2014 
// Design Name: 
// Module Name:    tetris_vga2 
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
module tetris_vga2(
	clk,
	GridA, GridB,
	HSync, VSync,
	R, G, B
    );
	
	input clk; // 100Mhz clock
	input [199:0] GridA; // blue grid
	input [199:0] GridB; // red grid
	output reg HSync;
	output reg VSync;
	output wire [2:0] R;
	output wire [2:0] G;
	output wire [1:0] B;
	
	reg [7:0] RGB;
	assign R = RGB[7:5];
	assign G = RGB[4:2];
	assign B = RGB[1:0];
	
	// colors
	parameter COLOR_BACKGROUND = 8'b000_000_00,
			  COLOR_BORDER     = 8'b111_111_11,
			  COLOR_GRIDA      = 8'b000_000_11,
			  COLOR_GRIDB      = 8'b000_110_00,
			  COLOR_BOTH       = 8'b111_000_00;
	
	parameter HPULSE_END  = 96 ,
			  LMARGIN_END = 336,
			  LBORDER_END = 352,
			  RGAME_END   = 512,
			  RBORDER_END = 528;

	parameter VPULSE_END  = 2,
			  TMARGIN_END = 76,
			  TBORDER_END = 92,
			  BGAME_END   = 412,
			  BBORDER_END = 428;
	
	reg [9:0] HorizontalCounter;
	reg [9:0] VerticalCounter;

	wire [5:0] ShiftedHorizontalCounter = HorizontalCounter[9:4];
	parameter SHIFTED_HGAME_START = 22; // gamestart/16

	reg [199:0] GridA_Buff;
	reg [199:0] GridB_Buff;
	wire [9:0] a = GridA_Buff[199:190];
	wire [9:0] b = GridB_Buff[199:190];

	reg [1:0] clock_divider;
	wire pxl_clk = clock_divider[1];
	
	always @(posedge clk) begin
		clock_divider <= clock_divider + 1'b1;
	end
	
	// HorizontalCounter should count 25MHz clock pulses from 0 to 799
	always @(posedge pxl_clk) begin
		if (HorizontalCounter < 799)
			HorizontalCounter <= HorizontalCounter + 1'b1;
		else
			HorizontalCounter <= 0;
	end

	// HSync is active for 96 clock pulses
	always @(posedge pxl_clk) begin
		if (HorizontalCounter < 96)
			HSync <= 1'b0;
		else
			HSync <= 1'b1;
	end


	// VerticalCounter should count HSync pulses from 0 to 524
	always @(negedge HSync) begin
		if (VerticalCounter < 524)
			VerticalCounter <= VerticalCounter + 1'b1;
		else
			VerticalCounter <= 0;
	end

	// VSync is active for 2 lines
	always @(posedge pxl_clk) begin
		if (VerticalCounter < 2)
			VSync <= 1'b0;
		else
			VSync <= 1'b1;
	end

	// stuff for drawing game area:
	always @(posedge pxl_clk) begin
		// Draw top margin
		if (VerticalCounter < TMARGIN_END)
			RGB <= COLOR_BACKGROUND;
		
		// Draw top border
		else if (VerticalCounter < TBORDER_END) begin
			if (HorizontalCounter >= LMARGIN_END && HorizontalCounter < RBORDER_END)
				RGB <= COLOR_BORDER;
			else
				RGB <= COLOR_BACKGROUND;
		end
		
		// Draw game
		else if (VerticalCounter < BGAME_END) begin
			if (HorizontalCounter < LMARGIN_END)
				RGB <= COLOR_BACKGROUND;
			else if (HorizontalCounter < LBORDER_END)
				RGB <= COLOR_BORDER;
			else if (HorizontalCounter < RGAME_END) begin
				// draw game board
				case (ShiftedHorizontalCounter)
					SHIFTED_HGAME_START:     RGB <= (a[9] & b[9]) ? COLOR_BOTH : (a[9]) ? COLOR_GRIDA : (b[9]) ? COLOR_GRIDB : COLOR_BACKGROUND;
					SHIFTED_HGAME_START + 1: RGB <= (a[8] & b[8]) ? COLOR_BOTH : (a[8]) ? COLOR_GRIDA : (b[8]) ? COLOR_GRIDB : COLOR_BACKGROUND;
					SHIFTED_HGAME_START + 2: RGB <= (a[7] & b[7]) ? COLOR_BOTH : (a[7]) ? COLOR_GRIDA : (b[7]) ? COLOR_GRIDB : COLOR_BACKGROUND;
					SHIFTED_HGAME_START + 3: RGB <= (a[6] & b[6]) ? COLOR_BOTH : (a[6]) ? COLOR_GRIDA : (b[6]) ? COLOR_GRIDB : COLOR_BACKGROUND;
					SHIFTED_HGAME_START + 4: RGB <= (a[5] & b[5]) ? COLOR_BOTH : (a[5]) ? COLOR_GRIDA : (b[5]) ? COLOR_GRIDB : COLOR_BACKGROUND;
					SHIFTED_HGAME_START + 5: RGB <= (a[4] & b[4]) ? COLOR_BOTH : (a[4]) ? COLOR_GRIDA : (b[4]) ? COLOR_GRIDB : COLOR_BACKGROUND;
					SHIFTED_HGAME_START + 6: RGB <= (a[3] & b[3]) ? COLOR_BOTH : (a[3]) ? COLOR_GRIDA : (b[3]) ? COLOR_GRIDB : COLOR_BACKGROUND;
					SHIFTED_HGAME_START + 7: RGB <= (a[2] & b[2]) ? COLOR_BOTH : (a[2]) ? COLOR_GRIDA : (b[2]) ? COLOR_GRIDB : COLOR_BACKGROUND;
					SHIFTED_HGAME_START + 8: RGB <= (a[1] & b[1]) ? COLOR_BOTH : (a[1]) ? COLOR_GRIDA : (b[1]) ? COLOR_GRIDB : COLOR_BACKGROUND;
					SHIFTED_HGAME_START + 9: RGB <= (a[0] & b[0]) ? COLOR_BOTH : (a[0]) ? COLOR_GRIDA : (b[0]) ? COLOR_GRIDB : COLOR_BACKGROUND;
					default:		         RGB <= COLOR_BACKGROUND;
				endcase
			end
			else if (HorizontalCounter < RBORDER_END)
				RGB <= COLOR_BORDER;
			else
				RGB <= COLOR_BACKGROUND;
		end
		
		// Draw bottom border
		else if (VerticalCounter < BBORDER_END) begin
			if (HorizontalCounter >= LMARGIN_END && HorizontalCounter < RBORDER_END)
				RGB <= COLOR_BORDER;
			else
				RGB <= COLOR_BACKGROUND;
		end
		
		// Draw bottom margin
		else
			RGB <= COLOR_BACKGROUND;
	end

	always @(negedge HSync) begin
		if (VerticalCounter == 0) begin
			// load new grid
			GridA_Buff <= GridA;
			GridB_Buff <= GridB;
		end
		else if (VerticalCounter > TBORDER_END 
				&& VerticalCounter[3:0] == TBORDER_END % 16) begin // is 16 lines after TBORDER_END
			// shift grids by 10 (move to next row)
			GridA_Buff <= GridA_Buff << 10;
			GridB_Buff <= GridB_Buff << 10;
		end
	end

endmodule
