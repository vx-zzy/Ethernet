`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:02:27 05/11/2019 
// Design Name: 
// Module Name:    uart_rx 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//9600  	bps = 10461
//115200	bps = 868
//460800    bps = 217
//////////////////////////////////////////////////////////////////////////////////
module uart_rx#(
		parameter bps 	= 	10461		,
		parameter bps_2 = 	bps / 2
	)(
		input 				clk			,
		input 				rst			,
		input 				rx			,
		output reg	[7:0]	data_out	,
		output reg 			data_vld
    );
	
	reg flag;
	reg rx_r0;
	reg rx_r1;
	reg rx_r2;
	reg[13:0] cnt1;
	reg[3:0] cnt2;
	assign rx_start = !rx_r1 && rx_r2;
	always@(posedge clk)begin
		if(rst)begin
			rx_r0 <= 1'b1;
			rx_r1 <= 1'b1;
			rx_r2 <= 1'b1;
		end
		else begin
			rx_r0 <= rx;
			rx_r1 <= rx_r0;
			rx_r2 <= rx_r1;		
		end
	end
			
	always@(posedge clk)begin
		if(rst)
			flag <= 0;
		else
		if(rx_start)
			flag <= 1;
		else
		if(end_cnt2)
			flag <= 0;
	end
	
	always@(posedge clk)begin
		if(rst)
			cnt1 <= 0;
		else begin
			if(add_cnt1)
				if(end_cnt1)
					cnt1 <= 0;
				else
					cnt1 <= cnt1 + 1'b1;
		end
	end
	assign add_cnt1 = flag;
	assign end_cnt1 = add_cnt1 && cnt1 == bps - 1;

	always@(posedge clk)begin
		if(rst)
			cnt2 <= 0;
		else begin
			if(add_cnt2)
				if(end_cnt2)
					cnt2 <= 0;
				else
					cnt2 <= cnt2 + 1'b1;   //如果不给1'b1会报warning
		end
	end
	assign add_cnt2 = end_cnt1;
	assign end_cnt2 = add_cnt2 && cnt2 == 9 - 1;

	always@(posedge clk)begin
		if(rst)
			data_vld <= 1'b0;
		else
		if(end_cnt2)
			data_vld <= 1'b1;
		else
			data_vld <= 1'b0;
	end
	assign vld = add_cnt1 && (cnt1 == bps_2 - 1) && cnt2 >= 1 && cnt2 < 9;
	always@(posedge clk)begin
		if(rst)
			data_out <= 8'd0;
		else 
		if(vld)//flag && cnt == 0
			data_out[cnt2 - 1] <= rx_r2;
		else
		if(data_vld)
			data_out <= 8'd0;
	end	
	


endmodule
