`timescale 1ns / 1ps
`include "Definition.h"
// VGA����ģ��  ���ݵ�ǰɨ�赽�ĵ�����һ���������Ӧ��ɫ

module VGA_Control
(
	input clk,
	input rst,
	
	input [1:0] snake,
	input [5:0] apple_x,
	input [4:0] apple_y,
	output [9:0] x_pos,
	output [9:0] y_pos,	
	output hsync,
	output vsync,
	output reg [11:0] color_out
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
	
localparam NONE = 2'b00;
localparam HEAD = 2'b01;
localparam BODY = 2'b10;
localparam WALL = 2'b11;

localparam HEAD_COLOR = 12'b0000_1111_0000;
localparam BODY_COLOR = 12'b0000_1111_1111;
	
	
reg [3:0]lox;
reg [3:0]loy;

//VGA 行场同步信号
assign hsync = (cnt_h <= H_SYNC - 1'b1) ? 1'b0 : 1'b1;
assign vsync = (cnt_v <= V_SYNC - 1'b1) ? 1'b0 : 1'b1;
assign x_pos = cnt_h - 144;
assign y_pos = cnt_v - 35;

// H counter
always @(posedge clk or posedge rst) begin
    if(rst)  cnt_h <= 10'd0;
    else begin
        if(cnt_h < H_TOTAL - 1'b1)  cnt_h <= cnt_h + 1'b1;
        else cnt_h <= 10'd0;
    end
end
// V counter
always @(posedge clk or posedge rst) begin
    if(rst)  cnt_v <= 10'd0;
    else if(cnt_h == H_TOTAL - 1'b1) begin
        if(cnt_v < V_TOTAL - 1'b1)  cnt_v <= cnt_v + 1'b1;
        else cnt_v <= 10'd0;
    end
end

always @(posedge clk) begin 	
if(x_pos >= 0 && x_pos < 640 && y_pos >= 0 && y_pos < 480) begin 
    lox = x_pos[3:0];
    loy = y_pos[3:0];						
    if(x_pos[9:4] == apple_x && y_pos[9:4] == apple_y)
        case({loy,lox})
            8'b0000_0000: color_out = `BLACK;
        default: color_out = `YELLOW;
        endcase						
    else if(snake == NONE)
        color_out = `BLACK;
    else if(snake == WALL)
        color_out = 3'b101;
    else if(snake == HEAD|snake == BODY) begin   //���ݵ�ǰɨ�赽�ĵ�����һ���������Ӧ��ɫ
        case({lox,loy})
            8'b0000_0000:color_out = `BLACK;
            default:color_out = (snake == HEAD) ?  HEAD_COLOR : BODY_COLOR;
        endcase
    end
end
else color_out = `BLACK;
end
endmodule