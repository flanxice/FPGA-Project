`timescale 1ns / 1ps

module clockDiv(
    input sys_clk,          //1s 100M Hz
    input sys_rst_n,
    output reg clk_25M      // 1s 25M Hz
    );

reg [1:0] counter;
always @(posedge sys_clk) begin
    if(sys_rst_n) begin
        clk_25M <= 0;
        counter <= 0;       
    end
    else begin 
        if(counter >= 3) begin 
            clk_25M <= ~clk_25M;
            counter <= 0;
        end
        else counter <= counter + 1;
    end
end
endmodule
