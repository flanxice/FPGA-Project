`timescale 1ns / 1ps

module DP(
    input sys_clk,
    input sys_rst_n,
    input left_in, right_in, up_in, down_in,
    input left_in1, right_in1, up_in1, down_in1,
    input [3:0] speedcontrol,
    input [1:0] vgaMUX,
    input [1:0] choice,
    input exitbutton,
    // feed back
    output button_up, button_down, button_left, button_right,
    output exit,
    // OUTPUT
    output reg [3:0] seg_select,
    output reg [6:0] seg_LED,
    output reg [11:0] RGB,
    output reg vga_h,
    output reg vga_v);

wire clk_25M;
wire [3:0] red, green, blue;
wire [1:0] choice;
wire [11:0] RGB0, RGB2, RGB3;
reg [11:0] RGB1;
wire [6:0] seg_LED1, seg_LED2;
wire [3:0] seg_select1, seg_select2;
wire vga_h0, vga_h1, vga_h2, vga_h3;
wire vga_v0, vga_v1, vga_v2, vga_v3;
wire left, right, up, down, left1, right1, up1, down1;

Button b1(.sys_clk(sys_clk),.sys_rst_n(sys_rst_n),.button_in(left_in),.stable_out(left));
Button b2(.sys_clk(sys_clk),.sys_rst_n(sys_rst_n),.button_in(right_in),.stable_out(right));
Button b3(.sys_clk(sys_clk),.sys_rst_n(sys_rst_n),.button_in(up_in),.stable_out(up));
Button b4(.sys_clk(sys_clk),.sys_rst_n(sys_rst_n),.button_in(down_in),.stable_out(down));
Button b5(.sys_clk(sys_clk),.sys_rst_n(sys_rst_n),.button_in(left_in1),.stable_out(left1));
Button b6(.sys_clk(sys_clk),.sys_rst_n(sys_rst_n),.button_in(right_in1),.stable_out(right1));
Button b7(.sys_clk(sys_clk),.sys_rst_n(sys_rst_n),.button_in(up_in1),.stable_out(up1));
Button b8(.sys_clk(sys_clk),.sys_rst_n(sys_rst_n),.button_in(down_in1),.stable_out(down1));

assign button_up = up;
assign button_down = down;
assign button_left = left;
assign button_right = right;
assign exit = (sys_rst_n ? 0 : exitbutton);

always @(*) begin
    RGB1 = {red, green, blue};
end


// clockDiv clkdivmain(.sys_clk(sys_clk),.sys_rst_n(sys_rst_n),.clk_25M(clk_25M));
VGA_out vgamain(.sys_clk(sys_clk),.sys_rst_n(sys_rst_n),.choise(choice),.vga_hs(vga_h0),.vga_vs(vga_v0),.vga_rgb(RGB0));
SBgame game1(.mclk(sys_clk),.rst(sys_rst_n),.to_left1(left),.to_right1(right),.to_left2(left1),.to_right2(right2),.bar_move_speed(speedcontrol),
    .HSync(vga_h1),.VSync(vga_v1),.OutBlue(blue),.OutGreen(grean),.OutRed(red),.seg_select(seg_select1),.seg_LED(seg_LED1));
top_greedy_snake game2(.clk(sys_clk),.rst(sys_rst_n),.left(left),.right(right),.up(up),.down(down),.hsync(vga_h2),.vsync(vga_v2),
    .color_out(RGB2),.seg_out(seg_LED2),.sel(seg_select2));

// 0 background ; 1 game1 ; 2 game2;
always @(*) begin
    case (vgaMUX)
        0 : begin
            {RGB, vga_h, vga_v} = {RGB0, vga_h0, vga_v0};
            {seg_select, seg_LED} = 11'b00000000000;
        end
        1 : begin
            {RGB, vga_h, vga_v} = {RGB1, vga_h1, vga_v1};
            {seg_select, seg_LED} = {seg_select1, seg_LED1};
        end
        2 : begin
            {RGB, vga_h, vga_v} = {RGB3, vga_h3, vga_v3};
            {seg_select, seg_LED} = {seg_select2, seg_LED2};
        end
    endcase
    
end
endmodule