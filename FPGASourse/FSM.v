`timescale 1ns / 1ps

// parameter   state_game1 = 0,            state_game1_in = 1,
//             state_game2 = 2,            state_game2_in = 3,
//             state_game3 = 4,            state_game3_in = 5,
//             state_exit  = 6,            state_exit_in  = 7;

module FSM(
    input sys_clk,
    input sys_rst_n,
    input button_up,
    input button_down,
    input button_left,
    input button_right, // 兼确定
    input game_exit,
    output reg [1:0] vgaMUX, // 0 background ; 1 game1 ; 2 game2;
    output reg [1:0] choice); // 0 back_game1 ; 2 back_game_2 ; 3 back_exit ; 4 back_exit_in;

// State Define
parameter   state_game1 = 0,            state_game1_in = 4,
            state_game2 = 1,            state_game2_in = 5,
            state_exit  = 2,            state_exit_in  = 3;

reg [2:0] state;
//reg game_exit;  // control to exit in_state
// reg background; // define bits

always @(posedge sys_clk) begin
    if (sys_rst_n) begin
        state <= state_game1;
//        game_exit = 1'b0;
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
            end
            else state <= state_game1_in;
        end
        state_game2_in : begin
            if(game_exit) begin
                state <= state_game1;
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
            {choice, vgaMUX} = 4'b0000;
        end
        state_game2      : begin
            {choice, vgaMUX} = 4'b0100;
        end  
        state_game1_in   : begin
            {choice, vgaMUX} = 4'b0001;
        end
        state_game2_in   : begin
            {choice, vgaMUX} = 4'b0010;
        end
        state_exit       : begin
            {choice, vgaMUX} = 4'b1000;
        end
        state_exit_in    : begin
            {choice, vgaMUX} = 4'b1100;
        end
    endcase
end         
endmodule
