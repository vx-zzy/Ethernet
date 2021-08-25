`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/15 10:07:25
// Design Name: 
// Module Name: AXI_INSTR_RAM
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


module AXI_INSTR_RAM#(
  		parameter RAM_WIDTH = 32,                       // Specify RAM data width
  		parameter RAM_DEPTH = 1024,                     // Specify RAM depth (number of entries) 
  		parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
) (
		input			clk				,
		input			rst				,
		input			rx				,
		output			tx				,
		output			rst_core		,
		// AXI-4 SLAVE Interface
		input         	axi_awvalid		,
		output        	axi_awready		,
		input  [32-1:0] axi_awaddr		,
		input  [3-1:0]  axi_awprot		,
	
		input         	axi_wvalid		,
		output        	axi_wready		,
		input  [32-1:0] axi_wdata		,
		input  [4-1:0]  axi_wstrb		,
	
		output        	axi_bvalid		,
		input         	axi_bready		,
	
		input         	axi_arvalid		,
		output        	axi_arready		,
		input  [32-1:0] axi_araddr		,
		input  [3-1:0]  axi_arprot		,
	
		output        	axi_rvalid		,
		input         	axi_rready		,
		output [32-1:0] axi_rdata
	);
	wire	[31:0]						Q				;
	wire	[31:0]						D				;
	reg		[0:0]						CEN				;
	reg		[0:0]						WEN				;
	reg		[13:0]						A				;
	// The address capturing is a single operation, we can handle this always 1
	assign axi_awready = 1'b1;
	assign axi_arready = 1'b1;
	assign axi_wready = 1'b1;
	//reg [9:0] A;
	reg [31:0] DP;
	//wire [31:0] Q;
	assign axi_rdata = Q;
	// For memory, we provide the signals in negedge, because the setup and hold sh*t
	always @(posedge clk) begin
		if (rst) begin
			A <= {13{1'b0}};
			DP <= {32{1'b0}};
		end else begin 
			if(axi_awvalid == 1'b1) begin
				A <= axi_awaddr[13:0];
			end else if(axi_arvalid == 1'b1) begin
				A <= axi_araddr[13:0];
			end
			
			if(axi_wvalid == 1'b1) begin
				DP <= axi_wdata;
			end
 		end
	end
	
	// Flags for reading
	reg reading1, reading2;
	assign axi_rvalid = reading2;
	always @(posedge clk) begin
		if (rst) begin
			reading1 <= 1'b0;
			reading2 <= 1'b0;
		end else begin 
			if(axi_rready == 1'b1 && reading1 == 1'b1 && reading2 == 1'b1) begin
				reading1 <= 1'b0;
			end else if(axi_arvalid == 1'b1) begin
				reading1 <= 1'b1;
			end
			
			if(axi_rready == 1'b1 && reading1 == 1'b1 && reading2 == 1'b1) begin
				reading2 <= 1'b0;
			end else if(reading1 == 1'b1) begin
				reading2 <= 1'b1;
			end
		end
	end
	
	// Flags for writting
	reg writting1, writting2, writting3;
	assign axi_bvalid = writting3;
	always @(posedge clk) begin
		if (rst) begin
			writting1 <= 1'b0;
			writting2 <= 1'b0;
			writting3 <= 1'b0;
		end else begin 
			
			if(axi_bready == 1'b1 && writting1 == 1'b1 && writting2 == 1'b1 && writting3 == 1'b1) begin
				writting3 <= 1'b0;
			end else if(writting2 == 1'b1) begin
				writting3 <= 1'b1;
			end else begin
				writting3 <= writting3;
			end
			
			if(axi_bready == 1'b1 && writting1 == 1'b1 && writting2 == 1'b1 && writting3 == 1'b1) begin
				writting1 <= 1'b0;
			end else if(axi_awvalid == 1'b1) begin
				writting1 <= 1'b1;
			end else begin
				writting1 <= writting1;
			end
			
			if(axi_bready == 1'b1 && writting1 == 1'b1 && writting2 == 1'b1 && writting3 == 1'b1) begin
				writting2 <= 1'b0;
			end else if(axi_wvalid == 1'b1) begin
				writting2 <= 1'b1;
			end else begin
				writting2 <= writting2;
			end
		end
	end
	
	// Control of memory based on Flags
	//reg CEN, WEN;
	// For memory, we provide the signals in negedge, because the setup and hold sh*t
	always @(posedge clk) begin
		if (rst) begin
			CEN <= 1'b1;
			WEN <= 1'b1;
		end else begin 
			CEN <= ~(reading1 | writting1);
			WEN <= ~writting2;
		end
	end
	//wire [31:0] D;
	assign D[7:0]   = axi_wstrb[0]?DP[7:0]  :Q[7:0];
	assign D[15:8]  = axi_wstrb[1]?DP[15:8] :Q[15:8];
	assign D[23:16] = axi_wstrb[2]?DP[23:16]:Q[23:16];
	assign D[31:24] = axi_wstrb[3]?DP[31:24]:Q[31:24];
	wire	[31:0]			instr		;
	wire	[0:0]			vld			;
	reg	   [13:0]			cnt_instr	;
	always@(posedge clk)begin
		if(rst)
			cnt_instr <= 32'd0;
		else
	   if(end_instr || !rst_core)
			cnt_instr <= 32'd0;
	   else
	   if(add_instr)
			cnt_instr <= cnt_instr + 1'b1;
	end
	assign	add_instr	=	vld									;
	assign	end_instr	=	add_instr && cnt_instr >= 16384 - 1	;
	uart_instr#(
		.bps		( 217		)
	)uart_inst(
		.clk 					( clk		),
		.rst 					( rst		),
		.rx 					( rx		),
		.tx 					( tx		),
		.instr					( instr		),
		.vld 					( vld		),
		.rst_core				( rst_core	)
    );
	RAM_2PORT #(
        .RAM_WIDTH      		( RAM_WIDTH ),                       // Specify RAM data width
        .RAM_DEPTH      		( RAM_DEPTH ),                     // Specify RAM depth (number of entries)
        .INIT_FILE      		( INIT_FILE )  // Specify name/location of RAM initialization file if using one (leave blank if not)
    )ram_inst(
    	.addra					( A			),     // Address bus, width determined from RAM_DEPTH
    	.dina					( D			),       // RAM input data, width determined from RAM_WIDTH
    	.clka					( clk		),       // Clock
    	.wea					( !WEN		),         // Write enable
    	.ena					( 1'b1		),         // RAM Enable, for additional power savings, disable port when not in use
    	.douta					( Q			),      // RAM output data, width determined from RAM_WIDTH
  		.clkb					( clk		),    // input wire clkb
		.enb 					( 1'b1		),
  		.web					( vld		),      // input wire [0 : 0] web
  		.addrb					( cnt_instr	),  // input wire [13 : 0] addrb
  		.dinb					( instr		),    // input wire [31 : 0] dinb
  		.doutb					( doutb		)  // output wire [31 : 0] doutb
  );
/*	instr_ram ram_inst(
    	.addra					( A			),     // Address bus, width determined from RAM_DEPTH
    	.dina					( D			),       // RAM input data, width determined from RAM_WIDTH
    	.clka					( clk		),       // Clock
    	.wea					( !WEN		),         // Write enable
    	.ena					( 1'b1		),         // RAM Enable, for additional power savings, disable port when not in use
    	.douta					( Q			),      // RAM output data, width determined from RAM_WIDTH
  		.clkb					( clk		),    // input wire clkb
  		.web					( vld		),      // input wire [0 : 0] web
  		.addrb					( cnt_instr	),  // input wire [13 : 0] addrb
  		.dinb					( instr		),    // input wire [31 : 0] dinb
  		.doutb					( doutb		)  // output wire [31 : 0] doutb
  );*/
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction
endmodule

