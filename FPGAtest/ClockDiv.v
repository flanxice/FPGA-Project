`timescale 1ns / 1ps

module clockDiv(
    input sys_clk,          //1s 100M Hz
    input sys_rst_n,
    output reg clk25Hz      // 1s 25M Hz
    // output reg clk2ms,
    // output reg clk1s
    );
reg [25:0] counts25Hz;

always @(posedge sys_clk or posedge sys_rst_n) begin
    if(sys_rst_n) begin
        counts25Hz <= 0;
        clk25Hz <= 0;
    end
    else if(counts25Hz >= 25000000) begin
        clk25Hz <= ~clk25Hz;
        counts25Hz <= 0;
    end
    else 
        counts25Hz <= counts25Hz + 1'b1;   
end

endmodule
