`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:48:01 11/17/2014 
// Design Name: 
// Module Name:    tetris_vga 
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
module tetris_vga(
	clk,
	GridA_in,
	GridB_in,
	Hsync,
	Vsync,
	R,
	G,
	B
    );

	input clk; // 100Mhz clock
	input [199:0] GridA_in; // blue grid
	input [199:0] GridB_in; // red grid
	output reg Hsync;
	output reg Vsync;
	output wire [2:0] R;
	output wire [2:0] G;
	output wire [1:0] B;
	
	reg [7:0] RGB;
	assign R = RGB[7:5];
	assign G = RGB[4:2];
	assign B = RGB[1:0];
	
	// state parameters
	parameter S_vs_sync   = 3'd0,
			  S_vs_fporch = 3'd1,
			  S_hs_sync   = 3'd2,
			  S_hs_fporch = 3'd3,
			  S_hs_active = 3'd4,
			  S_hs_bporch = 3'd5,
			  S_vs_bporch = 3'd6;
	
	// timing parameters.
	// Number of 25.175Mhz clock cycles per state.
	parameter VS_SYNC   = 1600,
			  VS_FPORCH = 8000,
			  HS_SYNC   = 96,
			  HS_FPORCH = 16,
			  HS_BPORCH = 48,
			  VS_BPORCH = 26400;
	
	// screen size parameters
	// Number of pixels in the screen
	parameter SCREEN_HEIGHT = 480,
			  SCREEN_WIDTH  = 640;

	parameter BORDER_WIDTH  = 16,
			  SQUARE_WIDTH  = 16;

	// alignment and sizing parameters
	parameter LMARGIN_END   = 224,
			  LBORDER_END   = 240, // LMARGIN_END + BORDER_WIDTH
			  HGAME_END     = 400, // LBORDER_END + 10*SQUARE_WIDTH
			  RBORDER_END   = 416; // GAME_END + BORDER_WIDTH
	parameter TMARGIN_END   = 64,
			  TBORDER_END   = 80,  // TMARGIN_END + BORDER_WIDTH
			  VGAME_END     = 400, // TBORDER_END + 20*SQUARE_WIDTH
			  BBORDER_END   = 416; // VGAME_END + BORDER_WIDTH
			  
	parameter GAME_HSHIFT = 15; // LBORDER_END / 16
	
	// colors
	parameter COLOR_BACKGROUND = 8'b000_000_00,
			  COLOR_BORDER     = 8'b111_111_11,
			  COLOR_GRIDA      = 8'b111_000_00,
			  COLOR_GRIDB      = 8'b000_000_11,
			  COLOR_BOTH       = 8'b000_111_00;
			  
	reg [199:0] GridA_buff;
	reg [199:0] GridB_buff;
	reg [2:0] state;
	reg [14:0] state_counter;
	reg [8:0] line_counter = 1;
	
	wire [9:0] a = GridA_buff[199:190];
	wire [9:0] b = GridB_buff[199:190];
	
	reg [1:0] clock_divider;
	wire pxl_clk = clock_divider[1];
	
	always @(posedge clk) begin
		clock_divider <= clock_divider + 1'b1;
	end
	
	always @(posedge pxl_clk) begin
		case (state)
		S_vs_sync:
			begin
				if (state_counter == 0) begin
					GridA_buff <= GridA_in;
					GridB_buff <= GridB_in;
					line_counter <= 0;
				end
				if (state_counter < VS_SYNC) begin
					Vsync <= 1'b0;
					state_counter <= state_counter + 1'b1;
				end
				else begin
					Vsync <= 1'b1;
					state_counter <= 0;
					state <= S_vs_fporch;
				end
			end
		S_vs_fporch:
			begin
				if (state_counter < VS_FPORCH)
					state_counter <= state_counter + 1'b1;
				else begin
					state_counter <= 0;
					state <= S_hs_sync;
				end
			end
		S_hs_sync:
			begin
				if (state_counter == 0)
					line_counter <= line_counter + 1'b1;
				if (state_counter < HS_SYNC) begin
					Hsync <= 1'b0;
					state_counter <= state_counter + 1'b1;
				end
				else begin
					Hsync <= 1'b1;
					state_counter <= 0;
					state <= S_hs_fporch;
				end
			end
		S_hs_fporch:
			begin
				if (state_counter < HS_FPORCH)
					state_counter <= state_counter + 1'b1;
				else begin
					state_counter <= 0;
					state <= S_hs_active;
				end
			end
		S_hs_active:
			begin
				if (state_counter < SCREEN_WIDTH) begin
					state_counter <= state_counter + 1'b1;
					
					// draw top margin
					if (line_counter < TMARGIN_END)
						RGB <= COLOR_BACKGROUND;

					// draw top border
					else if (line_counter < TBORDER_END) begin
						if (state_counter < LMARGIN_END	|| state_counter >= RBORDER_END)
							RGB <= COLOR_BACKGROUND;
						else
							RGB <= COLOR_BORDER;
					end
					
					// draw game lines
					else if (line_counter < VGAME_END) begin
						if (state_counter < LMARGIN_END)
							RGB <= COLOR_BACKGROUND;
						else if (state_counter < LBORDER_END)
							RGB <= COLOR_BORDER;
						else if (state_counter < HGAME_END)
							case (state_counter >> 4)
								GAME_HSHIFT:     RGB <= (a[9] & b[9]) ? COLOR_BOTH : (a[9]) ? COLOR_GRIDA : (b[9]) ? COLOR_GRIDB : COLOR_BACKGROUND;
								GAME_HSHIFT + 1: RGB <= (a[8] & b[8]) ? COLOR_BOTH : (a[8]) ? COLOR_GRIDA : (b[8]) ? COLOR_GRIDB : COLOR_BACKGROUND;
								GAME_HSHIFT + 2: RGB <= (a[7] & b[7]) ? COLOR_BOTH : (a[7]) ? COLOR_GRIDA : (b[7]) ? COLOR_GRIDB : COLOR_BACKGROUND;
								GAME_HSHIFT + 3: RGB <= (a[6] & b[6]) ? COLOR_BOTH : (a[6]) ? COLOR_GRIDA : (b[6]) ? COLOR_GRIDB : COLOR_BACKGROUND;
								GAME_HSHIFT + 4: RGB <= (a[5] & b[5]) ? COLOR_BOTH : (a[5]) ? COLOR_GRIDA : (b[5]) ? COLOR_GRIDB : COLOR_BACKGROUND;
								GAME_HSHIFT + 5: RGB <= (a[4] & b[4]) ? COLOR_BOTH : (a[4]) ? COLOR_GRIDA : (b[4]) ? COLOR_GRIDB : COLOR_BACKGROUND;
								GAME_HSHIFT + 6: RGB <= (a[3] & b[3]) ? COLOR_BOTH : (a[3]) ? COLOR_GRIDA : (b[3]) ? COLOR_GRIDB : COLOR_BACKGROUND;
								GAME_HSHIFT + 7: RGB <= (a[2] & b[2]) ? COLOR_BOTH : (a[2]) ? COLOR_GRIDA : (b[2]) ? COLOR_GRIDB : COLOR_BACKGROUND;
								GAME_HSHIFT + 8: RGB <= (a[1] & b[1]) ? COLOR_BOTH : (a[1]) ? COLOR_GRIDA : (b[1]) ? COLOR_GRIDB : COLOR_BACKGROUND;
								GAME_HSHIFT + 9: RGB <= (a[0] & b[0]) ? COLOR_BOTH : (a[0]) ? COLOR_GRIDA : (b[0]) ? COLOR_GRIDB : COLOR_BACKGROUND;
								default:		 RGB <= COLOR_BACKGROUND;
							endcase
						else if (state_counter < RBORDER_END)
							RGB <= COLOR_BORDER;
						else
							RGB <= COLOR_BACKGROUND;
					end

					// draw bottom border
					else if (line_counter < BBORDER_END) begin
						if (state_counter < LMARGIN_END || state_counter >= RBORDER_END)
							RGB <= COLOR_BACKGROUND;
						else
							RGB <= COLOR_BORDER;
					end
					
					// draw bottom margin
					else
						RGB <= COLOR_BACKGROUND;
				end
				else begin
					state_counter <= 0;
					state <= S_hs_bporch;
				end
			end
		S_hs_bporch:
			begin
				if (state_counter == 0) begin
					if (line_counter > TBORDER_END
							&& line_counter < VGAME_END
							&& line_counter[3:0] == 0) begin
						
						GridA_buff <= GridA_buff << 10;
						GridB_buff <= GridB_buff << 10;
					end
				end
				if (state_counter < HS_BPORCH)
					state_counter <= state_counter + 1'b1;
				else begin
					state_counter <= 0;
					if (line_counter < SCREEN_HEIGHT)
						state <= S_hs_sync;
					else
						state <= S_vs_bporch;
				end
			end
		S_vs_bporch:
			begin
				if (state_counter < VS_BPORCH)
					state_counter <= state_counter + 1'b1;
				else begin
					state_counter <= 0;
					state <= S_vs_sync;
				end
			end
		default:
			begin
				state <= S_vs_sync;
				state_counter <= 0;
			end
		endcase
	end

endmodule
