`timescale 1ns / 1ps

module clockDiv(
    input sys_clk,          //1s 100M Hz
    input sys_rst_n,
    output reg clk_25M      // 1s 25M Hz
    );

reg counter_4;

 
always @(posedge sys_clk) begin
	if(sys_rst_n) begin
		counter_4 <= 0;
		clk_25M = 0;
	end else if(counter_4 == 1) begin
		counter_4 <= 0;
		clk_25M <= ~clk_25M;
	end else if(counter_4 == 0) begin
		counter_4 <= counter_4 + 1;
	end
end	
endmodule
