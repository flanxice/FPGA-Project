`timescale 1ns / 1ps

module seg(
    input clk,
	 input rst,
	 input lose1,
	 input lose2,
    output reg [3:0] select,
    output reg [6:0] seg
    );
    reg [3:0] num0 = 4'b0;
    reg [3:0] num1 = 4'b0;
    reg [3:0] num2 = 4'b0;
    reg [3:0] num3 = 4'b0;
    reg [1:0] cnt = 0;
    reg [8:0] clk_cnt = 0;
    reg sclk = 0;
    always@(posedge clk)
    begin
        if(clk_cnt ==350)
        begin
            sclk <= ~sclk;
            clk_cnt <= 0;
        end
        else
            clk_cnt <= clk_cnt + 1;
    end
    wire [6:0] out0;
    wire [6:0] out1;
    wire [6:0] out2;
    wire [6:0] out3;
    seg_decoder seg0(
        .clk(clk),
        .num(num0),
        .code(out0)
        );
    
      seg_decoder seg1(
        .clk(clk),
        .num(10),
        .code(out1)
        );
    
    seg_decoder seg2(
        .clk(clk),
        .num(11),
        .code(out2)
        );
    
    seg_decoder seg3(
        .clk(clk),
        .num(num3),
        .code(out3)
        );
        always@(posedge sclk)
        begin
            if(rst) //high active
            begin
                cnt <= 0;
            end
            else
            begin
                case(cnt)
                2'b00:
                begin
                    seg <= out0;
                    select <= 4'b0111;
                end    
                2'b01:
                begin
                    seg <= out1;
                    select <= 4'b1011;
                end
                2'b10:
                begin
                    seg <= out2;
                    select <= 4'b1101;
                end
                2'b11:
                begin
                    seg <= out3;
                    select <= 4'b1110;
                end
                default:
                begin
                    seg <= seg;
                    select <= select;
                end
                endcase
                cnt <= cnt + 1;    
                if(cnt == 2'b11)
                    cnt<=0;
            end
        end
        always@(posedge lose1 or posedge rst)
        begin
            if(rst)
            begin
                num0 <= 0;
            end
            else if(num0 != 5&&num3!=5)
            num0=num0+1;
            end
          always@(posedge lose2 or posedge rst)
                   begin
                       if(rst)
                       begin
                           num3 <= 0;
                       end
                       else if(num0!=5&&num3 != 5)
                       num3=num3+1;
                       end 
endmodule
