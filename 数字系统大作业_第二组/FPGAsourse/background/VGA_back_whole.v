`timescale 1ns / 1ps
// The whole VGA 
module VGA_out(
    input sys_clk, //25MHz
    input sys_rst_n,
    input [2:0] choise,
    //VGA
    output vga_hs,
    output vga_vs,
    output [11:0] vga_rgb);

//Wire define
wire vga_clk_w;
wire [11:0] pixel_data;
wire [9:0] pixel_x;
wire [9:0] pixel_y;

//****************************Main Code**************************
// 这样的话每个VGA输出都有个时钟分频
// 优化的时候可以将时钟分频拿出来
clockDiv clkdiv1(
      .sys_clk(sys_clk),         
      .sys_rst_n(sys_rst_n),
      .clk_25M(vga_clk_w));

vga_driver VGAdriver1(
    .vga_clk(vga_clk_w),   
    .sys_rst_n(sys_rst_n),
    .vga_hs(vga_hs),      // 行同步
    .vga_vs(vga_vs),      // 场同步
    .vga_rgb(vga_rgb),      //4+4+4 
    .pixel_data(pixel_data),    //像素点RGB data
    .pixel_x(pixel_x),       //像素点横坐标
    .pixel_y(pixel_y)        //像素点纵坐标
);
 
vga_display_back vgadisplay1(
    .vga_clk(vga_clk_w),
    .sys_rst_n(sys_rst_n),
    .pixel_x(pixel_x),
    .pixel_y(pixel_y),
    .choise(choise),
    .pixel_data(pixel_data));

endmodule