/*
 * @Author: ZhiyuanZhao
 * @Description: 
 * @Date: 2020-12-03 21:50:24
 * @LastEditTime: 2021-03-20 16:03:47
 */
`timescale 1ns / 1ps

module top#(          
        parameter ip_sour               = {8'd192, 8'd168, 8'd1, 8'd254}    ,
        parameter ip_des                = {8'd192, 8'd168, 8'd1, 8'd100}    ,
        parameter ETH_NUM               = 3   
)(
        input               clk             ,
        input               rst_n           ,
	    input	 			rgmii_rx_clk	,
	    input	 			rgmii_rx_ctl	,
	    input	 	[3:0]	rgmii_rd 		,
	    output	  			rgmii_tx_clk	,
	    output	  			rgmii_tx_ctl	,
	    output	  	[3:0]	rgmii_td    	,
	    output 	 			phy_rst 		,
        output      [2:0]   led
  
    );

    localparam              sword   = 32    ;
    localparam              masters = 1     ;
    localparam              slaves  = 3     ;
    localparam [slaves*sword-1:0] addr_mask = {32'h0000000F,32'h0000000F,32'h0000000F,32'h0000000F,32'h00003FFF};
    localparam [slaves*sword-1:0] addr_use  = {32'h00004040,32'h00004030,32'h00004020,32'h00004010,32'h00000000};

    wire                                        locked                        ;
    wire	[7:0]                               gmii_td		                  ;
    wire	[7:0]                               gmii_rd		                  ;
    assign  gmii_txc	    =	gmii_rxc			                          ;
    assign  phy_rst         =   1'b1                                          ;

    wire [masters-1:0]       m_axi_awvalid  ;
    wire [masters-1:0]       m_axi_awready  ;
    wire [masters*sword-1:0] m_axi_awaddr   ;
    wire [masters*3-1:0]     m_axi_awprot   ;

    wire [masters-1:0]       m_axi_wvalid   ;
    wire [masters-1:0]       m_axi_wready   ;
    wire [masters*sword-1:0] m_axi_wdata    ;
    wire [masters*4-1:0]     m_axi_wstrb    ;

    wire [masters-1:0]       m_axi_bvalid   ;
    wire [masters-1:0]       m_axi_bready   ;

    wire [masters-1:0]       m_axi_arvalid  ;
    wire [masters-1:0]       m_axi_arready  ;
    wire [masters*sword-1:0] m_axi_araddr   ;
    wire [masters*3-1:0]     m_axi_arprot   ;

    wire [masters-1:0]       m_axi_rvalid   ;
    wire [masters-1:0]       m_axi_rready   ;
    wire [masters*sword-1:0] m_axi_rdata    ;   

    // AXI4-lite slave memory interfaces

    wire [slaves-1:0]       s_axi_awvalid   ;
    wire [slaves-1:0]       s_axi_awready   ;
    wire [slaves*sword-1:0] s_axi_awaddr    ;
    wire [slaves*3-1:0]     s_axi_awprot    ;
    wire [slaves-1:0]       s_axi_wvalid    ;
    wire [slaves-1:0]       s_axi_wready    ;
    wire [slaves*sword-1:0] s_axi_wdata     ;
    wire [slaves*4-1:0]     s_axi_wstrb     ;      
    wire [slaves-1:0]       s_axi_bvalid    ;
    wire [slaves-1:0]       s_axi_bready    ;      
    wire [slaves-1:0]       s_axi_arvalid   ;
    wire [slaves-1:0]       s_axi_arready   ;
    wire [slaves*sword-1:0] s_axi_araddr    ;
    wire [slaves*3-1:0]     s_axi_arprot    ;      
    wire [slaves-1:0]       s_axi_rvalid    ;
    wire [slaves-1:0]       s_axi_rready    ;
    wire [slaves*sword-1:0] s_axi_rdata     ;
    // THE CONCENTRATION

    wire [sword-1:0] m_axi_awaddr_o [0:masters-1]   ;
    wire [3-1:0]     m_axi_awprot_o [0:masters-1]   ;
    wire [sword-1:0] m_axi_wdata_o [0:masters-1]    ;
    wire [4-1:0]     m_axi_wstrb_o [0:masters-1]    ;
    wire [sword-1:0] m_axi_araddr_o [0:masters-1]   ;
    wire [3-1:0]     m_axi_arprot_o [0:masters-1]   ;
    wire [sword-1:0] m_axi_rdata_o [0:masters-1]    ;
    wire [sword-1:0] s_axi_awaddr_o [0:slaves-1]    ;
    wire [3-1:0]     s_axi_awprot_o [0:slaves-1]    ;
    wire [sword-1:0] s_axi_wdata_o [0:slaves-1]     ;
    wire [4-1:0]     s_axi_wstrb_o [0:slaves-1]     ;
    wire [sword-1:0] s_axi_araddr_o [0:slaves-1]    ;
    wire [3-1:0]     s_axi_arprot_o [0:slaves-1]    ;
    wire [sword-1:0] s_axi_rdata_o [0:slaves-1]     ;

    wire  [sword-1:0] addr_mask_o [0:slaves-1]      ;
    wire  [sword-1:0] addr_use_o [0:slaves-1]       ;
    wire  [31:0]      irq                           ;
    assign irq		=	{31'd0, sm3_irq}			;          
    genvar k;
    generate
        for(k = 0; k < masters; k=k+1) begin
            assign m_axi_awaddr[(k+1)*sword-1:k*sword] = m_axi_awaddr_o[k];
            assign m_axi_awprot[(k+1)*3-1:k*3] = m_axi_awprot_o[k];
            assign m_axi_wdata[(k+1)*sword-1:k*sword] = m_axi_wdata_o[k];
            assign m_axi_wstrb[(k+1)*4-1:k*4] = m_axi_wstrb_o[k];
            assign m_axi_araddr[(k+1)*sword-1:k*sword] = m_axi_araddr_o[k];
            assign m_axi_arprot[(k+1)*3-1:k*3] = m_axi_arprot_o[k];
            assign m_axi_rdata_o[k] = m_axi_rdata[(k+1)*sword-1:k*sword];
        end
        for(k = 0; k < slaves; k=k+1) begin
            assign s_axi_awaddr_o[k] = s_axi_awaddr[(k+1)*sword-1:k*sword] ? (s_axi_awaddr[(k+1)*sword-1:k*sword] - addr_use[(k+1)*sword-1:k*sword]) : s_axi_awaddr[(k+1)*sword-1:k*sword];
            assign s_axi_awprot_o[k] = s_axi_awprot[(k+1)*3-1:k*3];
            assign s_axi_wdata_o[k] = s_axi_wdata[(k+1)*sword-1:k*sword];
            assign s_axi_wstrb_o[k] = s_axi_wstrb[(k+1)*4-1:k*4];
            assign s_axi_araddr_o[k] = s_axi_araddr[(k+1)*sword-1:k*sword] ? (s_axi_araddr[(k+1)*sword-1:k*sword] - addr_use[(k+1)*sword-1:k*sword]) : s_axi_araddr[(k+1)*sword-1:k*sword];
            assign s_axi_arprot_o[k] = s_axi_arprot[(k+1)*3-1:k*3];
            assign addr_mask_o[k] = addr_mask[(k+1)*sword-1:k*sword];
            assign addr_use_o[k] = addr_use[(k+1)*sword-1:k*sword];
            assign s_axi_rdata[(k+1)*sword-1:k*sword] = s_axi_rdata_o[k];
        end
    endgenerate
    pll pll_inst(
        .clk_in         ( clk                       ),
        .clk_out1       (                    ),
        .clk_out2       ( clk_100                   ),
        .locked         ( locked                    )
    );
    RESET #(
        .clk_num        ( 2                         )
    )reset_inst(
        .clk            ( {clk_100, gmii_rxc}       ),
        .rst_n          ( rst_n & locked                  ),
        .rst            ( {rst_100, gmii_rst}    )
    );
    // AXI INTERCONNECT, axi4_interconnect
    axi4_interconnect   #(
        .masters        ( masters           ),
        .slaves         ( slaves            ),
        .sword          ( sword             ),
        .addressing     ( 0                 ),
        .addr_mask      ( addr_mask         ),
        .addr_use       ( addr_use          )
    ) inst_axi4_interconnect
    (
        .CLK            ( clk_100           ),
        .RST            ( rst_100           ),
        .m_axi_awvalid  ( m_axi_awvalid     ),
        .m_axi_awready  ( m_axi_awready     ),
        .m_axi_awaddr   ( m_axi_awaddr      ),
        .m_axi_awprot   ( m_axi_awprot      ),
        .m_axi_wvalid   ( m_axi_wvalid      ),
        .m_axi_wready   ( m_axi_wready      ),
        .m_axi_wdata    ( m_axi_wdata       ),
        .m_axi_wstrb    ( m_axi_wstrb       ),
        .m_axi_bvalid   ( m_axi_bvalid      ),
        .m_axi_bready   ( m_axi_bready      ),
        .m_axi_arvalid  ( m_axi_arvalid     ),
        .m_axi_arready  ( m_axi_arready     ),
        .m_axi_araddr   ( m_axi_araddr      ),
        .m_axi_arprot   ( m_axi_arprot      ),
        .m_axi_rvalid   ( m_axi_rvalid      ),
        .m_axi_rready   ( m_axi_rready      ),
        .m_axi_rdata    ( m_axi_rdata       ),
        .s_axi_awvalid  ( s_axi_awvalid     ),
        .s_axi_awready  ( s_axi_awready     ),
        .s_axi_awaddr   ( s_axi_awaddr      ),
        .s_axi_awprot   ( s_axi_awprot      ),
        .s_axi_wvalid   ( s_axi_wvalid      ),
        .s_axi_wready   ( s_axi_wready      ),
        .s_axi_wdata    ( s_axi_wdata       ),
        .s_axi_wstrb    ( s_axi_wstrb       ),
        .s_axi_bvalid   ( s_axi_bvalid      ),
        .s_axi_bready   ( s_axi_bready      ),
        .s_axi_arvalid  ( s_axi_arvalid     ),
        .s_axi_arready  ( s_axi_arready     ),
        .s_axi_araddr   ( s_axi_araddr      ),
        .s_axi_arprot   ( s_axi_arprot      ),
        .s_axi_rvalid   ( s_axi_rvalid      ),
        .s_axi_rready   ( s_axi_rready      ),
        .s_axi_rdata    ( s_axi_rdata       )
    ); 

    wire [31:0] picorvcore_awaddr; assign m_axi_awaddr_o[0] = {2'b00, picorvcore_awaddr[31:2]};
    wire [31:0] picorvcore_araddr; assign m_axi_araddr_o[0] = {2'b00, picorvcore_araddr[31:2]};
    picorv32_axi inst_picorv32_axi
    (
        .clk            ( clk_100           ), 
        .resetn         ( !rst_100          ), 
        .trap           (                   ),
        .mem_axi_awvalid( m_axi_awvalid[0]  ),
        .mem_axi_awready( m_axi_awready[0]  ),
        .mem_axi_awaddr ( picorvcore_awaddr ),
        .mem_axi_awprot ( m_axi_awprot_o[0] ),
        .mem_axi_wvalid ( m_axi_wvalid[0]   ),
        .mem_axi_wready ( m_axi_wready[0]   ),
        .mem_axi_wdata  ( m_axi_wdata_o[0]  ),
        .mem_axi_wstrb  ( m_axi_wstrb_o[0]  ),
        .mem_axi_bvalid ( m_axi_bvalid[0]   ),
        .mem_axi_bready ( m_axi_bready[0]   ),
        .mem_axi_arvalid( m_axi_arvalid[0]  ),
        .mem_axi_arready( m_axi_arready[0]  ),
        .mem_axi_araddr ( picorvcore_araddr ),
        .mem_axi_arprot ( m_axi_arprot_o[0] ),
        .mem_axi_rvalid ( m_axi_rvalid[0]   ),
        .mem_axi_rready ( m_axi_rready[0]   ),
        .mem_axi_rdata  ( m_axi_rdata_o[0]  ),
        .irq            ( irq               ),
        .eoi            (                   )
    );
    // Slave 1, AXI_INSTR_RAM
    AXI_INSTR_RAM #(
        .RAM_WIDTH      ( 32                ),                      
        .RAM_DEPTH      ( 16384             ),                     
        .INIT_FILE      ( "G:/ZYNQ7000_X7Z015-2CLG485L/Ethernet_1G/IP/instr.verilog")  // Specify name/location of RAM initialization file if using one (leave blank if not)
    )inst_AXI_INSTR_RAM_s00(
        .clk            ( clk_100           ),
        .rst            ( rst_100           ),
      //  .rx             ( uart_rx           ),                        // input wire rx
        .rx             ( 1'b0           ),                        // input wire rx
        .tx             ( uart_tx           ),                        // output wire tx
        .rst_core       ( rst_core          ),
        .axi_awvalid    ( s_axi_awvalid[0]  ),
        .axi_awready    ( s_axi_awready[0]  ),
        .axi_awaddr     ( s_axi_awaddr_o[0] ),
        .axi_awprot     ( s_axi_awprot_o[0] ),
        .axi_wvalid     ( s_axi_wvalid[0]   ),
        .axi_wready     ( s_axi_wready[0]   ),
        .axi_wdata      ( s_axi_wdata_o[0]  ),
        .axi_wstrb      ( s_axi_wstrb_o[0]  ),
        .axi_bvalid     ( s_axi_bvalid[0]   ),
        .axi_bready     ( s_axi_bready[0]   ),
        .axi_arvalid    ( s_axi_arvalid[0]  ),
        .axi_arready    ( s_axi_arready[0]  ),
        .axi_araddr     ( s_axi_araddr_o[0] ),
        .axi_arprot     ( s_axi_arprot_o[0] ),
        .axi_rvalid     ( s_axi_rvalid[0]   ),
        .axi_rready     ( s_axi_rready[0]   ),
        .axi_rdata      ( s_axi_rdata_o[0]  )
    );
    AXI_ETHERNET  #(
        .ip_des         ( {8'd192, 8'd168, 8'd1, 8'd100} ),
        .ip_sour        ( {8'd192, 8'd168, 8'd1, 8'd254} ),
        .ETH_NUM        ( ETH_NUM                        )
    )inst_AXI_ETHERNET_s01 (	
		.clk		    ( clk_100		    ),
		.rst 		    ( rst_100		    ),
        .gmii_clk       ( gmii_rxc          ),
        .gmii_rst       ( gmii_rst          ),
        .axi_awvalid    ( s_axi_awvalid[1]  ),
        .axi_awready    ( s_axi_awready[1]  ),
        .axi_awaddr     ( s_axi_awaddr_o[1] ),
        .axi_awprot     ( s_axi_awprot_o[1] ),
        .axi_wvalid     ( s_axi_wvalid[1]   ),
        .axi_wready     ( s_axi_wready[1]   ),
        .axi_wdata      ( s_axi_wdata_o[1]  ),
        .axi_wstrb      ( s_axi_wstrb_o[1]  ),
        .axi_bvalid     ( s_axi_bvalid[1]   ),
        .axi_bready     ( s_axi_bready[1]   ),
        .axi_arvalid    ( s_axi_arvalid[1]  ),
        .axi_arready    ( s_axi_arready[1]  ),
        .axi_araddr     ( s_axi_araddr_o[1] ),
        .axi_arprot     ( s_axi_arprot_o[1] ),
        .axi_rvalid     ( s_axi_rvalid[1]   ),
        .axi_rready     ( s_axi_rready[1]   ),
        .axi_rdata      ( s_axi_rdata_o[1]  ),
		.gmii_tx_dv     ( gmii_tx_dv        ),
		.gmii_td        ( gmii_td           ),
		.gmii_rx_dv     ( gmii_rx_dv        ),
		.gmii_rx_err    ( gmii_rx_err       ),
		.gmii_rd        ( gmii_rd           )
	);
    AXI_SM3 inst_AXI_SM3_s01 (	
		.clk		    ( clk_100		    ),
		.rst 		    ( rst_100		    ),
        .axi_awvalid    ( s_axi_awvalid[2]  ),
        .axi_awready    ( s_axi_awready[2]  ),
        .axi_awaddr     ( s_axi_awaddr_o[2] ),
        .axi_awprot     ( s_axi_awprot_o[2] ),
        .axi_wvalid     ( s_axi_wvalid[2]   ),
        .axi_wready     ( s_axi_wready[2]   ),
        .axi_wdata      ( s_axi_wdata_o[2]  ),
        .axi_wstrb      ( s_axi_wstrb_o[2]  ),
        .axi_bvalid     ( s_axi_bvalid[2]   ),
        .axi_bready     ( s_axi_bready[2]   ),
        .axi_arvalid    ( s_axi_arvalid[2]  ),
        .axi_arready    ( s_axi_arready[2]  ),
        .axi_araddr     ( s_axi_araddr_o[2] ),
        .axi_arprot     ( s_axi_arprot_o[2] ),
        .axi_rvalid     ( s_axi_rvalid[2]   ),
        .axi_rready     ( s_axi_rready[2]   ),
        .axi_rdata      ( s_axi_rdata_o[2]  ),
        .sm3_irq        ( sm3_irq           )
	);
    clk_rgmii_shift rgmii_shift(
        .clk_out        ( rgmii_clk_out             ),     // output clk_out
        .clk_in         ( rgmii_rx_clk              )
    );    
	rgmii_gmii inst_rgmii_to_gmii(
		.rst            ( !rst_n                    ),
		.rgmii_rxc      ( rgmii_clk_out             ),
		.rgmii_rx_ctl   ( rgmii_rx_ctl              ),
		.rgmii_rd       ( rgmii_rd                  ),
		.gmii_rxc       ( gmii_rxc                  ),
		.gmii_rx_dv     ( gmii_rx_dv                ),
		.gmii_rx_err    ( gmii_rx_err               ),
		.gmii_rd        ( gmii_rd                   )
	); 
	gmii_rgmii inst_gmii_to_rgmii(
		.rst            ( gmii_rst                  ),
		.gmii_txc       ( gmii_txc                  ),
		.gmii_tx_dv     ( gmii_tx_dv                ),
		.gmii_td        ( gmii_td                   ),
		.rgmii_txc      ( rgmii_tx_clk              ),
		.rgmii_tx_ctl   ( rgmii_tx_ctl              ),
		.rgmii_td       ( rgmii_td                  )
	);
endmodule
