`timescale 1ns / 1ps

module DP(
    input sys_clk,
    input sys_rst_n,
    input [2:0] state,
    output wire [11:0] RGB,
    output wire vga_h,
    output wire vga_v);

// wire [11:0] RGB0, RGB1, RGB2, RGB3;
// wire vga_h0, vga_h1, vga_h2, vga_h3;
// wire vga_v0, vga_v1, vga_v2, vga_v3;

VGA_out vgamain(.sys_clk(sys_clk),.sys_rst_n(sys_rst_n),.choise(state),.vga_hs(vga_h),.vga_vs(vga_v),.vga_rgb(RGB));  


endmodule