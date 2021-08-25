/*
 * @Author: ZhiyuanZhao
 * @Description: 
 * @Date: 2020-12-03 21:49:58
 * @LastEditTime: 2021-01-03 19:44:55
 */
`timescale 1ns / 1ps

module TCP_client(
            input                       clk         ,
            input                       rst         ,
            input           [9:0]       u_din       ,
            input                       u_din_vld   ,
            input                       u_rd_en     ,
            output          [9:0]       u_dout      ,
            output          [31:0]      u_status    ,
            input           [31:0]      u_control   ,
            input                       din_vld     ,
            input           [7:0]       din         ,
            input                       din_eop     ,
            input                       din_sop     ,
            output     reg              dout_vld    ,
            output     reg  [7:0]       dout        ,
            output     reg              dout_eop    ,
            output     reg              dout_sop    
    );
    localparam  idle            =   3'b000          ,
                synsent         =   3'b001          ,
                establish       =   3'b010          ,
                correspond      =   3'b011          ,
                finwait         =   3'b100          ,
                timewait        =   3'b101          ,
                finish          =   3'b110          ;
    localparam wait_pkt = 3;//和重发fifo深度有关
    reg		[2:0]			state_tcp		;
    reg		[0:0]			state_rx		;//接收头，接收数据
    reg		[1:0]			state_tx		;//idle,发送头，发送数据，重发
    wire    [0:0]           tx_flag         ;
    reg     [0:0]           recei_flag      ;
    wire                    work_end        ;
    reg		[1:0]			trans_type		;//无数据部分头，无数据部分应答，有数据部分,重发
    reg		[0:0]			recei_type		;//无数据部分头，无数据部分应答，有数据部分

    wire	[31:0]			rx_seq_num		;
    wire	[31:0]			rx_ack_num		;
    wire	[3:0]			rx_head_len	    ;
    wire	[5:0]			rx_identi		;
    wire	[0:0]			rx_syn		    ;
    wire	[0:0]			rx_ack		    ;
    wire	[0:0]			rx_fin		    ;
    wire	[15:0]			rx_win_size	    ;
    wire	[15:0]			rx_checksum	    ;
    wire	[95:0]			rx_option		;
    reg 	[31:0]			tx_seq_num		;
    reg 	[31:0]			tx_ack_num		;
    reg 	[3:0]			tx_head_len	    ;
    wire 	[5:0]			tx_identi		;
    reg 	[0:0]			tx_syn		    ;
    reg 	[0:0]			tx_ack		    ;
    reg		[0:0]			tx_push		    ;
    reg 	[0:0]			tx_rst		    ;
    reg 	[0:0]			tx_fin		    ;
    wire 	[15:0]			tx_win_size	    ;
    wire 	[15:0]			tx_checksum	    ;
    reg 	[15:0]			tx_pointer		;
    wire 	[95:0]			tx_option		;
    wire    [15:0]          tx_mss          ;
    wire    [15:0]          rx_mss          ;
    wire	[7:0]			tx_sack 		;
    reg		[16:0]			in_cali0 		;
    reg		[16:0]			in_cali1		;
    reg		[4:0]			cnt_rst		    ;
    wire	[0:0]			trans_end		;
    wire	[9:0]			tx_din		    ;
    wire	[9:0]			rx_din		    ;
    wire	[9:0]			rsd_din		    ;
    wire	[9:0]			tx_dout		    ;
    wire	[9:0]			rx_dout		    ;
    wire	[9:0]			rsd_dout		;
    wire                    rx_wr_en        ;
    wire                    rsd_wr_en       ;
    wire                    rx_rd_en        ;
    wire                    rsd_rd_en       ;
    wire                    rx_empty        ;
    wire                    tx_empty        ;
    wire                    rsd_empty       ;
    wire                    rx_full         ;
    reg     [7:0]           tx_data         ;
    wire    [7:0]           rx_data         ;
    wire	[0:0]			ack_vld		    ;
    reg		[10:0]			cnt_rx		    ;
    reg		[16:0]			cnt_tx		    ;
    reg		[16:0]			tx_x		    ;
    reg		[16:0]			cnt_rsbyte		;
    reg		[10:0]			cnt_in		    ;
    reg		[10:0]			x		        ;
    reg		[10:0]			rx_x		    ;
    reg		[22:0]			cnt_resend	    ;
    reg		[0:0]			resend_flag		;
    wire 	[255:0]			tx_head		    ;
    reg 	[255:0]			rx_head		    ;

    wire    [11:0]          rm_din          ;
    wire    [11:0]          rm_dout         ;
    wire                    rm_empty        ;     
    wire    [11:0]          tm_din          ;
    wire    [11:0]          tm_dout         ;
    wire                    tm_empty        ;
    reg		[0:0]			fin_flag		;
    wire	[15:0]			client_port		;
    wire	[15:0]			server_port		;
    reg                     rx_rst          ;
    reg     [7:0]           cnt_rspkt       ;
    wire                    end_rspkt       ;
    reg                     stop_flag       ;
    assign tx_head		    =	{client_port, server_port, tx_seq_num, tx_ack_num, tx_head_len, 6'd0, tx_identi, tx_win_size,
                                tx_checksum, 16'd0, tx_option}	                    ;
    assign rx_data_vld		=	tx_ack_num == rx_seq_num			                ;
    assign client_port		=	u_control[15:0]			                            ;
    assign server_port		=	16'd6000                            			    ;
    assign rx_seq_num       =   rx_head[223-:32]                                    ;
    assign rx_ack_num		=	rx_head[191-:32]			                        ;
    assign rx_head_len      =   rx_head[159-:4]                                     ;
    assign rx_identi		=	rx_head[149-:6]			                            ;
    assign rx_win_size		=	rx_head[143-:16]			                        ;
    assign rx_checksum		=	rx_head[127-:16]			                        ;
    assign rx_option   		=	rx_head[95:0]   	    		                    ;
    assign rx_syn		    =	rx_identi[1]			                            ;
    assign rx_ack		    =	rx_identi[4]			                            ;
    assign rx_fin		    =	rx_identi[0]			                            ;
    assign tx_identi		=	{1'b0, tx_ack, tx_push, tx_rst, tx_syn, tx_fin}		;
    assign tx_win_size		=	16'hffff			                                ;   
    assign tx_checksum		=	16'd0			                                    ;    
    assign tx_mss		    =	16'h05b4			                                ;
    assign tx_option		=	{16'h0204, tx_mss, 32'h01030308, 32'h01010101}	    ;
    assign ack_vld		    =	recei_flag & rx_ack_num == tx_seq_num & rx_ack		;
    assign tx_flag		    =	!trans_idle			                                ;
    assign rs_rst           =   (trans_idle & !resend_flag) | state_idle | rst_fin  ;
    assign tx_fifo_rst      =   rst | rst_fin | !state_correspond                   ;
    assign trans_pkt		=	!tx_empty & !tm_empty & state_correspond & !stop_flag			;
    assign trans_ack		=	recei_flag & recei_type	& !state_idle		        ;
    assign work_start		=	u_control[16]			                            ;
    assign work_end		    =	u_control[17] || fin_flag			                ;

    assign state_idle       =   state_tcp == idle                                   ;
    assign state_synsent    =   state_tcp == synsent                                ;
    assign state_establish  =   state_tcp == establish                              ;
    assign state_correspond =   state_tcp == correspond                             ;
    assign state_finwait    =   state_tcp == finwait                                ;
    assign state_timewait   =   state_tcp == timewait                               ;
    assign state_finish     =   state_tcp == finish                                 ;
    assign trans_idle	    =	state_tx == 2'b00			                        ;
    assign trans_head	    =	state_tx == 2'b01			                        ;
    assign trans_data		=	state_tx == 2'b10			                        ;
    assign trans_resend		=	state_tx == 2'b11			                        ;
    assign trans_end		=	end_tx & (trans_type != 2'b10 || trans_data)        ;
    assign trans_start		=	trans_idle & (idle_synsent || synsent_establish || trans_pkt || trans_ack || correspond_finwait || end_rst)	;
    assign trans_validend	=	trans_end && trans_type != 2'b01			        ;

    assign u_status		    =	{state_tcp, rx_empty, rm_empty, rx_full, rm_full, tx_empty, tm_empty, tx_full, tm_full, 4'b0, rm_dout}			;
    assign u_dout		    =	rx_dout			                                    ;    
    assign rx_wr_en		    =	din_vld & !rx_full & state_rx & rx_data_vld	        ;
    assign rx_din		    =	{din_sop, din_eop, din}			                    ;
    assign rx_rd_en         =   u_rd_en & !rx_empty                                 ;
    assign rm_wr_en         =   rx_wr_en & rx_din[8]                                ;
    assign rm_din           =   cnt_rx                                              ;
    assign rm_rd_en		    =	rx_rd_en & rx_dout[8]			                    ;
    assign tx_wr_en         =   u_din_vld & !tx_full & state_correspond             ;
    assign tx_din           =   u_din                                               ;
    assign tm_wr_en		    =	tx_wr_en & tx_din[8]			                    ;
    assign tm_din           =   cnt_in                                              ;
    assign tx_rd_en		    =	trans_data & trans_pkt 			                    ;
    assign tm_rd_en		    =	tx_rd_en & tx_dout[8]			                    ;

    assign rsd_wr_en		=	dout_vld & !rsd_full & trans_type != 2'b01	        ;
    assign rsd_din		    =	{dout_sop, dout_eop, dout}			                ;
    assign rsd_rd_en        =   (trans_resend) & !rsd_empty                         ;
    
    always@(posedge clk)begin;
        if(rst)
            state_tcp <= idle;
        else
        case(state_tcp)
        idle:
            if(idle_synsent)
                state_tcp <= synsent;
        synsent:
            if(synsent_establish)   
                state_tcp <= establish;
            else
            if(rst_fin)
                state_tcp <= finish; 
        establish:
            if(establish_correspond)
                state_tcp <= correspond;
            else
            if(rst_fin)
                state_tcp <= finish; 
        correspond:
            if(correspond_finwait)
                state_tcp <= finwait;
            else
            if(rst_fin)
                state_tcp <= finish;
        finwait:
            if(finwait_finish)
                state_tcp <= finish;
            else
            if(finwait_timewait)
                state_tcp <= timewait;
            else
            if(rst_fin)
                state_tcp <= finish;
        timewait:
            if(timewait_finish)
                state_tcp <= finish;
            else 
            if(rst_fin)
                state_tcp <= finish;
        finish:
            if(finish_idle)
                state_tcp <= idle;
        default:state_tcp <= idle;
        endcase
    end

    assign idle_synsent             =   state_idle & work_start                                                                 ;
    assign synsent_establish        =   state_synsent && ack_vld & rx_syn                                                       ;
    assign establish_correspond		=   state_establish && trans_end		                                                    ;
    assign correspond_finwait		=	state_correspond && work_end && trans_idle && !(trans_pkt || trans_ack || resend_flag) 	;
    assign finwait_timewait		    =	state_finwait && ack_vld			                                                    ;
    assign finwait_finish		    =	state_finwait && fin_flag && ack_vld			                                        ;
    assign timewait_finish		    =	state_timewait && (recei_flag & rx_ack & rx_fin) || end_resend			                ;
    assign finish_idle		        =	state_finish & trans_idle			                                                    ;
    assign rst_fin		            =	(rx_rst & recei_flag) || end_rst			                                            ;
    always@(posedge clk)begin
        if(state_idle)
            rx_rst <= 1'b0;
        else
            rx_rst <= rx_identi[2];
    end
    always@(posedge clk)begin
        if(rst)
            fin_flag <= 1'b0;
        else
        if(rx_fin & recei_flag)
            fin_flag <= 1'b1;
        else
        if(state_idle)
            fin_flag <= 1'b0;
    end
    always@(posedge clk)begin
        if(rst)
            cnt_rsbyte <= 'd0;
        else
        if((trans_type == 2'b00 || trans_type == 2'b10) & end_tx)
            cnt_rsbyte <= cnt_rsbyte + cnt_tx;
        else
        if(rs_rst)
            cnt_rsbyte <= 'd0;
    end
    always@(posedge clk)begin
        if(rst)
            resend_flag <= 1'b0;
        else
        if(state_idle)
            resend_flag <= 1'b0;
        else
        if(trans_validend)
            resend_flag <= 1'b1;
        else
        if(ack_vld)
            resend_flag <= 1'b0;
    end
    always@(posedge clk)begin
        if(rst)
            cnt_resend <= 'd0;
        else
       if(end_resend || trans_validend || !resend_flag)
            cnt_resend <= 'd0;
       else
       if(add_resend)
            cnt_resend <= cnt_resend + 1'b1;
    end
    assign	add_resend	=	(resend_flag || state_timewait) && trans_idle	;
    assign	end_resend	=	add_resend && &cnt_resend	                    ;
    always@(posedge clk)begin
        if(rst)
            cnt_rspkt <= 'd0;
        else
        if(end_rspkt || !resend_flag)
            cnt_rspkt <= 'd0;
        else
        if(add_rspkt)
            cnt_rspkt <= cnt_rspkt + 1'b1;
    end
    assign	add_rspkt	=	tm_rd_en						        ;
    assign	end_rspkt	=	add_rspkt && cnt_rspkt >= wait_pkt - 1	;
    always@(posedge clk)begin
        if(end_rspkt)
            stop_flag <= 1'b1;
        else
        if(ack_vld || state_idle)
            stop_flag <= 1'b0;
    end
    always@(posedge clk)begin
        if(rst)
            cnt_rst <= 5'd0;
        else
       if(end_rst || !resend_flag)
            cnt_rst <= 5'd0;
       else
       if(add_rst)
            cnt_rst <= cnt_rst + 1'b1;
    end
    assign	add_rst	=	end_resend						;
    assign	end_rst	=	add_rst && cnt_rst >= 10	    ;
    always@(posedge clk)begin
        if(state_idle)
            tx_rst <= 1'b0;
        else
        if(end_rst)
            tx_rst <= 1'b1;
    end
    always@(posedge clk)begin
        if(rst)
            cnt_tx <= 'd1;
        else
        if(end_tx)
            cnt_tx <= 'd1;
        else
        if(add_tx)
            cnt_tx <= cnt_tx + 1'b1;
    end
    assign	add_tx	=	tx_flag 						                     ;
    assign	end_tx	=	add_tx && (cnt_tx >= tx_x || tm_rd_en)               ;
    always@(posedge clk)begin
        if(rst)
            state_tx <= 2'b0;
        else
        if(end_resend)
            state_tx <= 2'b11;
        else
        if(trans_start)
            state_tx <= 2'b1;
        else
        if(trans_end || state_idle)
            state_tx <= 2'b0;
        else
        if(end_tx)
            state_tx <= state_tx + 1'b1;
    end
    always@(posedge clk)begin
        if(idle_synsent || correspond_finwait || end_rst)
            trans_type <= 2'b0;
        else
        if(end_resend)
            trans_type <= 2'b11;
        else
        if(trans_pkt)
            trans_type <= 2'b10;
        else
        if(trans_ack || synsent_establish)
            trans_type <= 2'b01;

    end
    always@(*)begin
        if(trans_head && tx_head_len <= 5)
            tx_x = 20;
        else
        if(trans_head)
            tx_x = {tx_head_len, 2'b0};
        else
        if(trans_resend)
            tx_x = cnt_rsbyte;
        else
            tx_x = 1460;
    end
    always@(posedge clk)begin
		if(state_idle)
			tx_seq_num <= 'd0;
		else
		if(trans_type == 2'b00 && end_tx)	
            tx_seq_num <= tx_seq_num + 1'b1;
        else
        if(trans_type == 2'b10 && trans_data & end_tx)
            tx_seq_num <= tx_seq_num + cnt_tx;
	end
    always@(posedge clk)begin
		if(state_idle || state_synsent)begin
            tx_syn      <= 1'b1             ;
            tx_head_len <= 4'd8             ;
            tx_ack      <= 1'b0             ;
        end
		else begin
            tx_syn      <= 1'b0             ;
            tx_head_len <= 4'd5             ;
            tx_ack      <= 1'b1             ;
        end
	end
    always@(posedge clk)begin
        if(tm_dout != 1460 && trans_type == 2'b10)
            tx_push <= 1'b1;
        else
            tx_push <= 1'b0;
    end
    always@(posedge clk)begin
        dout_vld <= add_tx;  
    end
    always@(posedge clk)begin
        if(trans_resend)begin
            dout_sop <= rsd_dout[9]                         ;
            dout_eop <= rsd_dout[8]                         ;
        end
        else begin
            dout_sop <= cnt_tx == 1 && add_tx && !trans_data;
            dout_eop <= trans_end                           ;
        end
    end
    always@(posedge clk)begin
        if(trans_head)
            dout <= tx_head[255+8-cnt_tx*8-:8];
        else
        if(trans_data)
            dout <= tx_dout[7:0];
        else
        if(trans_resend)
            dout <= rsd_dout[7:0];
    end
    always@(posedge clk)begin
        if(state_idle || state_synsent)
            tx_ack_num <= 'd0;
        else
        if(state_establish || fin_flag) //
            tx_ack_num <= rx_seq_num + 1'b1;
        else
        if(state_correspond & state_rx & end_rx & rx_data_vld)
            tx_ack_num <= rx_seq_num + cnt_rx;
    end
    always@(posedge clk)begin
        if(state_finwait)
            tx_fin <= 1'b1;
        else
            tx_fin <= 1'b0;
    end
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
    assign	add_in	=	tx_wr_en 						        ;
    assign	end_in	=	add_in && tm_wr_en          	        ;
    always@(posedge clk)begin
        tx_data   <= rx_dout[7:0]   ;
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
        if(end_rx )
            cnt_rx <= 11'd1;
        else
        if(add_rx)
            cnt_rx <= cnt_rx + 1'b1;
    end
    assign	add_rx	=	din_vld						            ;
    assign	end_rx	=	add_rx && (cnt_rx >= rx_x || rm_wr_en)  ;
    always@(*)begin
        if(!state_rx && rx_head_len <= 5)
            rx_x = 20;
        else
        if(!state_rx)
            rx_x = {rx_head_len, 2'b0};
        else
            rx_x = 1460;
    end
    always@(posedge clk)begin
        if(state_idle)
            rx_head <= 256'd0;
        else
        if(!state_rx & din_vld & cnt_rx < 32) 
            rx_head[255+8-cnt_rx*8-:8] <= din;    
    end
    always@(posedge clk)begin
        if(din_eop && din_vld)
            recei_flag <= 1'b1;
        else 
        if(trans_start || state_idle || !trans_ack)
            recei_flag <= 1'b0;
    end
    always@(posedge clk)begin
        if(din_eop && din_vld)
            recei_type <= state_rx || rx_fin;
        else 
        if(trans_start || state_idle)
            recei_type <= 1'b0      ;
    end

   FIFO_syn #(
        .width      ( 10        ),
        .depth      ( 4096      )
   )rs_d_fifo_inst(
        .clk        ( clk       ),  // input wire wr_clk
        .srst       ( rs_rst    ),  // input wire wr_rst
		.din		( rsd_din	),                // input wire [10 : 0] din
		.wr_en		( rsd_wr_en	),            // input wire wr_en
		.rd_en		( rsd_rd_en	),            // input wire rd_en
		.dout		( rsd_dout	),              // output wire [10 : 0] dout
		.full		( rsd_full	),              // output wire full
		.empty		( rsd_empty	)            // output wire empty       
   ); 
   FIFO_syn #(
        .width      ( 10        ),
        .depth      ( 4096      )
   )d_tx_fifo_inst (
        .clk        ( clk       ),  
        .srst       ( tx_fifo_rst       ),  
		.din		( tx_din	),                // input wire [10 : 0] din
		.wr_en		( tx_wr_en	),            // input wire wr_en
		.rd_en		( tx_rd_en	),            // input wire rd_en
		.dout		( tx_dout	),              // output wire [10 : 0] dout
		.full		( tx_full	),              // output wire full
		.empty		( tx_empty	)            // output wire empty
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
 	FIFO_syn #(
        .width      ( 12        ),
        .depth      ( 128       )
   )m_tx_fifo_inst (
        .clk        ( clk       ),  
        .srst       ( tx_fifo_rst       ),  
		.din		( tm_din	),                // input wire [10 : 0] din
		.wr_en		( tm_wr_en	),            // input wire wr_en
		.rd_en		( tm_rd_en	),            // input wire rd_en
		.dout		( tm_dout	),              // output wire [10 : 0] dout
		.full		( tm_full	),              // output wire full
		.empty		( tm_empty	)            // output wire empty
	); 
endmodule
