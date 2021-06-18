`timescale 1ns / 1ps

module PS2_recv(
    input sys_clk,
    input rst,
    input spi_miso, // USB to FPGA
    output wire [9:0] data, // 1 代表按下
    // output wire [3:0] pss, // 轮盘控制
    output reg smosi,//反馈给手柄
    output reg scs,
    output reg sclk,
    output [7:0] ledout
//    output clk_1020us,
//    output clk_6us
//    output reg trig,
//    output reg [3:0] count_for_trig
//    output reg led
);//test if feed back

wire clk_1020us;
wire clk_6us;
//reg pss_rx, pss_ry, pss_lx, pss_ly;
//wire [9:0] data;
//wire [7:0] ledout;
reg select, start, up, down, left, right, up1, down1, left1, right1;

reg [3:0] count_for_trig = 0;
reg trig;
reg [7:0] count_trig = 0;
reg [3:0] bytecount;
reg [7:0] led;

assign data = rst ? 10'd0 : ~{select, start, up, down, left, right, up1, down1, left1, right1};
assign ledout = rst ? 8'd0 : led;
// assign pss = rst ? 4'd0 : {pss_rx, pss_ry, pss_lx, pss_ly};

clkrecv recvclk1(.sys_clk(sys_clk),.rst(rst),
    .clk_1020us(clk_1020us),.clk_6us(clk_6us));

always @(posedge clk_1020us or posedge rst) begin
if(rst) begin
    count_for_trig <= 0;
end
else begin
    count_for_trig <= count_for_trig + 1;
    if (count_for_trig == 4'b0001)   
        trig <= 0;
    else if (count_for_trig == 4'b0010)   //trig拉低1020us
        trig <= 1;
    else if (count_for_trig == 4'b1010)
        count_for_trig <= 4'b0000;
end
end

always @(negedge clk_6us or posedge rst) begin
if(rst) begin
    sclk <= 1;
end
else begin
    if(trig == 0) begin 
        scs <= 0;      
        count_trig <= count_trig + 1;
/*********************************************recording********************************************************/
// byte1 1~16       FPGA to USB     0X01 : 0000_0001                                (1,3,5,7,9,11,13,15)
// byte2 20~35      FPGA to USB     0X42 : 0100_0010                                (20,22,24,26,28,30,32,34)
// byte3 39~54      USB to FPGA     0X5A : 0101_1010
// byte4 58~73      USB to FPGA     {select, _, _, start, up, right, down, left}    (58,60,62,64,66,68,70,72)
// byte5 77~92      USB to FPGA     {_, _, _, _, up_r, right_r, down_r, left_r}
// byte6 96~111     USB to FPGA     PSS_RX  =>  0X00 : left ; 0XFF : right
// byte7 115~130    USB to FPGA     PSS_RY  =>  0X00 : up   ; 0XFF : down
// byte8 134~149    USB to FPGA     PSS_LX  =>  0X00 : left ; 0XFF : right
// byte9 153~168    USB to FPGA     PSS_LY  =>  0X00 : up   ; 0XFF : down
        if ((0<count_trig)&(count_trig<17))   //byte1
            sclk<=~sclk;
        else if ((19<count_trig)&(count_trig<36))  //byte2
            sclk<=~sclk;
        else if ((38<count_trig)&(count_trig<55))  //byte3
            sclk<=~sclk;
        else if ((57<count_trig)&(count_trig<74))  //byte4
            sclk<=~sclk;
        else if ((76<count_trig)&(count_trig<93))  //byte5
            sclk<=~sclk;
        else if ((95<count_trig)&(count_trig<112))  //byte6
            sclk<=~sclk;
        else if ((114<count_trig)&(count_trig<131))  //byte7
            sclk<=~sclk;
        else if ((133<count_trig)&(count_trig<150))  //byte8
            sclk<=~sclk;
        else if ((152<count_trig)&(count_trig<169))  //byte9
            sclk<=~sclk;

//通过波形图可以看出莫斯一共拉高了三次，每次持续12us，因为只需要发送一个0x01和0x42
// USB to FPGA
        // 0b0000_0001
        if (count_trig<2)
            smosi <= 1;
        else if ((20<count_trig)&(count_trig<23))
            smosi <= 1;
        else if ((30<count_trig)&(count_trig<33))
            smosi <= 1;
        else 
            smosi<=0;
        // test if feedback
        if(count_trig == 39) led[7] = spi_miso;         //0
        else if(count_trig == 41) led[6] = spi_miso;    //1
        else if(count_trig == 43) led[5] = spi_miso;    //0
        else if(count_trig == 45) led[4] = spi_miso;    //1
        else if(count_trig == 47) led[3] = spi_miso;    //1
        else if(count_trig == 49) led[2] = spi_miso;    //0
        else if(count_trig == 51) led[1] = spi_miso;    //1
        else if(count_trig == 53) led[0] = spi_miso;    //0

////////////// read select,start,up,right,down,left and so on///////////
        if(count_trig == 58)        select <= spi_miso;
        else if(count_trig == 64)   start <= spi_miso;
        else if(count_trig == 67)   up1 <= spi_miso;    //66
        else if(count_trig == 69)   right1 <= spi_miso;
        else if(count_trig == 71)   down1 <= spi_miso;
        else if(count_trig == 73)   left1 <= spi_miso;

        else if(count_trig == 85)   up <= spi_miso;
        else if(count_trig == 87)   right <= spi_miso;
        else if(count_trig == 89)   down <= spi_miso;
        else if(count_trig == 91)   left <= spi_miso;
//////////////读取 6789 bytes////////////////////////
        // else if(count_trig == 96)   pss_rx <= spi_miso; //0 left ;//1 right;
        // else if(count_trig == 115)  pss_ry <= spi_miso; //0 up ;//1 down;
        // else if(count_trig == 134)  pss_lx <= spi_miso; //0 left ;//1 right;
        // else if(count_trig == 153)  pss_ly <= spi_miso; //0 up ;//1 down;
    end

    else if(trig == 1)   //不通讯时（即trig=1时）cs信号拉高，clk信号拉高
    begin
        count_trig <= 0;
        scs <= 1;
        sclk <= 1;
//        {select, start, up, down, left, right, up1, down1, left1, right1} <= 10'b11_1111_1111;
    end
end
end
endmodule