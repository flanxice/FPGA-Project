`timescale 1ns / 1ps


module clkrecv(
    input sys_clk,
    input rst,
    output reg clk_1020us,
    output reg clk_6us);

reg [9:0] cnt_clk_6us;
reg [15:0] cnt_1020us;

always @(posedge sys_clk)   //定义两个时钟，周期分别为6us和1020us
begin
    if(rst) begin
        cnt_clk_6us <= 0;
        clk_6us <= 0;
        cnt_1020us <= 0;
        clk_1020us <= 0;
    end
    else begin
        if(cnt_clk_6us == (150-1)) begin    //300
            cnt_clk_6us <= 0;
            clk_6us <= ~clk_6us;   //按位取反
        end
        else
            cnt_clk_6us <= cnt_clk_6us + 1;

        if(cnt_1020us == (25500-1)) begin    //  110 0011 1001 1100  周期1020us //51000
            cnt_1020us <= 0;
            clk_1020us <= ~clk_1020us;   //按位取反
        end
        else
            cnt_1020us <= cnt_1020us + 1;
    end   
end
endmodule