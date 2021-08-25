`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/19 11:08:47
// Design Name: 
// Module Name: TCP_correspond
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


module ETHERNET_Transmission#(
    parameter ip_sour = {8'd192, 8'd168, 8'd1, 8'd254},
    parameter ip_des  = {8'd192, 8'd168, 8'd1, 8'd100},
    parameter ETH_NUM = 1'b1
)(
        input                       clk             ,
        input                       rst             ,
	    input	 	    		    rgmii_rx_clk	,
	    input	 	    		    rgmii_rx_ctl	,
	    input	 	    [3:0]	    rgmii_rd 		,
	    output	  	    		    rgmii_tx_clk	,
	    output	  	    		    rgmii_tx_ctl	,
        output	  	    [3:0]	    rgmii_td    	,
        input           [7:0]       udp1_tx_data    ,
        input                       udp1_tx_sop     ,
        input                       udp1_tx_eop     ,
        input                       udp1_tx_vld     ,
        output                      udp1_rx_vld     ,
/*        output                      tcp1_rx_vld     ,
        input           [7:0]       tcp1_tx_data    ,
        input                       tcp1_tx_sop     ,
        input                       tcp1_tx_eop     ,
        input                       tcp1_tx_vld     ,
        output                      tcp2_rx_vld     ,
        input           [7:0]       tcp2_tx_data    ,
        input                       tcp2_tx_sop     ,
        input                       tcp2_tx_eop     ,
        input                       tcp2_tx_vld     ,*/
        output                      rx_sop          ,
        output                      rx_eop          ,
        output          [7:0]       rx_data         
    );
    reg     [7:0]           tx_data          ;
    reg                     tx_sop           ;
    reg	                    tx_eop           ;
    reg                     tx_vld           ;
    wire                    rx_vld           ;					
    wire    [1:0]           rx_type          ;
    reg     [1:0]           tx_type          ;
    wire    [10:0]          rx_len           ;
    reg	    [1:0]           state			 ;
    wire	[9:0]			tcp1_din		 ;
    wire	[9:0]			tcp1_dout		 ;
    wire	[0:0]			tcp1_wr_en		 ;
    wire	[0:0]			tcp1_rd_en		 ;
    wire	[9:0]			tcp2_din		 ;
    wire	[9:0]			tcp2_dout		 ;
    wire	[0:0]			tcp2_wr_en		 ;
    wire	[0:0]			tcp2_rd_en		 ;
    wire	[0:0]			udp1_wr_en		 ;
    wire	[0:0]			udp1_empty		 ;
    wire	[0:0]			tcp1_empty		 ;
    wire	[0:0]			udp1_rd_en		 ;
    wire	[9:0]			udp1_din		 ;
    wire	[9:0]			udp1_dout		 ;
    localparam  idle = 2'b00     ,
                tcp1 = 2'b01     ,
                tcp2 = 2'b10     ,
                udp1 = 2'b11     ;
    assign state_idle		=	state == idle			                    ;
    assign state_tcp1		=	state == tcp1			                    ;
    assign state_tcp2		=	state == tcp2			                    ;
    assign state_udp1		=	state == udp1			                    ;
/*    assign tcp1_rx_vld		=	rx_type == 2'b00 ? rx_vld : 1'b0            ;
    assign tcp2_rx_vld		=	rx_type == 2'b01 ? rx_vld : 1'b0            ;
    assign tcp1_wr_en		=	tcp1_tx_vld & !tcp1_full         			;
    assign tcp1_din		    =	{tcp1_tx_sop, tcp1_tx_eop, tcp1_tx_data}	;
    assign tcp1_rd_en		=	state_tcp1 & !tcp1_empty        			;
    assign tcp2_wr_en		=	tcp2_tx_vld & !tcp2_full         			;
    assign tcp2_din		    =	{tcp2_tx_sop, tcp2_tx_eop, tcp2_tx_data}	;
    assign tcp2_rd_en		=	state_tcp2 & !tcp2_empty        			;*/
    assign udp1_wr_en		=	udp1_tx_vld & !udp1_full			        ;
    assign udp1_din		    =	{udp1_tx_sop, udp1_tx_eop, udp1_tx_data}	;
    assign udp1_rd_en		=	state_udp1 & !udp1_empty			        ;   
    assign udp1_rx_vld		=	rx_type == 2'b11 ? rx_vld : 1'b0			;
    always@(posedge clk)begin
        if(state_tcp1)begin
            tx_vld  <= tcp1_rd_en                   ;
            tx_sop  <= tcp1_dout[9] &  tcp1_rd_en   ;
            tx_eop  <= tcp1_dout[8] &  tcp1_rd_en   ;
            tx_data <= tcp1_dout[7:0]               ;
            tx_type <= 2'b00                        ;
        end
        else
        if(state_tcp2)begin
            tx_vld  <= tcp2_rd_en                   ;
            tx_sop  <= tcp2_dout[9] &  tcp2_rd_en   ;
            tx_eop  <= tcp2_dout[8] &  tcp2_rd_en   ;
            tx_data <= tcp2_dout[7:0]               ;
            tx_type <= 2'b00                        ;
        end
        else
        if(state_udp1)begin
            tx_vld  <= udp1_rd_en                   ;
            tx_sop  <= udp1_dout[9] &  udp1_rd_en   ;
            tx_eop  <= udp1_dout[8] &  udp1_rd_en   ;
            tx_data <= udp1_dout[7:0]               ;
            tx_type <= 2'b11                        ;
        end
        else begin
            tx_vld  <= 1'b0                         ;
            tx_sop  <= 1'b0                         ;
            tx_eop  <= 1'b0                         ;
            tx_data <= udp1_dout[7:0]               ;
            tx_type <= 2'b00                        ;
        end
    end
    always@(posedge clk)begin
        if(rst)
            state <= idle;
        else
        case(state)
        idle:
            //if(idle_tcp1)
            //    state <= tcp1;
            //else
            //if(idle_tcp2)
            //    state <= tcp2;
            //else
            if(idle_udp1)
                state <= udp1;
        tcp1:
            if(tcp1_idle)
                state <= idle;
        tcp2:
            if(tcp2_idle)
                state <= idle;
        udp1:
            if(udp1_idle)
                state <= idle;
        default:state <= idle;
        endcase
    end
//    assign idle_tcp1		=	state_idle & !tcp1_empty			        ;
//    assign idle_tcp2		=	state_idle & !tcp2_empty			        ;
    assign idle_udp1		=	state_idle & !udp1_empty			        ;
    assign tcp1_idle		=	state_tcp1 & tcp1_dout[8] & tcp1_rd_en		;
    assign tcp2_idle		=	state_tcp2 & tcp2_dout[8] & tcp2_rd_en		;
    assign udp1_idle		=	state_udp1 & udp1_dout[8] & udp1_rd_en		;
/*    trans_fifo tcp1_fifo_inst(
        .clk        ( clk                   ),  // input wire wr_clk
        .srst       ( rst                   ),  // input wire wr_rst
		.din		( tcp1_din	            ),                // input wire [10 : 0] din
		.wr_en		( tcp1_wr_en            ),            // input wire wr_en
		.rd_en		( tcp1_rd_en            ),            // input wire rd_en
		.dout		( tcp1_dout	            ),              // output wire [10 : 0] dout
		.full		( tcp1_full	            ),              // output wire full
		.empty		( tcp1_empty            )            // output wire empty       
   );      
    trans_fifo tcp2_fifo_inst(
        .clk        ( clk                   ),  // input wire wr_clk
        .srst       ( rst                   ),  // input wire wr_rst
		.din		( tcp2_din	            ),                // input wire [10 : 0] din
		.wr_en		( tcp2_wr_en            ),            // input wire wr_en
		.rd_en		( tcp2_rd_en            ),            // input wire rd_en
		.dout		( tcp2_dout	            ),              // output wire [10 : 0] dout
		.full		( tcp2_full	            ),              // output wire full
		.empty		( tcp2_empty            )            // output wire empty       
   );           */
    trans_fifo udp1_fifo_inst(          
        .clk        ( clk                   ),  // input wire wr_clk
        .srst       ( rst                   ),  // input wire wr_rst
		.din		( udp1_din	            ),                // input wire [10 : 0] din
		.wr_en		( udp1_wr_en            ),            // input wire wr_en
		.rd_en		( udp1_rd_en            ),            // input wire rd_en
		.dout		( udp1_dout	            ),              // output wire [10 : 0] dout
		.full		( udp1_full	            ),              // output wire full
		.empty		( udp1_empty            )            // output wire empty       
   );

    ethernet_rx #(
        .ip_des         ( ip_des            ),
        .ip_sour        ( ip_sour           ),
        .udp_check      ( 1'b0              )
    )mac_rx_inst(
        .clk            ( clk               ),
        .rst            ( rst               ),
        .rxd            ( rxd               ),
        .crs_dv         ( crs_dv            ),
        .dout_type      ( rx_type           ),
        .dout_vld       ( rx_vld            ),
        .dout           ( rx_data           ),
        .dout_sop       ( rx_sop            ),
        .dout_len       ( rx_len            ),
        .dout_eop       ( rx_eop            )
    );
    ethernet_tx #(
        .ip_des         ( ip_des            ),
        .ip_sour        ( ip_sour           )
    )mac_tx_inst(
        .clk            ( clk               ),
        .rst            ( rst               ),
        .txd            ( txd               ),
        .tx_en          ( tx_en             ),
        .din_vld        ( tx_vld            ),
        .din_type       ( tx_type           ),
        .din            ( tx_data           ),
        .din_sop        ( tx_sop            ),
        .din_eop        ( tx_eop            )
    );  
endmodule
