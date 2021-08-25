/*
 * @Author: ZhiyuanZhao
 * @Description: 可以将多位宽输入或输出由串口接收或发送
 * @Date: 2020-12-07 16:59:45
 * @LastEditTime: 2020-12-11 17:08:57
 */
`timescale 1ns / 1ps

module uart_config #(
		parameter 	bps 	= 868		,
		parameter	tx_w	= 2			,
		parameter	rx_w	= 4			
	)
	(
		input 							clk		    ,
		input 							rst		    ,
		input 							rx		    ,
		input 							uart_txen	,
		input 		 [tx_w*8-1:0]		tx_data	    ,
		output	reg						rdy			,
        output  reg             		uart_rxen   ,
        output  reg  [rx_w*8-1:0]     	rx_data     ,
		output 							tx		
    );
    reg   [7:0]         data_in         ;
	reg   [19:0]        cnt_wait		;
	reg	  [2:0]			state			;
	reg	  [2:0]			nstate			;
	wire  [7:0] 		data_out		;
	reg	  [tx_w*8-1:0]	tx_r			;
	wire 				rx_vld			;
	reg 				tx_vld			;
	wire 				tx_rdy			;
    reg   [rx_w*8-1:0]  wait_reg        ;
    reg   [tx_w:0]      cnt_uart        ;
    reg                 uart_flag       ;
	localparam state_idle 		= 3'd0	,
			   state_wait 		= 3'd1	,
			   state_end		= 3'd2	;
	always@(posedge clk)begin
		if(uart_txen)
			tx_r <= tx_data;
	end
	always@(*)begin
		if(uart_flag || uart_txen || !tx_rdy)
			rdy = 1'b0;
		else
			rdy = 1'b1;
	end
	always @(posedge clk)begin
        tx_vld      <=   add_uart                       	;
        data_in     <=   tx_r[tx_w*8-1-cnt_uart*8-:8]    	;
		rx_data   	<= 	 wait_reg   						;
    end
    always @(posedge clk)begin
        if(rst)
            cnt_uart <= 'd0;
        else
        if(end_uart)
            cnt_uart <= 'd0;
        else
        if(add_uart)
            cnt_uart <= cnt_uart + 1'b1;
    end
    assign add_uart = tx_rdy  &  uart_flag            ;
    assign end_uart = add_uart & cnt_uart == tx_w - 1 ;  
    always @(posedge clk)begin
        if(uart_txen)
            uart_flag <= 1'b1;
        else
        if(end_uart)
            uart_flag <= 1'b0;
    end		   
	
	always @(posedge clk)begin
		if(rst)
			state <= state_idle;
		else
		case (state)
			state_idle:
				if(idle_wait)
					state <= state_wait;
			state_wait:
				if(wait_end)
					state <= state_end;
			state_end:
				state <= state_idle;
			default:
				state <= state_idle;
		endcase 
	end

	assign idle_wait 	= (state == state_idle) && rx_vld	; 			
	assign wait_end  	= (state == state_wait) && end_wait ;
	
	always @(posedge clk)begin
		if(state == state_wait)
			if(end_wait || rx_vld)
				cnt_wait <= 17'd0;
			else
				cnt_wait <= cnt_wait + 1'b1;
		else
			cnt_wait <= 17'd0;
	end
	assign end_wait = rx_w == 1'b1 ? 1'b1 : (cnt_wait == bps*20 - 1);//1000_000

	always @(posedge clk)begin
		if(state == state_end)begin
			uart_rxen <= 1'b1       ;           
        end
		else begin
			uart_rxen <= 1'b0       ;
        end
	end
	generate if(rx_w == 1) begin : one_B		
		always @(posedge clk)begin
				if(rst)
					wait_reg <= 'd0;
				else
				if(idle_wait)
					wait_reg <= data_out;
				else
				if(rx_vld)
					wait_reg <= data_out;
			end
		end
		else begin:more_B
			always @(posedge clk)begin
				if(rst)
					wait_reg <= 'd0;
				else
			    if(idle_wait)
			        wait_reg <= data_out;
			    else
				if(rx_vld)
					wait_reg <= {wait_reg[rx_w*8-9:0], data_out};
			end
		end
	endgenerate
	uart_tx #(
		.bps		( bps				)
	)tx_inst(
		.clk		( clk				),
		.rst		( rst				),
		.tx			( tx				),
		.data_in	( data_in			),
		.tx_vld		( tx_vld			),
		.tx_rdy		( tx_rdy			)
	);		
	uart_rx #(
		.bps		( bps				)
	)rx_inst(		
		.clk		( clk				),
		.rst		( rst				),
		.rx			( rx				),
		.data_out	( data_out			),
		.data_vld	( rx_vld			)
	);		


endmodule
//将接收转换为32位的指令存储到指令RAM
module uart_instr #(
		parameter bps = 217
	)
	(
		input 						clk		,
		input 						rst		,
		input 						rx		,
		output	 					tx		,
		output	reg	[32-1:0] 		instr	,
		output	reg			 		vld 	,
		output						rst_core
    );
	
	reg   [19:0]        cnt_wait		;
	reg	  [2:0]			state			;
	reg	  [1:0]			cnt_rx		    ;
	wire  [7:0] 		data_out		;	
	wire 				rx_vld			;
	reg 				tx_vld			;
	wire 				rdy				;
    reg  [31:0]         wait_reg        ;
	wire [7:0]			cali = cnt_rx ? 8'hff : 8'd0;
	localparam state_idle 		= 3'd0	,
			   state_wait 		= 3'd1	,
			   state_end		= 3'd2	;
	
	assign rst_core		=	state != state_idle			;
	always @(posedge clk)begin
		if(rst)
			state <= state_idle;
		else
		case (state)
			state_idle:
				if(idle_wait)
					state <= state_wait;
			state_wait:
				if(wait_end)
					state <= state_end;
			state_end:
				state <= state_idle;
			default:
				state <= state_idle;
		endcase 
	end

	assign idle_wait 	= (state == state_idle) && rx_vld	; 			
	assign wait_end  	= (state == state_wait) && end_wait	;

	always@(posedge clk)begin
		if(rst)begin
			vld 	<= 1'b0	;
			instr 	<= 32'd0;
		end
		else begin
			vld 	<= end_rx;
			instr 	<= {wait_reg[23:0], data_out};
		end
	end
	always @(posedge clk)begin
        if(rst)
            cnt_rx <= 2'd0;
        else 
		if(rx_vld)
			cnt_rx <= cnt_rx + 1'b1;
        else
        if(state == state_idle)
            cnt_rx <= 2'd0;
	end
	assign end_rx		=	rx_vld && &cnt_rx			;
	always @(posedge clk)begin
		if(state == state_wait)
			if(end_wait || rx_vld)
				cnt_wait <= 17'd0;
			else
				cnt_wait <= cnt_wait + 1'b1;
		else
			cnt_wait <= 17'd0;
	end
	assign end_wait = cnt_wait == bps * 200 - 1;//

	always @(posedge clk)begin
		if(rst)
			tx_vld <= 1'b0;
		else
		if((state == state_end) && rdy)
			tx_vld <= 1'b1;
		else
			tx_vld <= 1'b0;
	end

	always @(posedge clk)begin
		if(rst)
			wait_reg <= 32'd0;
		else
        if(idle_wait)
            wait_reg <= data_out;
        else
		if(rx_vld)
			wait_reg <= {wait_reg[23:0], data_out};
	end

	uart_tx #(
		.bps		( bps				)
	)tx_inst(
		.clk		( clk				),
		.rst		( rst				),
		.tx			( tx				),
		.data_in	( cali				),
		.tx_vld		( tx_vld			),
		.tx_rdy		( rdy				)
	);		
	uart_rx #(
		.bps		( bps				)
	)rx_inst(		
		.clk		( clk				),
		.rst		( rst				),
		.rx			( rx				),
		.data_out	( data_out			),
		.data_vld	( rx_vld			)
	);		

endmodule