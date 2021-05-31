`timescale 1ns / 1ps

module Main(
    input sys_clk,
    input sys_rst_n,
    input button_up_in,
    input button_down_in,
    input button_left_in,
    input button_right_in, // 兼确定
    //VGA out
    output wire [11:0] RGB,
    output wire vga_h,
    output wire vga_v
    //Test
    // output reg [2:0] state_output
    );
    
wire [1:0] state_output;

FSM FSM1(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .button_up_in(button_up_in),
    .button_down_in(button_down_in),
    .button_left_in(button_left_in),
    .button_right_in(button_right_in), // 兼确定
    .state_output(state_output));

DP DP1(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .state(state_output),
    .RGB(RGB),
    .vga_h(vga_h),
    .vga_v(vga_v));


endmodule