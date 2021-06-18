`timescale 1ns / 1ps

module Main(
    input sys_clk,
    input sys_rst_n,
    input left_in, right_in, up_in, down_in,
//    input left_in1, right_in1, up_in1, down_in1,
    input [3:0] speedcontrol, 
    input exitbutton, 
    input gamein_rst,
    //VGA out
    output [11:0] RGB,
    output vga_h,
    output vga_v,
    output [3:0] seg_select,
    output [6:0] seg_LED,
    output led
    //Test
    // output reg [2:0] state_output
    );

wire up,down,left,right;
wire [1:0] vgaMUX;
wire [2:0] choice;
wire exit;

FSM FSM1(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .button_up(up),
    .button_down(down),
    .button_left(left),
    .button_right(right), // 兼确定
    .game_exit(exit),
    .vgaMUX(vgaMUX),
    .choice(choice));

DP DP1(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .left_in(left_in), .right_in(right_in), .up_in(up_in), .down_in(down_in),
//    .left_in1(left_in1), .right_in1(right_in1), .up_in1(up_in1), .down_in1(down_in1),
    .speedcontrol(speedcontrol),
    .vgaMUX(vgaMUX),
    .choice(choice),
    .button_up(up), .button_down(down), .button_left(left), .button_right(right),
    .exitbutton(exitbutton),
    .gamein_rst(gamein_rst),
    .exit(exit),
    .seg_select(seg_select),
    .seg_LED(seg_LED),
    .RGB(RGB),
    .vga_h(vga_h),
    .vga_v(vga_v),
    .ledtetris(led));

endmodule