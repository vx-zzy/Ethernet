`timescale 1ns / 1ps

module ETH_TB(
    );

reg		clk								;
reg		rgmii_rx_clk							;
reg		rx_clk_delay							;
reg		rst_n									;
wire 	sys_clk_n								;
reg		[3:0]	rgmii_rd                		;
reg 			rgmii_rx_ctl 					;
wire	[3:0]	rgmii_td                		;
always#10 clk 	= ~ clk			;
always#4 rgmii_rx_clk 	= ~ rgmii_rx_clk		;
assign #1 rx_clk_delay 	= rgmii_rx_clk			;
initial begin

	clk = 0;
	rgmii_rx_clk = 0;
	rst_n = 0;
	#500 rst_n = 1;  //有pll且是同步复位的情况下，复位时间给长一点，保证pll时钟输出之后复位在结束
end

initial begin
    rgmii_rd	= 4'h0;
    rgmii_rx_ctl	= 0;	
	#500
	rgmii0_send_data_task(1);
	rgmii0_send_data_task(10);
	rgmii0_send_data_task(100);
	rgmii0_send_data_task(372);
	rgmii0_send_end_task();
end

task rgmii0_send_data_task;
    input [7:0] data;
begin
	@(posedge rgmii_rx_clk)begin 
		rgmii_rx_ctl = 1'b1;
		rgmii_rd = data[3:0];
	end
	@(negedge rgmii_rx_clk)
		rgmii_rd = data[7:4];
end
endtask
task rgmii0_send_end_task;
begin
	repeat(25)
	@(posedge rgmii_rx_clk) 
		rgmii_rx_ctl = 1'b0;
end
endtask
task send0_data_pkt;
	input logic[15:0] len;  //输入像素点数量
begin
	for(int i = 0; i < 7; i++)
		rgmii0_send_data_task(8'h55);
	rgmii0_send_data_task(8'hd5);
	for(int i = 0; i < 4; i++)rgmii0_send_data_task(i[7:0]);	//发送行列坐标
	rgmii0_send_data_task(len[15:8]);
	rgmii0_send_data_task(len[7:0]);
	rgmii0_send_data_task(8'h08);  		//预留
	rgmii0_send_data_task(8'h88);
	for(int i = 0; i < len * 4; i++)rgmii0_send_data_task(i[7:0]);
	rgmii0_send_end_task();
end
endtask
top top_inst
(
	.clk		(	clk			),
	.rst_n		(	rst_n			),
//	.mdc		(	mdc			),
//    .mdio       (   mdio        ),
//	.uart_tx		(	uart_tx			),
//	.uart_rx		(	uart_rx			),
	.rgmii_rd			( rgmii_rd			),
	.rgmii_td			( rgmii_td			),
	.rgmii_rx_clk		(	rx_clk_delay			),
	.rgmii_rx_ctl		(	rgmii_rx_ctl			),
	.rgmii_tx_clk		(	rgmii_tx_clk			),
	.rgmii_tx_ctl		(	rgmii_tx_ctl			),
	.phy_rst		(	phy_rst			),
	.led		(	led			)
);
endmodule
