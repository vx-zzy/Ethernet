`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/08 17:08:31
// Design Name: 
// Module Name: rgmii_gmii
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


module rgmii_gmii(
        input						    rst			        ,
        input						    rgmii_rxc			,
        input						    rgmii_rx_ctl		,
        input			[3:0]			rgmii_rd			,
        output                          gmii_rxc            ,
        output                          gmii_rx_dv          ,
        output                          gmii_rx_err         ,
        output			[7:0]			gmii_rd			    

    );

    assign gmii_rxc		    =	rgmii_rxc			    ;
    assign gmii_rx_err		=	!gmii_rx_err_r			;

    genvar              i                               ;
    generate for(i=0;i<4;i=i+1) begin : iddr
        IDDR #(
          .DDR_CLK_EDGE ( "SAME_EDGE_PIPELINED" ), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                                    //    or "SAME_EDGE_PIPELINED" 
          .INIT_Q1      ( 1'b0                  ), // Initial value of Q1: 1'b0 or 1'b1
          .INIT_Q2      ( 1'b0                  ), // Initial value of Q2: 1'b0 or 1'b1
          .SRTYPE       ( "SYNC"                ) // Set/Reset type: "SYNC" or "ASYNC" 
        ) IDDR_inst (
          .Q1           ( gmii_rd[i]            ), // 1-bit output for positive edge of clock 
          .Q2           ( gmii_rd[i+4]          ), // 1-bit output for negative edge of clock
          .C            ( rgmii_rxc				),   // 1-bit clock input
          .CE           ( 1'b1                  ), // 1-bit clock enable input
          .D            ( rgmii_rd[i]           ),   // 1-bit DDR data input
          .R            ( rst                   ),   // 1-bit reset
          .S            ( 1'b0                  )    // 1-bit set
        );
    end
    endgenerate
    IDDR #(
          .DDR_CLK_EDGE ( "SAME_EDGE_PIPELINED" ), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                                    //    or "SAME_EDGE_PIPELINED" 
          .INIT_Q1      ( 1'b0                  ), // Initial value of Q1: 1'b0 or 1'b1
          .INIT_Q2      ( 1'b0                  ), // Initial value of Q2: 1'b0 or 1'b1
          .SRTYPE       ( "SYNC"                ) // Set/Reset type: "SYNC" or "ASYNC" 
        ) IDDR_inst (
          .Q1           ( gmii_rx_dv            ), // 1-bit output for positive edge of clock 
          .Q2           ( gmii_rx_err_r         ), // 1-bit output for negative edge of clock
          .C            ( rgmii_rxc             ),   // 1-bit clock input
          .CE           ( 1'b1                  ), // 1-bit clock enable input
          .D            ( rgmii_rx_ctl          ),   // 1-bit DDR data input
          .R            ( rst                   ),   // 1-bit reset
          .S            ( 1'b0                  )    // 1-bit set
        );

endmodule
