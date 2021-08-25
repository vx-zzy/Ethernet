`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/17 09:48:15
// Design Name: 
// Module Name: FIFO_asyn
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


module FIFO_asyn1#(
        parameter width = 8                             ,
        parameter depth = 16
)(
        input						        wr_clk		,
        input						        rd_clk		,
        input						        wr_rst		,
        input						        rd_rst		,
        input                               wr_en       ,
        input			[width-1:0]			din			,
        input                               rd_en       ,
        output  reg     [width-1:0]         dout        ,
        output                              full        ,
        output                              empty

    );
    reg		[$clog2(depth)-1:0]                cnt_wr		;
    reg		[$clog2(depth)-1:0]                cnt_rd		;
    wire	[$clog2(depth)-1:0]                gray_wr		;
    reg 	[$clog2(depth)-1:0]                gray_wr_r	;
(* ASYNC_REG="true" *)    reg		[$clog2(depth)-1:0]                wr_rd_syn1	;
    reg		[$clog2(depth)-1:0]                wr_rd_syn2	;
    wire	[$clog2(depth)-1:0]                gray_rd		;
    reg	    [$clog2(depth)-1:0]                gray_rd_r	;
(* ASYNC_REG="true" *)    reg		[$clog2(depth)-1:0]                rd_wr_syn1	;
    reg		[$clog2(depth)-1:0]                rd_wr_syn2	;
    wire	[$clog2(depth)-1:0]                rd_addr	    ;
    wire	[$clog2(depth)-1:0]                wr_addr	    ;

    reg                                        full_flag    ;
    reg                                        empty_flag   ;
    integer                                    i            ;

    assign full		=	cnt_wr == rd_addr && full_flag		                ;
    assign empty	=	cnt_rd == wr_addr && empty_flag             		;

(* ram_style = "block" *)    reg		[width-1:0]                        fifo_data[depth-1:0]	;
    initial begin
        for(i = 0; i < depth; i = i + 1)
            fifo_data[i] = 0;
    end

    always@(posedge wr_clk)begin
        if(wr_rst)
            cnt_wr <= 'd0;
        else
        if(add_wr)
            cnt_wr <= cnt_wr + 1'b1;
    end
    assign	add_wr	=	wr_en && !full;

    always@(posedge wr_clk)begin
        if(add_wr)
            fifo_data[cnt_wr] <= din;
    end
    always@(posedge rd_clk)begin
        dout <= fifo_data[cnt_rd + add_rd];
    end
    always@(posedge rd_clk)begin
        if(rd_rst)
            cnt_rd <= 'd0;
        else
        if(add_rd)
            cnt_rd <= cnt_rd + 1'b1;
    end
    assign	add_rd	=	rd_en && !empty;
    always@(posedge wr_clk)begin
        if(wr_rst)begin
            gray_wr_r   <= 'd0          ;
            rd_wr_syn1  <= 'd0          ;
            rd_wr_syn2  <= 'd0          ;
        end
        else begin
            gray_wr_r   <= gray_wr      ;
            rd_wr_syn1  <= gray_rd_r    ;
            rd_wr_syn2  <= rd_wr_syn1   ;
        end
    end
    always@(posedge rd_clk)begin
        if(rd_rst)begin
            gray_rd_r   <= 'd0          ;
            wr_rd_syn1  <= 'd0          ;
            wr_rd_syn2  <= 'd0          ;
        end
        else begin
            gray_rd_r   <= gray_rd      ;
            wr_rd_syn1  <= gray_wr_r    ;
            wr_rd_syn2  <= wr_rd_syn1   ;            
        end
    end

    always@(posedge wr_clk)begin
        if(wr_rst)
            full_flag <= 1'b0;
        else
        if(rd_addr + 1'b1 == cnt_wr)
            full_flag <= 1'b0;
        else
        if(cnt_wr + 1'b1 == rd_addr)
            full_flag <= 1'b1;
    end
    always@(posedge rd_clk)begin
        if(rd_rst)
            empty_flag <= 1'b1;
        else
        if(wr_addr + 1'b1 == cnt_rd)
            empty_flag <= 1'b0;
        else
        if(cnt_rd + 1'b1 == wr_addr)
            empty_flag <= 1'b1;
    end
    bin_gray #(
        .width      ( $clog2(depth) )
    )bin_gray_wr_inst(
        .bin        ( cnt_wr        ),
        .gray       ( gray_wr       )
    );
    bin_gray #(
        .width      ( $clog2(depth) )
    )bin_gray_rd_inst(
        .bin        ( cnt_rd        ),
        .gray       ( gray_rd       )
    );
    gray_bin #(
        .width      ( $clog2(depth) )
    )gray_bin_wr_inst(
        .gray       ( rd_wr_syn2    ),
        .bin        ( rd_addr       )
    );
    gray_bin #(
        .width      ( $clog2(depth) )
    )gray_bin_rd_inst(
        .gray       ( wr_rd_syn2    ),
        .bin        ( wr_addr       )
    );

endmodule

module FIFO_asyn#(
        parameter width = 8                             ,
        parameter depth = 16
)(
        input						        wr_clk		,
        input						        rd_clk		,
        input						        wr_rst		,
        input						        rd_rst		,
        input                               wr_en       ,
        input			[width-1:0]			din			,
        input                               rd_en       ,
        output  reg     [width-1:0]         dout        ,
        output                              full        ,
        output                              empty

    );
    reg		[$clog2(depth):0]                   cnt_wr		;
    reg		[$clog2(depth):0]                   cnt_rd		;
    wire	[$clog2(depth):0]                   gray_wr		;
    reg 	[$clog2(depth):0]                   gray_wr_r	;
(* ASYNC_REG="true" *)    reg		[$clog2(depth):0]                   wr_rd_syn1	;
    reg		[$clog2(depth):0]                   wr_rd_syn2	;
    wire	[$clog2(depth):0]                   gray_rd		;
    reg	    [$clog2(depth):0]                   gray_rd_r	;
(* ASYNC_REG="true" *)    reg		[$clog2(depth):0]                   rd_wr_syn1	;
    reg		[$clog2(depth):0]                   rd_wr_syn2	;

    reg                                         full_flag   ;
    reg                                         empty_flag  ;
    integer                                     i           ;

    assign full		=	(gray_wr[$clog2(depth)-:2] == ~rd_wr_syn2[$clog2(depth)-:2]) && (gray_wr[$clog2(depth)-2:0] == rd_wr_syn2[$clog2(depth)-2:0]);
    assign empty	=	gray_rd == wr_rd_syn2             		;

(* ram_style = "block" *)    reg		[width-1:0]                        fifo_data[depth-1:0]	;
    initial begin
        for(i = 0; i < depth; i = i + 1)
            fifo_data[i] = 0;
    end

    always@(posedge wr_clk)begin
        if(wr_rst)
            cnt_wr <= 'd0;
        else
        if(add_wr)
            cnt_wr <= cnt_wr + 1'b1;
    end
    assign	add_wr	=	wr_en && !full;

    always@(posedge wr_clk)begin
        if(add_wr)
            fifo_data[cnt_wr[$clog2(depth)-1:0]] <= din;
    end
    always@(posedge rd_clk)begin
        dout <= fifo_data[cnt_rd[$clog2(depth)-1:0] + add_rd];
    end
    always@(posedge rd_clk)begin
        if(rd_rst)
            cnt_rd <= 'd0;
        else
        if(add_rd)
            cnt_rd <= cnt_rd + 1'b1;
    end
    assign	add_rd	=	rd_en && !empty;
    always@(posedge wr_clk)begin
        if(wr_rst)begin
            gray_wr_r   <= 'd0          ;
            rd_wr_syn1  <= 'd0          ;
            rd_wr_syn2  <= 'd0          ;
        end
        else begin
            gray_wr_r   <= gray_wr      ;
            rd_wr_syn1  <= gray_rd_r    ;
            rd_wr_syn2  <= rd_wr_syn1   ;
        end
    end
    always@(posedge rd_clk)begin
        if(rd_rst)begin
            gray_rd_r   <= 'd0          ;
            wr_rd_syn1  <= 'd0          ;
            wr_rd_syn2  <= 'd0          ;
        end
        else begin
            gray_rd_r   <= gray_rd      ;
            wr_rd_syn1  <= gray_wr_r    ;
            wr_rd_syn2  <= wr_rd_syn1   ;            
        end
    end

    bin_gray #(
        .width      ( $clog2(depth)+1 )
    )bin_gray_wr_inst(
        .bin        ( cnt_wr        ),
        .gray       ( gray_wr       )
    );
    bin_gray #(
        .width      ( $clog2(depth)+1 )
    )bin_gray_rd_inst(
        .bin        ( cnt_rd        ),
        .gray       ( gray_rd       )
    );

endmodule