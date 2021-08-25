/*
 * @Author: ZhiyuanZhao
 * @Description: 
 * @Date: 2020-12-07 22:00:05
 * @LastEditTime: 2021-04-30 15:12:59
 */
`timescale 1ns / 1ps

module Inter_Transmission#(
    parameter ip_sour = {8'd192, 8'd168, 8'd1, 8'd254},
    parameter ip_des  = {8'd192, 8'd168, 8'd1, 8'd100},
    parameter ETH_NUM = 1'b1
)(
        input                                   clk             ,
        input                                   rst             ,
        input   		                        gmii_clk 		,              
        input   		                        gmii_rst 		,                                      
        input   		                        gmii_rx_dv 		,                          
        input           [7:0]	                gmii_rd 		,                           
        output          [7:0]	                gmii_td 		,              
        output		                            gmii_tx_dv 		,              
        input           [ETH_NUM*8-1:0]         dev_tx_data     ,
        input           [ETH_NUM-1:0]           dev_tx_sop      ,
        input           [ETH_NUM-1:0]           dev_tx_eop      ,
        input           [ETH_NUM-1:0]           dev_tx_vld      ,
        output          [ETH_NUM-1:0]           dev_rx_vld      ,
        output                                  rx_sop          ,
        output                                  rx_eop          ,
        output          [7:0]                   rx_data         
    );
    wire                                tx_vld                          ;
    wire                                rx_vld                          ;					
    wire    [ETH_NUM-1:0]               rx_type                         ;
    wire    [ETH_NUM-1:0]               tx_type                         ;
    wire    [10:0]                      rx_len                          ;
    wire	[ETH_NUM-1:0]	            fifo_wr_en		                ;
    wire	[ETH_NUM-1:0]	            fifo_empty		                ;
    wire	[ETH_NUM-1:0]	            fifo_full		                ;
    wire	[ETH_NUM-1:0]	            fifo_rd_en		                ;
    reg		[ETH_NUM-1:0]               bus_sel		                    ;
    wire	[9:0]			            fifo_din[ETH_NUM-1:0]		    ;
    wire	[9:0]			            fifo_dout[ETH_NUM-1:0]		    ;
    wire    [9:0]                       tx_data                         ;
    reg		                		    tx_flag                         ;   
    genvar                              i                               ;
    assign fifo_wr_en		=	dev_tx_vld & ~fifo_full			        ;
    assign fifo_rd_en		=	bus_sel & ~fifo_empty & {ETH_NUM{rdy}}  ;   
    assign tx_type		    =	fifo_rd_en			                    ;
    assign tx_vld		    =	|fifo_rd_en			                    ;
    assign tx_last		    =	tx_vld && tx_data[8]			        ;
    always@(posedge clk)begin
        if(rst)
            tx_flag <= 1'b0;
        else
        if(tx_last)
            tx_flag <= 1'b0;
        else
        if(tx_vld) 
            tx_flag <= 1'b1;
    end
    always@(posedge clk)begin
        if(rst)
            bus_sel <= 'b1;
        else
        if(bus_sel == 0)
            bus_sel <= 'b1;
        else
        if(tx_last)
            bus_sel <= 'b0;
        else
        if(!tx_vld && ETH_NUM != 1)//可使用cnt进行计数，单独对cnt进行译码为独热码
            bus_sel <= {bus_sel[ETH_NUM-2:0],bus_sel[ETH_NUM-1]};
    end
    generate for(i=0;i<ETH_NUM;i=i+1) begin : BUFFER
        assign dev_rx_vld[i]		=	rx_type[i] && rx_vld			                    ;
        assign fifo_din[i]		    =	{dev_tx_sop[i], dev_tx_eop[i], dev_tx_data[i*8+:8]}	;
        assign tx_data		        =	|bus_sel ? (bus_sel[i]	? fifo_dout[i] : 'bz) : 'd0 ;
        FIFO_syn#(
            .width          ( 10                ),
            .depth          ( 2048              )
        ) fifo_inst(          
            .clk            ( clk               ),  // input wire wr_clk
            .srst           ( rst               ),  // input wire wr_rst
		    .din		    ( fifo_din[i]	    ),                // input wire [10 : 0] din
		    .wr_en		    ( fifo_wr_en[i]     ),            // input wire wr_en
		    .rd_en		    ( fifo_rd_en[i]     ),            // input wire rd_en
		    .dout		    ( fifo_dout[i]	    ),              // output wire [10 : 0] dout
		    .full		    ( fifo_full[i]	    ),              // output wire full
		    .empty		    ( fifo_empty[i]     )            // output wire empty       
        );
    end
    endgenerate


    ethernet_rx #(
        .ip_des         ( ip_des            ),
        .ip_sour        ( ip_sour           ),
        .ETH_NUM        ( ETH_NUM           ),
        .udp_check      ( 1'b0              )
    )mac_rx_inst(
        .clk            ( clk               ),
        .rst            ( rst               ),
        .gmii_rst       ( gmii_rst          ), 
		.gmii_clk       ( gmii_clk          ),
		.gmii_rx_dv     ( gmii_rx_dv        ),
		.gmii_rd        ( gmii_rd           ),
        .dout_type      ( rx_type           ),
        .dout_vld       ( rx_vld            ),
        .dout           ( rx_data           ),
        .dout_sop       ( rx_sop            ),
        .dout_len       ( rx_len            ),
        .dout_eop       ( rx_eop            )
    );
    ethernet_tx #(
        .ETH_NUM        ( ETH_NUM           ),
        .ip_des         ( ip_des            ),
        .ip_sour        ( ip_sour           )
    )mac_tx_inst(
        .clk            ( clk               ),
        .rst            ( rst               ),
        .gmii_clk       ( gmii_clk          ),
        .gmii_rst       ( gmii_rst          ), 
        .rdy            ( rdy               ),
		.gmii_tx_dv     ( gmii_tx_dv        ),
		.gmii_td        ( gmii_td           ),
        .din_vld        ( tx_vld            ),
        .din_type       ( fifo_rd_en        ),
        .din            ( tx_data[7:0]      ),
        .din_sop        ( tx_data[9]        ),
        .din_eop        ( tx_data[8]        )
    );  
endmodule
