`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/08 17:57:27
// Design Name: 
// Module Name: gmii_rgmii
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


module gmii_rgmii(
        input						    rst			        ,
        input						    gmii_txc			,
        input						    gmii_tx_dv   		,
        input			[7:0]			gmii_td			    ,
        output                          rgmii_tx_ctl        ,
        output                          rgmii_txc           ,
        output			[3:0]			rgmii_td			    
    );
    assign rgmii_txc		=	gmii_txc			;
    genvar          i                               ;
    generate for(i=0;i<4;i=i+1) begin : oddr
        ODDR #(
          .DDR_CLK_EDGE ( "SAME_EDGE"       ), // "OPPOSITE_EDGE" or "SAME_EDGE" 
          .INIT         ( 1'b0              ),    // Initial value of Q: 1'b0 or 1'b1
          .SRTYPE       ( "SYNC"            ) // Set/Reset type: "SYNC" or "ASYNC" 
        ) ODDR_inst (
          .Q            ( rgmii_td[i]       ),   // 1-bit DDR output
          .C            ( gmii_txc          ),   // 1-bit clock input
          .CE           ( 1'b1              ), // 1-bit clock enable input
          .D1           ( gmii_td[i]        ), // 1-bit data input (positive edge)
          .D2           ( gmii_td[i+4]      ), // 1-bit data input (negative edge)
          .R            ( rst               ),   // 1-bit reset
          .S            ( 1'b0              )    // 1-bit set
        );
    end
    endgenerate
    ODDR #(
      .DDR_CLK_EDGE ( "SAME_EDGE"       ), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT         ( 1'b0              ),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE       ( "SYNC"            ) // Set/Reset type: "SYNC" or "ASYNC" 
    ) ODDR_inst (
      .Q            ( rgmii_tx_ctl      ),   // 1-bit DDR output
      .C            ( gmii_txc          ),   // 1-bit clock input
      .CE           ( 1'b1              ), // 1-bit clock enable input
      .D1           ( gmii_tx_dv        ), // 1-bit data input (positive edge)
      .D2           ( gmii_tx_dv        ), // 1-bit data input (negative edge)
      .R            ( rst               ),   // 1-bit reset
      .S            ( 1'b0              )    // 1-bit set
    );
endmodule
