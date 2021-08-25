`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/09 21:18:52
// Design Name: 
// Module Name: tb
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

module testbench();

reg		clk	;
reg		rgmii_rx_clk	;
reg		rst_n	;


always#5 clk = ~ clk;
always#5 rgmii_rx_clk = ~ rgmii_rx_clk;

initial begin

	clk = 0;
	rgmii_rx_clk = 0;
	rst_n = 0;
	#50 rst_n = 1;


end
top top_inst
(
	.clk		(	clk			),
	.rst_n		(	rst_n			),
//	.mdc		(	mdc			),
//    .mdio       (   mdio        ),
//	.uart_tx		(	uart_tx			),
//	.uart_rx		(	uart_rx			),
	.rgmii_rx_clk		(	rgmii_rx_clk			),
	.rgmii_rx_ctl		(	rgmii_rx_ctl			),
	.rgmii_tx_clk		(	rgmii_tx_clk			),
	.rgmii_tx_ctl		(	rgmii_tx_ctl			),
	.phy_rst		(	phy_rst			),
	.led		(	led			)
);
endmodule
