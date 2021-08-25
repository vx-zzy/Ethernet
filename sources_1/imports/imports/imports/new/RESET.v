`timescale 1ns / 1ps

module RESET#(
		parameter rst_type  = 	 "sync"	,
		parameter clk_num 	=	 1
)(
		input			[clk_num - 1:0]		clk		,
		input								rst_n	,
		output			[clk_num - 1:0]		rst	
    );
	reg			rst_r		[clk_num -1:0];
	reg	[1:0]	rst_sync	[clk_num -1:0];
	genvar i		;
	generate 
		for(i = 0; i < clk_num ;i = i + 1) begin
			if(rst_type == "async")begin
				always @(posedge clk[i] or negedge rst_n)begin
					if(!rst_n)
						rst_sync[i] <= 2'b11;   //决定复位信号的脉宽
					else
						rst_sync[i] <= {rst_sync[i][0], 1'b0};
				end
			end 
			else begin
				always @(posedge clk[i])begin
					rst_sync[i] <= {rst_sync[i][0], !rst_n};
				end				
			end
			assign rst[i]		=		rst_sync[i][1]		;
		end
	endgenerate

	
endmodule