/*
 * @Author: ZhiyuanZhao
 * @Description: 
 * @Date: 2020-12-03 21:49:58
 * @LastEditTime: 2021-03-30 13:35:11
 */
`timescale 1ns / 1ps

module ethernet_tx#(
    parameter ip_sour   = {8'd192, 8'd168, 8'd1, 8'd254},
    parameter ip_des    = {8'd192, 8'd168, 8'd1, 8'd100},
    parameter ETH_NUM   = 1'b1                          ,
    parameter wait_time = 20                                //1000M:96ns      100M:960ns
)(
        input                           clk         ,
        input                           rst         ,
        input          [7:0]            din         ,
        input                           din_vld     ,
        input          [ETH_NUM-1:0]    din_type    ,
        input                           din_eop     ,
        input                           din_sop     ,
        output                          rdy         ,
        input		                    gmii_clk    ,              
        input		                    gmii_rst    ,              
        output  reg    [7:0]	        gmii_td     ,              
        output	reg	                    gmii_tx_dv  
    );
    
    localparam  mac_pre     =   64'h55_55_55_55_55_55_55_d5             ,//64'h01_02_03_04_05_06_07_08           
                mac_des     =   48'h00_E0_4C_68_05_2C                   ,//ff_ff_ff_ff_ff_ff    01_02_03_04_05_06   94_e6_f7_60_fc_d4  
                mac_sour    =   48'h07_08_09_0a_0b_0c                   ,//94_e6_f7_60_fc_d5
                mac_type    =   16'h08_00                               ,
                mac_head    =   {mac_pre, mac_des, mac_sour, mac_type}  ,//176
                ip_ver      =   4'h4                                    ,
                ip_head_len =   4'h5                                    ,
                ip_service  =   8'd0                                    ,
                ip_flag     =   32'd0                                   ,
                ip_life     =   8'd64                                   ,
                ip_tcp      =   8'd6                                    ,
                ip_udp      =   8'd17                                   ;
                
    localparam  idle        =   3'd0                                    ,
                tx_head     =   3'd1                                    ,
                tx_data     =   3'd2                                    ,
                tx_crc      =   3'd3                                    ,
                fin         =   3'd4                                    ;
    wire    [159:0]         ip_head             ;
    wire    [15:0]          sou_port            ;
    wire    [15:0]          des_port            ;
    wire    [335:0]         head                ;
    wire    [31:0]          crc_result          ;
    wire    [15:0]          ip_len              ;
    reg     [17:0]          ip_cali             ;    
    reg     [17:0]          ip_correct          ;
    reg     [17:0]          tcp_cali            ;    
    reg     [17:0]          tcp_correct         ;
    reg     [15:0]          data_len            ;
    reg                     crc_en              ;
    reg     [31:0]          mac_crc             ;
    reg     [2:0]           state               ;
    reg     [1:0]           cnt_tx              ;
    reg     [11:0]          x                   ;
    reg     [11:0]          cnt_data            ;
    reg     [11:0]          cnt_vld             ;
    reg     [7:0]           crc_data            ;
    reg                     crc_rst             ;
    reg		[0:0]			pre_checksum_rst	;
    reg	    [1:0]			pkt_type		    ;
    wire	[7:0]			tcp_udp		        ;
    wire    [9:0]           d_din               ;
    wire    [29+ETH_NUM-1:0]m_din               ;
    wire    [9:0]           d_dout              ;
    wire    [29+ETH_NUM-1:0]m_dout              ;
    wire                    m_empty             ;
    wire                    d_empty             ;        
    wire                    m_wr_en             ;        
    wire                    m_rd_en             ;        
    wire                    d_wr_en             ;        
    wire                    d_rd_en             ;        
    wire    [16:0]          cali_tcp            ;      
    wire    [95:0]          fake_head           ;
    wire    [4:0]           pos_cali            ;
    reg		[9:0]			cnt_wait		    ;
    wire                    cali_cnt            ;
    assign  rdy		    =	!d_full & !m_full			                                                                                ;
    assign  cali_cnt	=	cnt_data - pos_cali			                                                                                ;
    assign  is_tcp		=	pkt_type != 1			                                                                                    ;
    assign  pos_cali	=	is_tcp ? 16 : 6                 			                                                                ;
    assign  fake_head	=	{ip_sour, ip_des, 8'd0, tcp_udp, data_len}			                                                        ;
    assign  tcp_udp		=	is_tcp ? ip_tcp : ip_udp        			                                                                ;                                                                                                                                                                           ;
    assign  port        =   1'b1                                                                                                        ;
    assign  ip_head     =   {ip_ver, ip_head_len, ip_service, ip_len, ip_flag, ip_life, tcp_udp, ~ip_correct[15:0], ip_sour, ip_des}    ;
    assign  head        =   {mac_head, ip_head}                                                                                         ;
    assign  head_period =   state == tx_head                                                                                            ;
    assign  data_period =   state == tx_data                                                                                            ;
    assign  crc_period  =   state == tx_crc                                                                                             ;
    assign  tx_period   =   head_period | data_period | crc_period                                                                      ;
    assign  d_din       =   {din_sop, din_eop,  din}                                                                                    ;
    assign  d_wr_en     =   din_vld & !d_full                                                                                           ;
        //   17+ ETH_NUM+  12 
    assign  m_din       =   {din_type, cali_tcp, cnt_vld}                                                                               ;
    assign  m_wr_en     =   end_vld & !m_full                                                                                           ;
    assign  d_rd_en     =   !d_empty & data_period & cnt_data < data_len & end_tx                                                       ;
    assign  m_rd_en     =   !m_empty & data_period & end_data                                                                           ;        
    assign  ip_len      =   data_len + 20                                                                                               ;
    always @ * begin
        if(cnt_data == 0 & head_period)
            ip_cali = ip_head[15:0] + ip_head[31:16] + ip_head[47:32] + ip_head[63:48] + ip_head[95:80] + ip_head[111:96] + ip_head[127:112] + ip_head[143:128] + ip_head[159:144];
        else
        if(|ip_correct[17:16])
            ip_cali = ip_correct[17:16] + ip_correct[15:0];
        else
            ip_cali = ip_correct;
    end 
    always@(posedge gmii_clk)begin
        if(gmii_rst)
            cnt_wait <= 10'd0;
        else
        if(state == idle && cnt_wait <= wait_time)
            cnt_wait <= cnt_wait + 1'b1;
        else
        if(state != idle)
            cnt_wait <= 10'd0;
    end
    always @(posedge gmii_clk)begin
        if(gmii_rst)
            ip_correct <= 18'd0;
        else
        if(head_period)
            ip_correct <= ip_cali;
        else
            ip_correct <= 18'd0;
    end    
    always @ * begin
        if(cnt_data == 0 & head_period)
            tcp_cali = fake_head[15:0] + fake_head[31:16] + fake_head[47:32] + fake_head[63:48] + fake_head[79:64] + fake_head[95:80] + m_dout[12+:17];
        else
        if(|tcp_correct[17:16])
            tcp_cali = tcp_correct[17:16] + tcp_correct[15:0];
        else
            tcp_cali = tcp_correct;
    end
    always @(posedge gmii_clk)begin
        if(gmii_rst)
            tcp_correct <= 18'd0;
        else
        if(head_data)
            tcp_correct <= ~tcp_cali;
        else
        if(head_period)
            tcp_correct <= tcp_cali;
        else
        if(state == idle)
            tcp_correct <= 18'd0;
    end
    always @(posedge gmii_clk)begin
        if(gmii_rst)
            state <= idle;
        else
        case(state)
            idle:
                if(idle_head)
                    state <= tx_head;
            tx_head:
                if(head_data)
                    state <= tx_data;
            tx_data:
                if(data_crc)
                    state <= tx_crc;
            tx_crc:
                if(crc_fin)
                    state <= fin;
            fin:
                state <= idle;
            default:
                state <= idle;
        endcase
    end
    assign idle_head = state == idle & !m_empty & cnt_wait >= wait_time                 ; 
    assign head_data = head_period & end_data                                           ;
    assign data_crc  = data_period & end_data                                           ;
    assign crc_fin   = crc_period & end_data                                            ;
    always @(posedge gmii_clk)begin
        if(idle_head)begin
            data_len <= m_dout[11:0]            ;
            pkt_type <= m_dout[29+:ETH_NUM]     ;
        end
        else
        if(state == idle)begin
            data_len <= 16'd0           ;
            pkt_type <= 2'b0            ;
        end
    end
    always @(posedge gmii_clk)begin
        if(gmii_rst)
            crc_rst <= 1'b1;
        else
        if(state == idle)
            crc_rst <= 1'b1;
        else
            crc_rst <= 1'b0;
    end
    always @* begin
        if(head_period)
            x = 42;
        else
        if(crc_period)
            x = 4;
        else
        if(data_len < 26)
            x = 26;
        else
            x = data_len;
    end
    always @(posedge gmii_clk)begin
        if(gmii_rst)
            cnt_data <= 20'd0;
        else
        if(end_data || state == idle)
            cnt_data <= 20'd0;
        else
        if(add_data)
            cnt_data <= cnt_data + 1'b1;
    end
    assign add_data = end_tx                           ;
    assign end_data = add_data & cnt_data >= x - 1     ;
    always @(*)begin
            mac_crc =  ~{crc_result[24], crc_result[25], crc_result[26], crc_result[27], crc_result[28], crc_result[29], crc_result[30], crc_result[31], crc_result[16], crc_result[17], crc_result[18], crc_result[19], crc_result[20], crc_result[21], crc_result[22], crc_result[23],crc_result[8], crc_result[9], crc_result[10], crc_result[11], crc_result[12], crc_result[13], crc_result[14], crc_result[15],crc_result[0], crc_result[1], crc_result[2], crc_result[3], crc_result[4], crc_result[5], crc_result[6], crc_result[7]};
    end
    always @(*)begin
        if(head_period & cnt_data >= 8 & cnt_tx == 0)begin
            crc_data    = head[328-cnt_data*8+:8]     ;
            crc_en      = 1'b1                        ;
        end
        else
        if(data_period & cnt_data >= pos_cali && cnt_data < pos_cali + 2 && cnt_tx == 0)begin
            crc_data    = tcp_correct[8-cali_cnt*8+:8];
            crc_en      = 1'b1                        ;
        end
        else
        if(data_period & cnt_tx == 0 & cnt_data < data_len)begin
            crc_data    = d_dout[7:0]                 ;
            crc_en      = 1'b1                        ;
        end
        else 
        if(data_period & cnt_tx == 0 & cnt_data >= data_len)begin
            crc_data    = 8'd0                        ;
            crc_en      = 1'b1                        ;
        end
        else begin
            crc_data    = 8'd0                        ;
            crc_en      = 1'b0                        ;
        end
    end
    always @(posedge gmii_clk)begin
        if(gmii_rst)
            cnt_tx <= 'd0;
        else
        if(end_tx)
            cnt_tx <= 'd0;
        else
        if(add_tx)
            cnt_tx <= cnt_tx + 1'b1;
    end
    assign add_tx = tx_period                          ;
    assign end_tx = add_tx & cnt_tx == 1 - 1           ;
    always @(posedge gmii_clk)begin
        if(gmii_rst)
            gmii_tx_dv <= 1'b0;
        else
        if(tx_period)  
            gmii_tx_dv <= 1'b1;
        else
            gmii_tx_dv <= 1'b0;
    end
    always @(posedge gmii_clk)begin
        if(gmii_rst)
            gmii_td <= 8'b0;
        else
        if(head_period)
            gmii_td <= head[328-cnt_data*8+:8];//+:8 和-:8初始值不同
        else
        if(data_period & cnt_data >= pos_cali && cnt_data < pos_cali + 2)
            gmii_td <= tcp_correct[8-cali_cnt*8+:8];
        else
        if(data_period & cnt_data < data_len)
            gmii_td <= d_dout;
        else
        if(crc_period)
            gmii_td <= mac_crc[24-cnt_data*8+:8];
        else
            gmii_td <= 8'b0;
    end 

    //************************** user_clk ***********************************************
    always@(posedge clk)begin
        if(rst)
            pre_checksum_rst <= 1'b1;
        else
            pre_checksum_rst <= din_eop & din_vld;
    end
    always @(posedge clk)begin
        if(rst)
            cnt_vld <= 12'd1;
        else
        if(end_vld)
            cnt_vld <= 12'd1;
        else
        if(add_vld)
            cnt_vld <= cnt_vld + 1'b1;
    end    
    assign add_vld = d_wr_en            ;
    assign end_vld = add_vld & din_eop  ;
    checksum check_inst(
        .clk            ( clk               ),
        .rst            ( pre_checksum_rst  ),  
        .init           ( 17'd0             ),
        .en             ( din_vld           ),
        .data           ( din               ),
        .cali           ( cali_tcp          )      
    );
    crc crc_inst(
        .clk            ( gmii_clk          ),
        .rst            ( crc_rst           ),
        .data_in        ( crc_data          ),
        .enable         ( crc_en            ),
        .Crc            ( crc_result        ),
        .CrcNext        (                   )
    );
    FIFO_asyn #(
        .width          ( 10                ),
        .depth          ( 4096              )
    ) d_fifo_inst(
        .wr_clk         ( clk               ),  
        .wr_rst         ( rst               ),  
        .rd_clk         ( gmii_clk          ),  
        .rd_rst         ( gmii_rst          ),  
		.din		    ( d_din		        ),                // input wire [10 : 0] din
		.wr_en		    ( d_wr_en	        ),            // input wire wr_en
		.rd_en		    ( d_rd_en	        ),            // input wire rd_en
		.dout		    ( d_dout	        ),              // output wire [10 : 0] dout
		.full		    ( d_full	        ),              // output wire full
		.empty		    ( d_empty	        )            // output wire empty
	);  
 	FIFO_asyn #(
        .width          ( 17 + ETH_NUM + 12 ),
        .depth          ( 32                )
    ) m_fifo_inst(
        .wr_clk         ( clk               ),  
        .wr_rst         ( rst               ),  
        .rd_clk         ( gmii_clk          ),  
        .rd_rst         ( gmii_rst          ),  
		.din		    ( m_din		        ),                // input wire [10 : 0] din
		.wr_en		    ( m_wr_en	        ),            // input wire wr_en
		.rd_en		    ( m_rd_en	        ),            // input wire rd_en
		.dout		    ( m_dout	        ),              // output wire [10 : 0] dout
		.full		    ( m_full	        ),              // output wire full
		.empty		    ( m_empty	        )            // output wire empty
	); 
endmodule
