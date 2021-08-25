`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/05 20:20:55
// Design Name: 
// Module Name: ethernet_rx
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


module ethernet_rx#(
    parameter ip_sour   = {8'd192, 8'd168, 8'd1, 8'd254},
    parameter ip_des    = {8'd192, 8'd168, 8'd1, 8'd100},
    parameter ETH_NUM   = 1'b1                          ,
    parameter wait_time = 20                            ,
    parameter udp_check = 1'b1
)(
        input                           clk         ,
        input                           rst         ,
        input   		                gmii_clk 	,
        input                           gmii_rst    ,              
        input   		                gmii_rx_dv 	,                          
        input          [7:0]	        gmii_rd 	,    
        output     reg [ETH_NUM-1:0]    dout_type   ,
        output     reg                  dout_vld    ,
        output     reg [7:0]            dout        ,
        output     reg [10:0]           dout_len    ,
        output     reg                  dout_eop    ,
        output     reg                  dout_sop    
    );
    
    localparam  mac_pre     =   56'h55_55_55_55_55_55_55                ,
                mac_type    =   16'h08_00                               ,
                ip_ver_len  =   8'h45                                   ,
                ip_tcp      =   8'd6                                    ,
                ip_udp      =   8'd17                                   ;
    localparam  idle        =   3'd0                                    ,
                rx_pre      =   3'd1                                    ,
                rx_head     =   3'd2                                    ,
                rx_data     =   3'd3                                    ,
                rx_crc      =   3'd4                                    ,
                rx_err      =   3'd5                                    ,
                fin         =   3'd6                                    ;
    reg     [271:0]             head                ;
    wire    [159:0]             ip_head             ;
    reg     [55:0]              pre                 ;
    reg                         rx_vld              ;
    reg     [7:0]               eth_rx              ;
    reg     [1:0]               cnt_rx              ;
    reg     [5:0]               cnt_ifg             ;
    reg                         rx_flag             ;
    reg     [2:0]               state               ;
    reg     [10:0]              cnt_data            ;
    reg     [10:0]              x                   ;        
    reg     [15:0]              data_len            ;
    reg     [15:0]              sou_port            ;
    reg     [15:0]              des_port            ;
    reg     [17:0]              ip_cali             ;
    reg     [17:0]              ip_correct          ;
    wire    [31:0]              crc_result          ;
    reg     [7:0]               crc_data            ;
    reg                         crc_en              ;
    reg                         crc_rst             ;
    reg     [31:0]              mac_crc             ;
    reg     [31:0]              crc                 ;
    wire                        is_ip               ;
    wire                        is_udp              ;
    wire                        is_v4               ;
    wire                        is_life             ;
    wire                        is_right            ;
    wire                        right_des           ;
    wire                        right_sour          ;
    wire                        to_err              ;
    reg                         err_flag            ;
    wire    [9:0]               d_din               ;
    wire    [12+ETH_NUM-1:0]    m_din               ;
    wire    [9:0]               d_dout              ;
    wire    [12+ETH_NUM-1:0]    m_dout              ;
    wire                        m_wr_en             ;
    wire                        d_wr_en             ;
    wire                        m_rd_en             ;
    wire                        d_rd_en             ;
    wire                        d_empty             ;
    wire                        m_empty             ;
    wire	[7:0]		        tcp_udp		        ;
    wire                        tcpcali_right       ;
    reg		[0:0]		        pre_checksum_rst	;
    reg     [ETH_NUM-1:0]       pkt_type            ;
    wire	[16:0]		        cali_tcp		    ;
    reg 	[16:0]		        cali_tcp_r		    ;
    wire    [95:0]              fake_head           ;
    reg     [17:0]              tcp_cali            ;    
    reg     [17:0]              tcp_correct         ;

    assign  tcpcali_right	=	  (is_udp || !udp_check) || ((&tcp_correct[15:0] || cnt_data < 3) & crc_period)		;
    assign  fake_head	    =	  {ip_sour, ip_des, 8'd0, tcp_udp, data_len}			            ;
    assign  tcp_udp		    =	  is_tcp ? ip_tcp : ip_udp        			                        ;
    assign  in_vld          =     rx_flag & gmii_rx_dv                                              ;
    assign  rx_start        =     !rx_flag & gmii_rx_dv & gmii_rd == 8'h55                          ;
    assign  data_vld        =     in_vld || rx_start                                                ;
    assign  ip_head         =     head[159:0]                                                       ;
    assign  is_ip           =     head[175:160] == mac_type                                         ; 
    assign  is_v4           =     ip_head[159-:8] == ip_ver_len                                     ; 
    assign  is_right        =     (ip_correct[15:0] | ip_head[79-:16]) == 16'hffff                  ;
    assign  is_life         =     |ip_head[95-:8]                                                   ;
    assign  is_tcp          =     ip_head[87-:8] == ip_tcp                                          ;
    assign  is_udp          =     ip_head[87-:8] == ip_udp                                          ;
    assign  right_des       =     ip_head[63:32] == ip_des                                          ;
    assign  right_sour      =     ip_head[31:0] == ip_sour                                          ;
    assign  pre_period      =     state == rx_pre                                                   ;
    assign  head_period     =     state == rx_head                                                  ;
    assign  data_period     =     state == rx_data                                                  ;
    assign  crc_period      =     state == rx_crc                                                   ;
    assign  to_err          =     data_err || head_err || pre_err                                   ;
    assign  sop             =     data_period & rx_vld & cnt_data == 0                              ;
    assign  head_right      =     is_ip & is_life  & (is_tcp || is_udp) & right_des                 ;
    assign  pre_right       =     pre == mac_pre && eth_rx == 8'hd5                                 ;
    assign  d_wr_en         =     ((data_period & rx_vld & cnt_data < data_len) || to_err) & !d_full;
    assign  d_din           =     {sop, eop,  eth_rx}                                               ;
    assign  m_wr_en         =     state == fin & !m_full                                            ;
    assign  m_din           =     {pkt_type, err_flag, data_len[10:0]}                              ;//1+ETH_NUM+11
    assign  d_rd_en         =     !m_empty & !d_empty                                               ;
    assign  m_rd_en         =     d_rd_en & d_dout[8]                                               ;
    assign  eop             =     (data_period & rx_vld & cnt_data == data_len - 1) || to_err       ;
    assign  check_en		=	  data_period & rx_vld			                                    ;
    
    always@(posedge gmii_clk)begin
        if(state == idle)
            pkt_type <= 'b0;
        else
        if(data_period & end_data)
            if(is_udp)
                pkt_type <= 3'b001;
            else
            if(des_port == 4994)
                pkt_type <= 3'b010;
            else
            if(is_tcp)
                pkt_type <= 3'b100;
            else 
                pkt_type <= 'b0;
    end
    
    always @ * begin
        if(cnt_data == 0 & data_period)
            ip_cali = ip_head[15:0] + ip_head[31:16] + ip_head[47:32] + ip_head[63:48] + ip_head[95:80] + ip_head[111:96] + ip_head[127:112] + ip_head[143:128] + ip_head[159:144];
        else
        if(|ip_correct[17:16])
            ip_cali = ip_correct[17:16] + ip_correct[15:0];
        else
            ip_cali = ip_correct;
    end
    always@(posedge gmii_clk)begin
        if(data_period && cnt_data >= 0 && cnt_data < 2 && rx_vld)
            sou_port[15-cnt_data*8-:8] <= eth_rx;
        else
        if(state == idle)
            sou_port <= 16'd0;
    end
    always @(posedge gmii_clk)begin
        if(data_period)
            ip_correct <= ip_cali;
        else
        if(state == idle)
            ip_correct <= 18'd0;
    end  
    always@(posedge gmii_clk)begin
        if(data_period && cnt_data >= 2 && cnt_data <4 && rx_vld)
            des_port[31-cnt_data*8-:8] <= eth_rx;
        else
        if(state == idle)
            des_port <= 16'd0;
    end 
    always @(posedge gmii_clk)begin
        if(gmii_rst)
            rx_flag <= 1'b0;
        else
        if(rx_start)
            rx_flag <= 1'b1;
        else
        if(end_ifg)
            rx_flag <= 1'b0;
    end
    always @(posedge gmii_clk)begin
        if(gmii_rst)
            cnt_rx <= 2'd0;
        else
        if(end_rx)
            cnt_rx <= 2'd0;
        else
        if(add_rx)
            cnt_rx <= cnt_rx + 1'b1;
    end
    assign add_rx =  data_vld                       ;
    assign end_rx =  add_rx & cnt_rx == 1 - 1       ;
    always @(posedge gmii_clk)begin
        if(gmii_rst)
            cnt_ifg <= 6'd0;
        else
        if(end_ifg || gmii_rx_dv)
            cnt_ifg <= 6'd0;
        else
        if(add_ifg)
            cnt_ifg <= cnt_ifg + 1'b1;
    end
    assign add_ifg = rx_flag                                ;
    assign end_ifg = add_ifg & cnt_ifg == wait_time - 1    ;//帧间隙
    always @(posedge gmii_clk)begin
        if(data_vld)
            eth_rx <= gmii_rd;
        else
        if(!rx_flag)
            eth_rx <= 0;            
    end
    always @(posedge gmii_clk)begin
        rx_vld <= end_rx;
    end
    always @(posedge gmii_clk)begin
        if(pre_period & rx_vld)
            pre[55-cnt_data*8-:8] <= eth_rx;
        else
        if(state == idle)
            pre <= 56'd0;
    end
    always @(posedge gmii_clk)begin
        if(head_period & rx_vld)
            head[271-cnt_data*8-:8] <= eth_rx;
        else
        if(state == idle)
            head <= 16'd0;
    end

    always @(posedge gmii_clk)begin
        if(state == rx_err)
            err_flag <= 1'b1;
        else
        if(state == idle)
            err_flag <= 1'b0;
    end
    always @(posedge gmii_clk)begin
        if(crc_period & rx_vld & cnt_data < 4)
            mac_crc[31-cnt_data*8-:8] <= eth_rx;
        else
        if(state == idle)
            mac_crc <= 16'd0;
    end
    always @(posedge gmii_clk)begin
        if(head_data)
            data_len <= ip_head[143-:16] - 20;
        else
        if(state == idle)
            data_len <= 16'd0;
    end

    always @(posedge gmii_clk)begin
        if(gmii_rst) 
            state <= idle;
        else
            case(state)
            idle:
                if(idle_pre)
                    state <= rx_pre;
            rx_pre:
                if(pre_head)
                    state <= rx_head;
                else
                if(pre_err)
                    state <= rx_err;
            rx_head:
                if(head_data)
                    state <= rx_data;
                else
                if(head_err)
                    state <= rx_err;
            rx_data:
                if(data_crc)
                    state <= rx_crc;
                else
                if(data_err)
                    state <= rx_err;
            rx_crc:
                if(crc_fin)
                    state <= fin;
                else
                if(crc_err)
                    state <= rx_err;
            rx_err:
                if(err_fin)
                    state <= fin;
            fin:
                state <= idle;
            default:
                state <= idle;
            endcase
    end
   
    assign idle_pre     =   state == idle && rx_start                                                        ;
    assign pre_head     =   pre_period && pre_right && end_data                                              ;
    assign pre_err      =   pre_period && ((end_data && !pre_right) || !rx_flag)                             ;
    assign head_data    =   head_period && end_data &&  head_right                                           ;
    assign head_err     =   head_period && ((end_data & !head_right) || !rx_flag)                            ;
    assign data_crc     =   data_period && end_data                                                          ;
    assign data_err     =   data_period && !rx_flag                                                          ;
    assign crc_fin      =   crc_period && mac_crc ==  crc                                                    ;
    assign crc_err      =   crc_period && !(rx_flag & is_right & right_sour & tcpcali_right)                 ;
    assign err_fin      =   state == rx_err && !rx_flag                                                      ;
    always @(posedge gmii_clk)begin
        if(gmii_rst)
            cnt_data <= 11'd0;
        else
        if(end_data || state == idle)
            cnt_data <= 11'd0;
        else
        if(add_data)
            cnt_data <= cnt_data + 1'b1;            
    end  
    assign add_data = rx_vld;
    assign end_data = add_data & cnt_data >= x - 1;
    always @* begin
        if(pre_period)
            x = 8;
        else
        if(head_period)
            x = 34;      
        else
        if(state == rx_crc) 
            x = 4;
        else
        if(data_len < 26)
            x = 26;
        else
            x = data_len;
    end  
    always @(posedge gmii_clk)begin
        if(head_period || data_period)begin
            crc_data    <= eth_rx                      ;
            crc_en      <= rx_vld                      ;
        end
        else begin
            crc_data    <= 8'd0                        ;
            crc_en      <= 1'b0                        ;
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
    always @(posedge gmii_clk)begin
        if(crc_period)
            crc <= ~{crc_result[24], crc_result[25], crc_result[26], crc_result[27], crc_result[28], crc_result[29], crc_result[30], crc_result[31], crc_result[16], crc_result[17], crc_result[18], crc_result[19], crc_result[20], crc_result[21], crc_result[22], crc_result[23],crc_result[8], crc_result[9], crc_result[10], crc_result[11], crc_result[12], crc_result[13], crc_result[14], crc_result[15],crc_result[0], crc_result[1], crc_result[2], crc_result[3], crc_result[4], crc_result[5], crc_result[6], crc_result[7]};
        else 
            crc <= 32'hffffffff ;
    end
    always @ * begin
        if(cnt_data == 0 & crc_period & cnt_rx == 0)
            tcp_cali = fake_head[15:0] + fake_head[31:16] + fake_head[47:32] + fake_head[63:48] + fake_head[79:64] + fake_head[95:80] + cali_tcp_r;
        else
        if(|tcp_correct[17:16])
            tcp_cali = tcp_correct[17:16] + tcp_correct[15:0];
        else
            tcp_cali = tcp_correct;
    end
    always @(posedge gmii_clk) begin
        if(data_crc)
            cali_tcp_r <= cali_tcp;
    end
    always @(posedge gmii_clk)begin
        if(gmii_rst)
            tcp_correct <= 18'd0;
        else
        if(crc_period)
            tcp_correct <= tcp_cali;
        else
        if(state == idle)
            tcp_correct <= 18'd0;
    end    
    always@(posedge gmii_clk)begin
        if(gmii_rst)
            pre_checksum_rst <= 1'b1;
        else
            pre_checksum_rst <= state == idle;
    end
    //************************** user_clk ***********************************************
    always @(posedge clk)begin
        dout_vld    <= d_rd_en & !m_dout[11]                 ;
        dout        <= d_dout[7:0]                           ;
        dout_eop    <= d_dout[8] & d_rd_en                   ;
        dout_sop    <= d_dout[9] & d_rd_en                   ;
        dout_len    <= m_empty ? 0 : m_dout[10:0]            ;
        dout_type   <= m_empty ? 0 : m_dout[12+:ETH_NUM]     ;
    end
    checksum check_inst(
        .clk            ( gmii_clk          ),
        .rst            ( pre_checksum_rst  ),  
        .init           ( 17'd0             ),
        .en             ( check_en          ),
        .data           ( eth_rx            ),
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
        .rd_clk         ( clk               ),  
        .rd_rst         ( rst               ),  
        .wr_clk         ( gmii_clk          ),  
        .wr_rst         ( gmii_rst          ),  
		.din		    ( d_din		        ),                // input wire [9 : 0] din
		.wr_en		    ( d_wr_en	        ),            // input wire wr_en
		.rd_en		    ( d_rd_en	        ),            // input wire rd_en
		.dout		    ( d_dout	        ),              // output wire [9 : 0] dout
		.full		    ( d_full	        ),              // output wire full
		.empty		    ( d_empty	        )            // output wire empty
	);      
 	FIFO_asyn #(
        .width          ( 12+ETH_NUM        ),
        .depth          ( 32                )
    )m_fifo_inst(    
        .rd_clk         ( clk               ),  
        .rd_rst         ( rst               ),  
        .wr_clk         ( gmii_clk          ),  
        .wr_rst         ( gmii_rst          ),  
		.din		    ( m_din		        ),                // input wire [10 : 0] din
		.wr_en		    ( m_wr_en	        ),            // input wire wr_en
		.rd_en		    ( m_rd_en	        ),            // input wire rd_en
		.dout		    ( m_dout	        ),              // output wire [10 : 0] dout
		.full		    ( m_full	        ),              // output wire full
		.empty		    ( m_empty	        )            // output wire empty
	);   
endmodule

