`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/18 17:55:02
// Design Name: 
// Module Name: SIM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ps2SIM();

reg sys_clk,rst,spi_miso;
wire [9:0] data;
wire smosi,scs,sclk;
wire [7:0] ledout;
//wire clk_1020us;
//wire clk_6us;
//wire trig;
//wire [3:0] count_for_trig;

PS2_recv ps2(
.sys_clk(sys_clk),
.rst(rst),
.spi_miso(spi_miso),.data(data),.ledout(ledout),
            .smosi(smosi),.scs(scs),
.sclk(sclk));

always #1 sys_clk = ~sys_clk;
initial begin 
    sys_clk = 0;
    rst = 1;
    #10;
    rst = 0;
    #10000; 
end
endmodule
