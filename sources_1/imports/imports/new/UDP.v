/*
 * @Author: ZhiyuanZhao
 * @Description: 
 * @Date: 2020-12-03 21:49:58
 * @LastEditTime: 2020-12-10 22:44:47
 */
`timescale 1ns / 1ps

module UDP#(
    parameter src_port = 16'd4399,
    parameter dst_port = 16'd5000

)(
            input                       clk         ,
            input                       rst         ,
            input           [9:0]       u_din       ,
            input                       u_din_vld   ,
            input                       u_rd_en     ,
            output          [9:0]       u_dout      ,
            output          [31:0]      u_status    ,
            input                       din_vld     ,
            input           [31:0]      u_control   ,
            input           [7:0]       din         ,
            input                       din_eop     ,
            input                       din_sop     ,
            output     reg              dout_vld    ,
            output     reg  [7:0]       dout        ,
            output     reg              dout_eop    ,
            output     reg              dout_sop            
    );
    reg		[0:0]			state_rx		;//接收头，接收数据
    reg		[0:0]			state_tx		;//发送头，发送数据
    reg		[10:0]			cnt_rx		    ;
    reg		[10:0]			cnt_tx		    ;
    reg		[63:0]			rx_head		    ;
    wire	[63:0]			tx_head		    ;
    reg		[10:0]			rx_x		    ;
    reg		[10:0]			tx_x		    ;
    wire    [11:0]          rm_din          ;
    wire    [11:0]          rm_dout         ;
    wire                    rm_empty        ;    
    wire    [11:0]          tm_din          ;
    wire    [11:0]          tm_dout         ;
    wire                    tm_empty        ;  
    wire	[9:0]			tx_din		    ;
    wire	[9:0]			rx_din		    ;
    wire	[9:0]			tx_dout		    ;
    wire	[9:0]			rx_dout		    ;
    wire                    rx_wr_en        ;
    wire                    rx_rd_en        ;
    wire                    rx_empty        ;
    wire	[15:0]			rx_sou_port		;
    wire	[15:0]			rx_des_port		;
    wire	[15:0]			rx_data_len		;
    wire	[15:0]			tx_data_len		;
    wire	[15:0]			tx_sou_port		;
    wire	[15:0]			tx_des_port		;
    reg		[11:0]			cnt_in		    ;
    
    assign u_status		    =	{rx_empty, rm_empty, rx_full, rm_full, tx_empty, tm_empty, tx_full, tm_full, 4'b0, rm_dout}			;
    assign u_dout		    =	rx_dout			                                    ;
    assign rx_sou_port		=	rx_head[63-:16]			                            ;
    assign rx_des_port		=	rx_head[47-:16]			                            ;
    assign rx_data_len		=	rx_head[31-:16]			                            ;
    assign tx_sou_port		=	src_port			                                ;
    assign tx_des_port		=	dst_port    			                            ;
    assign tx_data_len		=	tm_dout	+ 8		                                    ;
    assign tx_head		    =	{tx_sou_port, tx_des_port, tx_data_len, 16'd0}		;
    assign trans_flag		=	!tm_empty & !tx_empty			                    ;   
    assign rx_wr_en		    =	din_vld & !rx_full & state_rx	                    ;
    assign rx_din		    =	{din_sop, din_eop, din}			                    ;
    assign rx_rd_en         =   u_rd_en & !rx_empty                                 ;
    assign rm_wr_en         =   rx_wr_en & rx_din[8]                                ;
    assign rm_din           =   cnt_rx                                              ;
    assign rm_rd_en		    =	rx_rd_en & rx_dout[8] & !rm_empty			        ;
    assign tx_wr_en         =   u_din_vld & !tx_full                                ;
    assign tx_din           =   u_din                                               ;
    assign tm_wr_en		    =	tx_wr_en & tx_din[8] & !tm_full			            ;
    assign tm_din           =   cnt_in                                              ;
    assign tx_rd_en		    =	trans_flag & state_tx			                    ;
    assign tm_rd_en		    =	tx_rd_en & tx_dout[8]			                    ;
    assign trans_end		=	end_tx & state_tx                                   ;
    always@(posedge clk)begin
        dout_vld <= trans_flag                                                      ; 
        dout_sop <= !state_tx && cnt_tx == 1 && trans_flag                          ;
        dout_eop <= trans_end & trans_flag                                          ;   //将很长的报文分开  
    end
    always@(posedge clk)begin
        if(!state_tx)
            dout <= tx_head[63+8-cnt_tx*8-:8];
        else
            dout <= tx_dout[7:0];
    end
    always@(posedge clk)begin
        if(rst)
            state_rx <= 1'b0;
        else
        if(din_eop & din_vld)
            state_rx <= 1'b0;
        else
        if(end_rx)
            state_rx <= state_rx + 1'b1;
    end
    always@(posedge clk)begin
        if(rst)
            cnt_rx <= 11'd1;
        else
        if(end_rx)
            cnt_rx <= 11'd1;
        else
        if(add_rx)
            cnt_rx <= cnt_rx + 1'b1;
    end
    assign	add_rx	=	din_vld						                        ;
    assign	end_rx	=	add_rx && (cnt_rx >= rx_x || rm_wr_en)    	        ;
    always@(posedge clk)begin
        if(rst)
            cnt_in <= 12'd1;
        else
       if(end_in)
            cnt_in <= 12'd1;
       else
       if(add_in)
            cnt_in <= cnt_in + 1'b1;
    end
    assign	add_in	=	tx_wr_en			;
    assign	end_in	=	add_in && tm_wr_en	;
    always@(*)begin
        if(!state_rx)
            rx_x = 8;
        else
            rx_x = 1472;
    end
    always@(posedge clk)begin
        if(!state_rx & din_vld) 
            rx_head[63+8-cnt_rx*8-:8] <= din;    
    end
    always@(posedge clk)begin
        if(rst)
            state_tx <= 1'b0;
        else
        if(trans_end)
            state_tx <= 1'b0;
        else
        if(end_tx)
            state_tx <= state_tx + 1'b1;
    end
    always@(posedge clk)begin
        if(rst)
            cnt_tx <= 11'd1;
        else
        if(end_tx)
            cnt_tx <= 11'd1;
        else
        if(add_tx)
            cnt_tx <= cnt_tx + 1'b1;
    end
    assign	add_tx	=	trans_flag 					                        ;
    assign	end_tx	=	add_tx && (cnt_tx >= tx_x || tm_rd_en)   	        ;

    always@(*)begin
        if(!state_tx)
            tx_x = 8;
        else
            tx_x = 1472;
    end
   FIFO_syn #(
        .width      ( 10        ),
        .depth      ( 4096      )
   )d_tx_fifo_inst (
        .clk        ( clk       ),  
        .srst       ( rst       ),  
		.din		( tx_din	),                // input wire [10 : 0] din
		.wr_en		( tx_wr_en	),            // input wire wr_en
		.rd_en		( tx_rd_en	),            // input wire rd_en
		.dout		( tx_dout	),              // output wire [10 : 0] dout
		.full		( tx_full	),              // output wire full
		.empty		( tx_empty	)            // output wire empty
	);      
 	FIFO_syn #(
        .width      ( 12        ),
        .depth      ( 128       )
   )m_tx_fifo_inst (
        .clk        ( clk       ),  
        .srst       ( rst       ),  
		.din		( tm_din	),                // input wire [10 : 0] din
		.wr_en		( tm_wr_en	),            // input wire wr_en
		.rd_en		( tm_rd_en	),            // input wire rd_en
		.dout		( tm_dout	),              // output wire [10 : 0] dout
		.full		( tm_full	),              // output wire full
		.empty		( tm_empty	)            // output wire empty
	); 
   FIFO_syn #(
        .width      ( 10        ),
        .depth      ( 4096      )
   )d_rx_fifo_inst (
        .clk        ( clk       ),  
        .srst       ( rst       ),  
		.din		( rx_din	),                // input wire [10 : 0] din
		.wr_en		( rx_wr_en	),            // input wire wr_en
		.rd_en		( rx_rd_en	),            // input wire rd_en
		.dout		( rx_dout	),              // output wire [10 : 0] dout
		.full		( rx_full	),              // output wire full
		.empty		( rx_empty	)            // output wire empty
	);      
 	FIFO_syn #(
        .width      ( 12        ),
        .depth      ( 128       )
   )m_rx_fifo_inst (
        .clk        ( clk       ),  
        .srst       ( rst       ),  
		.din		( rm_din	),                // input wire [10 : 0] din
		.wr_en		( rm_wr_en	),            // input wire wr_en
		.rd_en		( rm_rd_en	),            // input wire rd_en
		.dout		( rm_dout	),              // output wire [10 : 0] dout
		.full		( rm_full	),              // output wire full
		.empty		( rm_empty	)            // output wire empty
	); 
endmodule
