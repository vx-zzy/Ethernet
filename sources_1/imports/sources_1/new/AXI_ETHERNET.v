/*
 * @Author: ZhiyuanZhao
 * @Description: 
 * @Date: 2020-12-11 14:17:21
 * @LastEditTime: 2021-01-03 20:20:52
 */
`timescale 1ns / 1ps

module AXI_ETHERNET#(
		parameter C_S_AXI_DATA_WIDTH	= 32                                ,
		parameter C_S_AXI_ADDR_WIDTH	= 32                                ,
        parameter ETH_NUM               = 3                                 ,
        parameter ip_sour               = {8'd192, 8'd168, 8'd1, 8'd254}    ,
        parameter ip_des                = {8'd192, 8'd168, 8'd1, 8'd100}
	)(
		input 											clk				,
		input 											rst				,
		input  		[C_S_AXI_ADDR_WIDTH-1 : 0]      	axi_awaddr		,
		input  		[2 : 0]                         	axi_awprot		,
		input  		                                	axi_awvalid		,
		output 		                                	axi_awready		,
		input  		[C_S_AXI_DATA_WIDTH-1 : 0] 			axi_wdata		,    
		input  		[(C_S_AXI_DATA_WIDTH/8)-1 : 0] 		axi_wstrb		,
		input  		 									axi_wvalid		,
		output 		  									axi_wready		,
		output 		  									axi_bvalid		,
		input  		 									axi_bready		,
		input  		[C_S_AXI_ADDR_WIDTH-1 : 0] 			axi_araddr		,
		input  		[2 : 0] 							axi_arprot		,
		input  		 									axi_arvalid		,
		output 		  									axi_arready		,
		output 		[C_S_AXI_DATA_WIDTH-1 : 0] 			axi_rdata		,
		output   										axi_rvalid		,
		input   										axi_rready		,

		input 											gmii_clk		,
		input 											gmii_rst		,
        output						    				gmii_tx_dv   	,
        output			[7:0]							gmii_td			,
        input                           				gmii_rx_dv      ,
        input                           				gmii_rx_err     ,
        input 			[7:0]							gmii_rd			    
    );
 
	reg 	[C_S_AXI_ADDR_WIDTH-1 : 0] 			awaddr			        ;
	reg 	 									awready			        ;
	reg 	 									wready			        ;
	reg 	 									bvalid			        ;
	reg 	[C_S_AXI_ADDR_WIDTH-1 : 0] 			araddr			        ;
	reg 	 									arready			        ;
	reg 	[C_S_AXI_DATA_WIDTH-1 : 0] 			rdata			        ;
	reg 	 									rvalid			        ;

	wire		 								slv_reg_rden	        ;
	wire		 								slv_reg_wren	        ;
	reg 	[C_S_AXI_DATA_WIDTH-1:0]			reg_data_out	        ;
	integer	 									byte_index		        ;
    integer                          			i                       ;
	reg	 										aw_en			        ;

    wire    [7:0]                               udp1_tx_data            ;
    wire                                        udp1_tx_sop             ;
    wire                                        udp1_tx_eop             ;
    wire                                        udp1_tx_vld             ;
    wire	                                    udp1_rx_vld             ;
    wire                    					tcp1_rx_vld      		;				
    wire    [7:0]           					tcp1_tx_data     		;
    wire                    					tcp1_tx_sop      		;
    wire                    					tcp1_tx_eop      		;
    wire                    					tcp1_tx_vld      		;
    wire                    					tcp2_rx_vld      		;				
    wire    [7:0]           					tcp2_tx_data     		;
    wire                    					tcp2_tx_sop      		;
    wire                    					tcp2_tx_eop      		;
    wire                    					tcp2_tx_vld      		;
    wire	[7:0]                               mac_rx_data		        ;
    wire    [9:0]                               u_din			 		;
    wire                                        u_din_vld[ETH_NUM-1:0]  ;
    wire                                        u_rd_en[ETH_NUM-1:0]    ;
    reg     [31:0]                              u_control[ETH_NUM-1:0]  ;
    wire    [9:0]                               u_dout[ETH_NUM-1:0]     ;
    wire    [31:0]                              u_status[ETH_NUM-1:0]   ;

	assign axi_awready	= awready					            ;
	assign axi_wready	= wready					            ;
	assign axi_bvalid	= bvalid					            ;
	assign axi_arready	= arready					            ;
	assign axi_rdata	= rdata						            ;
	assign axi_rvalid	= rvalid					            ;

    assign u_din		= axi_wdata[9:0]			            ;
    assign u_din_vld[0]	= slv_reg_wren && awaddr == 32'h2	    ;
    assign u_din_vld[1]	= slv_reg_wren && awaddr == 32'h6	    ;
    assign u_din_vld[2]	= slv_reg_wren && awaddr == 32'ha	    ;
    assign u_rd_en[0]	= slv_reg_rden && araddr == 32'h3		;
    assign u_rd_en[1]	= slv_reg_rden && araddr == 32'h7		;
    assign u_rd_en[2]	= slv_reg_rden && araddr == 32'hb		;
	always @( posedge clk )begin
	    if ( rst )begin
	        awready <= 1'b0;
	        aw_en <= 1'b1;
	    end 
	    else   
	    if (~awready && axi_awvalid && axi_wvalid && aw_en)begin
	        awready <= 1'b1;
	        aw_en <= 1'b0;
	    end
	    else if (axi_bready && bvalid)begin
	        aw_en <= 1'b1;
	        awready <= 1'b0;
	    end
	    else           
	        awready <= 1'b0;
	end       

	always @( posedge clk )begin
	    if ( rst )
	        awaddr <= 0;
	    else  
	    if (~awready && axi_awvalid && axi_wvalid && aw_en)
	        awaddr <= axi_awaddr;
	end       

	always @( posedge clk )begin
	    if ( rst )
	        wready <= 1'b0;
	    else  
	    if (~wready && axi_wvalid && axi_awvalid && aw_en )
	        wready <= 1'b1;
	    else
	        wready <= 1'b0;
	end       

	assign slv_reg_wren = wready && axi_wvalid && awready && axi_awvalid;

	always @( posedge clk )begin
	    if ( rst )begin
            u_control[0] <= 32'd5000;
            u_control[1] <= 32'd0;
			u_control[2] <= 32'd5001;
	    end 
	    else begin
	      if (slv_reg_wren)
	        begin
	          case ( awaddr) 
	            32'h1:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	                if ( axi_wstrb[byte_index] == 1 ) begin
	                    u_control[0][(byte_index*8) +: 8] <= axi_wdata[(byte_index*8) +: 8];
	                end  
				32'h5:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	                if ( axi_wstrb[byte_index] == 1 ) begin
	                    u_control[1][(byte_index*8) +: 8] <= axi_wdata[(byte_index*8) +: 8];
	                end  
				32'h9:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	                if ( axi_wstrb[byte_index] == 1 ) begin
	                    u_control[2][(byte_index*8) +: 8] <= axi_wdata[(byte_index*8) +: 8];
	                end  
	          endcase
	        end
	    end
	end    

	always @( posedge clk )begin
	    if ( rst )
	        bvalid  <= 0;
	    else   
	    if (awready && axi_awvalid && ~bvalid && wready && axi_wvalid)
	        bvalid <= 1'b1;
	    else
	    if (axi_bready && bvalid) 
	        bvalid <= 1'b0; 
	end   

	always @( posedge clk )begin
	    if ( rst )begin
	        arready <= 1'b0;
	        araddr  <= 32'b0;
	    end 
	    else     
	    if (~arready && axi_arvalid)begin
	        arready <= 1'b1;
	        araddr  <= axi_araddr;
	    end
	    else
	        arready <= 1'b0;
	end       
 
	always @( posedge clk )begin
	    if ( rst )
	        rvalid <= 0;
	    else   
	    if (arready && axi_arvalid && ~rvalid)
	        rvalid <= 1'b1;   
	    else 
        if (rvalid && axi_rready)
	        rvalid <= 1'b0;
	end    

	assign slv_reg_rden = arready & axi_arvalid & ~rvalid;
	always @(*)begin
	    case ( araddr )
	      32'h0   : reg_data_out = u_status[0];
	      32'h1   : reg_data_out = u_control[0];
	      32'h3   : reg_data_out = u_dout[0];
	      32'h4   : reg_data_out = u_status[1];
	      32'h5   : reg_data_out = u_control[1];
	      32'h7   : reg_data_out = u_dout[1];
	      32'h8   : reg_data_out = u_status[2];
	      32'h9   : reg_data_out = u_control[2];
	      32'hb   : reg_data_out = u_dout[2];
	      default:  reg_data_out = 0;
	    endcase
	end

	always @( posedge clk )begin
	    if ( rst )
	        rdata  <= 0;
	    else    
	    if (slv_reg_rden)
	        rdata <= reg_data_out;     // register read data  
	end 

    Inter_Transmission #(
        .ip_des         ( ip_des                    ),
        .ip_sour        ( ip_sour                   ),
        .ETH_NUM        ( ETH_NUM                   )
    )Transmission_inst(
        .clk            ( clk                   	),
        .rst            ( rst                   	),
		.gmii_clk       ( gmii_clk                  ),
        .gmii_rst       ( gmii_rst                  ), 
		.gmii_rx_dv     ( gmii_rx_dv & !gmii_rx_err ),
		.gmii_rd        ( gmii_rd                   ),
		.gmii_tx_dv     ( gmii_tx_dv                ),
		.gmii_td        ( gmii_td                   ),
        .dev_tx_data    ( {tcp2_tx_data, tcp1_tx_data, udp1_tx_data}        ),
        .dev_tx_sop     ( {tcp2_tx_sop , tcp1_tx_sop , udp1_tx_sop }        ),
        .dev_tx_eop     ( {tcp2_tx_eop , tcp1_tx_eop , udp1_tx_eop }        ),
        .dev_tx_vld     ( {tcp2_tx_vld , tcp1_tx_vld , udp1_tx_vld }        ),
        .dev_rx_vld     ( {tcp2_rx_vld , tcp1_rx_vld , udp1_rx_vld }        ),
        .rx_sop         ( mac_rx_sop                ),
        .rx_eop         ( mac_rx_eop                ),
        .rx_data        ( mac_rx_data               )   
   
    );
    UDP #(
        .src_port       ( 16'd4399          ),
        .dst_port       ( 16'd5000	        )
    )UDP_inst(
        .clk            ( clk               ),
        .rst            ( rst               ),
        .u_din          ( u_din          	),
        .u_din_vld      ( u_din_vld[0]      ),
        .u_rd_en        ( u_rd_en[0]        ),
        .u_dout         ( u_dout[0]         ),
        .u_status       ( u_status[0]       ),
		.u_control		( u_control[0]      ),
        .din_vld        ( udp1_rx_vld       ),
        .din            ( mac_rx_data       ),
        .din_sop        ( mac_rx_sop        ),
        .din_eop        ( mac_rx_eop        ),
        .dout_vld       ( udp1_tx_vld       ),
        .dout           ( udp1_tx_data      ),
        .dout_sop       ( udp1_tx_sop       ),
        .dout_eop       ( udp1_tx_eop       )               
    );
    TCP_server TCP_server_inst(
        .clk            ( clk               ),
        .rst            ( rst               ),
        .u_din          ( u_din 	        ),
        .u_din_vld      ( u_din_vld[1]      ),
        .u_rd_en        ( u_rd_en[1]        ),
        .u_dout         ( u_dout[1]         ),
        .u_status       ( u_status[1]       ),
		.u_control		( u_control[1]      ),
        .din_vld        ( tcp1_rx_vld       ),
        .din            ( mac_rx_data       ),
        .din_sop        ( mac_rx_sop        ),
        .din_eop        ( mac_rx_eop        ),
        .dout_vld       ( tcp1_tx_vld       ),
        .dout           ( tcp1_tx_data      ),
        .dout_sop       ( tcp1_tx_sop       ),
        .dout_eop       ( tcp1_tx_eop       )               
    ); 
	TCP_client TCP_client_inst(
        .clk            ( clk               ),
        .rst            ( rst               ),
        .u_din          ( u_din 	        ),
        .u_din_vld      ( u_din_vld[2]      ),
        .u_rd_en        ( u_rd_en[2]        ),
        .u_dout         ( u_dout[2]         ),
        .u_status       ( u_status[2]       ),
		.u_control		( u_control[2]		),
        .din_vld        ( tcp2_rx_vld       ),
        .din            ( mac_rx_data       ),
        .din_sop        ( mac_rx_sop        ),
        .din_eop        ( mac_rx_eop        ),
        .dout_vld       ( tcp2_tx_vld       ),
        .dout           ( tcp2_tx_data      ),
        .dout_sop       ( tcp2_tx_sop       ),
        .dout_eop       ( tcp2_tx_eop       )               
    );


 /*   smi smi_inst(
        .clk            ( clk_50            ),
        .rst            ( rst_50            ),
        .rd_vld         ( rd_vld            ),
        .mode           ( mode              ),
        .rd_data        ( rd_data           ),
        .wr_data        ( wr_data           ), 
        .addr           ( smi_addr          ),
        .oper_en        ( oper_en           ),
        .md_in          ( md_in             ),
        .md_out         ( md_out            ),
        .md_en          ( md_en             ),
        .md_c           ( mdc               )
        
    );*/
	endmodule
