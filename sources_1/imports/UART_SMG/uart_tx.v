`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:33:38 05/11/2019 
// Design Name: 
// Module Name:    uart_tx 
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
//460800    bps = 218
//////////////////////////////////////////////////////////////////////////////////
module uart_tx #(
		parameter	bps	=	10461
)
(
		input 				clk		,
		input 				rst		,
		input		[7:0]	data_in	,
		input 				tx_vld	,
		output reg 			tx		,
		output reg 			tx_rdy
    );
	reg flag;
	reg[13:0] cnt1;
	reg[3:0] cnt2;
	reg[9:0] data;
	
	always@(posedge clk)begin
		if(rst)
			flag <= 0;
		else
		if(tx_vld)//且rdy == 1
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
	assign end_cnt2 = add_cnt2 && cnt2 == 10 - 1;

	always@* begin  //组合逻辑
		if(tx_vld)
			tx_rdy = 0;
		else
		if(flag)
			tx_rdy = 0;
		else
			tx_rdy = 1;
	end

	always@(posedge clk)begin//
		if(rst)
			tx <= 1;
		else 
		if(flag)//flag && cnt == 0
			tx <= data[cnt2];
		else
			tx <= 1;
	end	
	
	always@(posedge clk)begin
		if(rst)
			data <= 10'd0;
		else
		if(tx_vld)//且rdy == 1
			data <= {1'b1, data_in, 1'b0};//高低位顺序注意
		else
		if(end_cnt2)
			data <= 10'd0;
	end
endmodule
