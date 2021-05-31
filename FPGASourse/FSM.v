`timescale 1ns / 1ps

// parameter   state_game1 = 0,            state_game1_in = 1,
//             state_game2 = 2,            state_game2_in = 3,
//             state_game3 = 4,            state_game3_in = 5,
//             state_exit  = 6,            state_exit_in  = 7;

module FSM(
    input sys_clk,
    input sys_rst_n,
    input button_up_in,
    input button_down_in,
    input button_left_in,
    input button_right_in, // 兼确定
    //VGA out
    // output wire [11:0] RGB,
    // output wire vga_h,
    // output wire vga_v,
    //Test
    output reg [2:0] state_output);

// State Define
parameter   state_game1 = 0,            state_game1_in = 4,
            state_game2 = 1,            state_game2_in = 5,
            // state_game3 = 4,            state_game3_in = 5,
            state_exit  = 2,            state_exit_in  = 3;

reg [2:0] state;
reg game_exit;  // control to exit in_state
reg background; // define bits

wire vga_clk;
wire button_up,button_down,button_left,button_right;

// 时钟分频
//clockDiv clockDiv1(
//    .sys_clk(sys_clk),          //1s 100M Hz
//    .sys_rst_n(sys_rst_n),
//    .clk_25M(vga_clk));

Button button_up1(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .button_in(button_up_in),
    .stable_out(button_up));
Button button_down1(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .button_in(button_down_in),
    .stable_out(button_down));
Button button_left1(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .button_in(button_left_in),
    .stable_out(button_left));
Button button_right1(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .button_in(button_right_in),
    .stable_out(button_right));


always @(posedge sys_clk) begin
    if (sys_rst_n) begin
        state <= state_game1;
        game_exit = 1'b0;
    end
    else case (state)
        state_game1 : begin
            if(button_down) state <= state_game2;
            else if(button_up)  state <= state_exit;
            else if(button_right)  state <= state_game1_in;
            else state <= state_game1;
        end
        state_game2 : begin
            if(button_down) state <= state_exit;
            else if(button_up)  state <= state_game1;
            else if(button_right)  state <= state_game2_in;
            else state <= state_game2;
        end
        state_exit : begin
            if(button_down) state <= state_game1;
            else if(button_up)  state <= state_game2;
            else if(button_right)  state <= state_exit_in;
            else state <= state_exit;
        end
        state_game1_in : begin
            if(game_exit) begin
                state <= state_game1;
                game_exit <= 1'b0;
            end
            else state <= state_game1_in;
        end
        state_game2_in : begin
            if(game_exit) begin
                state <= state_game1;
                game_exit <= 1'b0;
            end
            else state <= state_game2_in;
        end
        state_exit_in  : state <= state_exit_in;
    endcase               
end    

// OutPut
always @(state) begin
    case (state)
        state_game1      : begin
            state_output = state;
        end
        state_game2      : begin
            state_output = state;
        end  
        state_game1_in   : begin
            state_output = state;
            // background = //
        end
        state_game2_in   : begin
            state_output = state;
            // background = //
        end
        state_exit       : begin
            state_output = state;
        end
        state_exit_in    : begin
            state_output = state;
            // background = //
        end
    endcase
end

// VGA_out vga0(
//     .vga_clk(sys_clk),
//     .sys_rst_n(sys_rst_n),
//     .choise(state),
//     //VGA
//     .vga_hs(vga_h),
//     .vga_vs(vga_v),
//     .vga_rgb(RGB));                  
endmodule
