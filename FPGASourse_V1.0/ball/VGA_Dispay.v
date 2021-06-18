`timescale 1ns / 1ps
`include "Definition.h"
module VGA_Dispay(
    input clk, 
    input rst,
    input [3:0] bar_move_speed,
    input to_left1,
    input to_right1,
    input to_left2,
    input to_right2,
    output reg hs,
    output reg vs,
    output reg [3:0] Red,
    output reg [3:0] Green,
    output reg [3:0] Blue,
    output reg lose1,
    output reg lose2);
  
parameter PAL = 640;		
parameter LAF = 480;        
parameter PLD = 800;        
parameter LFD = 521;       
parameter HPW = 96;           
parameter HFP = 16;           
parameter VPW = 2;        
parameter VFP = 10;          
parameter UP_BOUND = 10;
parameter DOWN_BOUND = 480;  
parameter LEFT_BOUND = 20;  
parameter RIGHT_BOUND = 630;
parameter ball_r = 10;
reg [9:0] Hcnt;     
reg [9:0] Vcnt; 
reg clk_50M=0;   
wire clk_25M;
reg h_speed = `RIGHT;
reg v_speed = `UP; 
reg [9:0] up_pos1 = 450;
reg [9:0] down_pos1 = 480;
reg [9:0] left_pos1 = 230;
reg [9:0] right_pos1 = 430; 
reg [9:0] up_pos2 = 30;
reg [9:0] down_pos2 = 0;
reg [9:0] left_pos2 = 230;
reg [9:0] right_pos2 = 430;
reg [9:0] ball_x_pos = 330;
reg [9:0] ball_y_pos = 390;

clockDiv  ck1(.sys_clk(clk),.sys_rst_n(rst),.clk_25M(clk_25M));

always@(posedge(clk_25M)) begin
/*conditions of reseting Hcnter && Vcnter*/
    if( Hcnt == PLD-1 ) begin//have reached the edge of one line
        Hcnt <= 0; //reset the horizontal counter
        if( Vcnt == LFD-1 ) //only when horizontal pointer reach the edge can the vertical counter ++
            Vcnt <=0;
        else
            Vcnt <= Vcnt + 1;
    end
    else    Hcnt <= Hcnt + 1;

/*generate hs timing*/
    if( Hcnt == PAL - 1 + HFP)
        hs <= 1'b0;
    else if( Hcnt == PAL - 1 + HFP + HPW )
        hs <= 1'b1;

/*generate vs timing*/        
    if( Vcnt == LAF - 1 + VFP ) 
        vs <= 1'b0;
    else if( Vcnt == LAF - 1 + VFP + VPW )
        vs <= 1'b1;                    
end

always @ (posedge clk_25M)  begin  
/* if(rst) 
begin
ball_x_pos<=330;
ball_y_pos<=390;
h_speed = `RIGHT;
v_speed = `UP;
end*/
// Display the downside bar
if (Vcnt>=up_pos1 && Vcnt<=down_pos1&& Hcnt>=left_pos1 && Hcnt<=right_pos1||
    Vcnt<=up_pos2 && Vcnt>=down_pos2&& Hcnt>=left_pos2 && Hcnt<=right_pos2) 
begin  
    if (Vcnt <= 100) begin
        Red <= `ONES;  
        Green <= `ZEROS;  
        Blue <= `ZEROS; 
    end
    else if (Vcnt >= 350) begin
        Red <= `ZEROS;  
        Green <= `ZEROS;  
        Blue <= `ONES; 
    end
end  
else if ( (Hcnt - ball_x_pos)*(Hcnt - ball_x_pos) + (Vcnt - ball_y_pos)*(Vcnt - ball_y_pos) <= (ball_r * ball_r) ) 
begin  
    Red <= `ZEROS;  
    Green <= `ONES;  
    Blue <= `ZEROS;  
end  
else begin  
    if(Vcnt == 240 || Vcnt == 239) begin
        Red <= `ONES;  
        Green <= `ONES;  
        Blue <= `ONES; 
    end
    else if(((Hcnt - 320)*(Hcnt - 320) + (Vcnt - 240)*(Vcnt - 240) <= 11025) &&
        ((Hcnt - 320)*(Hcnt - 320) + (Vcnt - 240)*(Vcnt - 240) >= 10000)) begin
            Red <= `ONES;  
            Green <= `ONES;  
            Blue <= `ONES; 
        end
    else begin
        Red <= `ZEROS;  
        Green <= `ZEROS;  
        Blue <= `ZEROS; 
    end   
end  

end

always @ (posedge vs)  begin          
// movement of the bar
if (to_left1 && left_pos1 >= LEFT_BOUND) begin  
    left_pos1 <= left_pos1 - bar_move_speed;  
    right_pos1 <= right_pos1 - bar_move_speed;  
end  
else if(to_right1 && right_pos1 <= RIGHT_BOUND) begin          
    left_pos1 <= left_pos1 + bar_move_speed; 
    right_pos1 <= right_pos1 + bar_move_speed;  
end  
if (to_left2 && left_pos2 >= LEFT_BOUND)  begin  
    left_pos2 <= left_pos2 - bar_move_speed;  
    right_pos2 <= right_pos2 - bar_move_speed;  
end  
else if(to_right2 && right_pos2 <= RIGHT_BOUND) begin          
    left_pos2 <= left_pos2 + bar_move_speed; 
    right_pos2 <= right_pos2 + bar_move_speed;  
end  
//movement of the ball
if (v_speed == `UP) // go up 
    ball_y_pos <= ball_y_pos - bar_move_speed;  
else //go down
    ball_y_pos <= ball_y_pos + bar_move_speed;  
if (h_speed == `RIGHT) // go right 
    ball_x_pos <= ball_x_pos + bar_move_speed;  
else //go left
    ball_x_pos <= ball_x_pos - bar_move_speed;   

end 

always @ (negedge vs)  begin
    if (ball_y_pos <= UP_BOUND)   // Here, all the jugement should use >= or <= instead of ==
    begin   
        lose1<=0; 
        lose2<=1;
        v_speed <= 1;              // Because when the offset is more than 1, the axis may step over the line
    end
    else if (ball_y_pos >= (up_pos1 - ball_r) && ball_x_pos <= right_pos1 && ball_x_pos >= left_pos1)  
    begin
        v_speed <= 0;  
        lose2<=0;
    end
    else if (ball_y_pos <= (up_pos2 + ball_r) && ball_x_pos <= right_pos2 && ball_x_pos >= left_pos2)  
    begin
        v_speed <= 1;lose1<=0;  
    end
    else if (ball_y_pos >= down_pos1 && ball_y_pos < (DOWN_BOUND - ball_r))
    begin
        lose1<=1;
    end
    else if (ball_y_pos <= down_pos2 && ball_y_pos > (UP_BOUND + ball_r))
    begin
        lose2<=1;
    end
    else if (ball_y_pos >= (DOWN_BOUND - ball_r + 1))
    begin
        v_speed <= 0; 
        lose2<=0;
        lose1<=1;
    end
    else  
        v_speed <= v_speed;  

    if (ball_x_pos <= LEFT_BOUND)  
        h_speed <= 1;  
    else if (ball_x_pos >= RIGHT_BOUND)  
        h_speed <= 0;  
    else  
        h_speed <= h_speed;  
end       
endmodule
