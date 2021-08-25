`timescale 1ns / 1ps


module AXI_SM3#(
		parameter C_S_AXI_DATA_WIDTH	= 32                                ,
		parameter C_S_AXI_ADDR_WIDTH	= 32                                
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
		output 											sm3_irq			
    );
	// AXI4LITE signals     
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
    reg     [C_S_AXI_DATA_WIDTH-1:0]            sm3_data                ;
    reg		                	                result_valid		    ;
    wire	[255:0]			                    din		                ;
    wire    [255:0]                             dout                    ;
	reg 	[2:0]								cnt_dout				;
	reg    										empty_r					;
	assign axi_awready	= awready					            		;
	assign axi_wready	= wready					            		;
	assign axi_bvalid	= bvalid					            		;
	assign axi_arready	= arready					            		;
	assign axi_rdata	= rdata						            		;
	assign axi_rvalid	= rvalid					            		;
    assign rd_en		= end_dout 										;
	assign sm3_irq		= !empty & empty_r								;
	always@(posedge clk)begin
		empty_r <= empty;
	end
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
            sm3_data <= 32'd0;
	    end 
	    else begin
	      if (slv_reg_wren)
	        begin
	          case ( awaddr) 
	            32'h0:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	                if ( axi_wstrb[byte_index] == 0 ) begin
	                    sm3_data[(byte_index*8) +: 8] <= axi_wdata[(byte_index*8) +: 8];
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
	      32'h4  : reg_data_out = !empty;
	      32'h8  : reg_data_out = dout[255-cnt_dout*32-:32];
	      default: reg_data_out = 0;
	    endcase
	end

	always @( posedge clk )begin
	    if ( rst )
	        rdata  <= 0;
	    else    
	    if (slv_reg_rden)
	        rdata <= reg_data_out;     // register read data  
	end 
	always@(posedge clk)begin
		if(rst)
			cnt_dout <= 'd0;
		else
		if(end_dout)
			cnt_dout <= 'd0;
		else
		if(add_dout)
			cnt_dout <= cnt_dout + 1'b1;
	end
	assign	add_dout	=	slv_reg_rden && !empty && araddr == 8	;
	assign	end_dout	=	add_dout && cnt_dout == 8 - 1			;
    sm3 sm3_inst(
        .clk            ( clk           ),
        .rst            ( rst           ),
        .sm3_data       ( axi_wdata[7:0]),
        .data_vld       ( slv_reg_wren  ),
        .vld_end        ( axi_wdata[8]  ),
        .sm3_result     ( din           ),
        .result_vld     ( wr_en         )
    );
    FIFO_syn #(
        .width      ( 256       ),
        .depth      ( 16      	)
   )fifo_inst(
        .clk            ( clk           ),
        .srst           ( rst           ),
        .din            ( din           ),
        .wr_en          ( wr_en         ),
        .dout           ( dout          ),
        .rd_en          ( rd_en         ),
        .empty          ( empty         ),
        .full           ( full          )
    );
endmodule
