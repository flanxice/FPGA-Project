`timescale 1ns / 1ps
`include "Definition.h"

// VGA Driver
module vga_driver(
    input vga_clk,      // VGA驱动时钟
    input sys_rst_n,    // 复位信号
    //VGA
    output vga_hs,      // 行同步
    output vga_vs,      // 场同步
    output [11:0] vga_rgb, //4+4+4
    
    input [11:0] pixel_data,    //像素点RGB data
    output [9:0] pixel_x,       //像素点横坐标
    output [9:0] pixel_y        //像素点纵坐标
);

// some parameters for sure in the reference Table 
parameter H_SYNC = 10'd96;
parameter H_BACK = 10'd48;
parameter H_DISP = 10'd640;
parameter H_FRONT = 10'd16;
parameter H_TOTAL = 10'd800;

parameter V_SYNC = 10'd2;
parameter V_BACK = 10'd33;
parameter V_DISP = 10'd480;
parameter V_FRONT = 10'd10;
parameter V_TOTAL = 10'd525;

// counters for H and V
reg [9:0] cnt_h;
reg [9:0] cnt_v;

wire vga_en; // 使能控制rgb数据输出
wire data_req;

//*******************************Main Code************************************
//VGA 行场同步信号
assign vga_hs = (cnt_h <= H_SYNC - 1'b1) ? 1'b0 : 1'b1;
assign vga_vs = (cnt_v <= V_SYNC - 1'b1) ? 1'b0 : 1'b1;

// 使能使RGB输出 // 范围内输出
assign vga_en = (((cnt_h >= H_SYNC + H_BACK) && (cnt_h < H_SYNC + H_BACK +H_DISP))
                &&((cnt_v >= V_SYNC + V_BACK) && (cnt_v < V_SYNC + V_BACK + V_DISP)))
                ? 1'b1 : 1'b0;

//在范围内RGB赋值
assign vga_rgb = vga_en ? pixel_data : 12'b0;

// 请求像素点颜色数据输入
assign data_req = (((cnt_h >= H_SYNC + H_BACK -1'b1) && (cnt_h < H_SYNC + H_BACK +H_DISP -1'b1))
                &&((cnt_v >= V_SYNC + V_BACK) && (cnt_v < V_SYNC + V_BACK + V_DISP)))
                ? 1'b1 : 1'b0;
// 像素点坐标
assign pixel_x = data_req ? (cnt_h - (H_SYNC + H_BACK -1'b1)) : 10'd0;
assign pixel_y = data_req ? (cnt_v - (V_SYNC + V_BACK -1'b1)) : 10'd0;

// H counter
always @(posedge vga_clk or posedge sys_rst_n) begin
    if(sys_rst_n)  cnt_h <= 10'd0;
    else begin
        if(cnt_h < H_TOTAL - 1'b1)  cnt_h <= cnt_h + 1'b1;
        else cnt_h <= 10'd0;
    end
end
// V counter
always @(posedge vga_clk or posedge sys_rst_n) begin
    if(sys_rst_n)  cnt_v <= 10'd0;
    else if(cnt_h == H_TOTAL - 1'b1) begin
        if(cnt_v < V_TOTAL - 1'b1)  cnt_v <= cnt_v + 1'b1;
        else cnt_v <= 10'd0;
    end
end
endmodule 