`timescale 1ns / 1ps

module Button(
    input sys_clk,
    input sys_rst_n,
    input button_in,
    output stable_out);

reg r1,r2,r3;
wire in_stable;

// 去抖动
debounce db1(
    .sys_clk(sys_clk),
    .noisy(button_in),
    .sys_rst_n(sys_rst_n),
    .stable_out(in_stable));

always @(posedge sys_clk or posedge sys_rst_n) begin
    if(sys_rst_n) begin
        r1 <= 1'b0;
        r2 <= 1'b0;
        r3 <= 1'b0;
    end
    else begin
        r1 <= in_stable;
        r2 <= r1;
        r3 <= r2;
    end 
end
assign stable_out = ~r3 & r2;
endmodule


// clear debounce module
module debounce(
    input sys_clk,
    input noisy,
    input sys_rst_n,
    output reg stable_out);
    
//parameter NDELAY = 650000;
parameter NDELAY = 0; // For simulation
parameter NBITS = 20;

reg [NBITS-1:0] count;
reg xnew;

always @(posedge sys_clk or posedge sys_rst_n) begin
    if(sys_rst_n) begin
        xnew <= noisy;
        stable_out <= noisy;
        count <= 0;
    end
    else if(noisy != xnew)  begin
        xnew <= noisy;
        count <= 0;
    end
    else if(count == NDELAY)    stable_out <= xnew;
    else count <= count + 1;
end
endmodule
