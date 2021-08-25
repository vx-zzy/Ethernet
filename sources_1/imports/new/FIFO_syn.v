/*
 * @Author: ZhiyuanZhao
 * @Description: 
 * @Date: 2020-09-15 16:30:29
 * @LastEditTime: 2021-03-31 16:25:10
 */
`timescale 1ns / 1ps


module FIFO_syn#(
        parameter ram_type  = "block"                        ,// "block" or "lut"
        parameter width     = 8                              ,
        parameter depth     = 4096                          //bigger fifo
)(
        input						        clk			,
        input						        srst		,
        input                               wr_en       ,
        input			[width-1:0]			din			,
        input                               rd_en       ,
        output  reg     [width-1:0]         dout        ,
        output  reg                         full        ,
        output  reg                         empty

    );
    reg		[$clog2(depth)-1:0]                cnt_wr		;
    reg		[$clog2(depth)-1:0]                cnt_rd		;

    reg                                        full_flag    ;
    reg                                        empty_flag   ;
    integer                                    i            ;
    reg		[width-1:0]                        fifo_data[depth-1:0]	;
    assign wr_chase		=	cnt_rd == cnt_wr + 1'b1			;
    assign rd_chase		=	cnt_wr == cnt_rd + 1'b1			;
    initial begin
        for(i = 0; i < depth; i = i + 1)
            fifo_data[i] = 0;
    end
    always@(posedge clk)begin
        if(srst)
            cnt_wr <= 'd0;
        else
        if(add_wr)
            cnt_wr <= cnt_wr + 1'b1;
    end
    assign	add_wr	=	wr_en && !full;

    always@(posedge clk)begin
        if(add_wr)
            fifo_data[cnt_wr] <= din;
    end

    always@(posedge clk)begin
        if(srst)
            cnt_rd <= 'd0;
        else
        if(add_rd)
            cnt_rd <= cnt_rd + 1'b1;
    end
    assign	add_rd	=	rd_en && !empty;
    generate if(ram_type == "block") begin : block_ram
        always@(posedge clk)begin
            dout <= fifo_data[cnt_rd + add_rd];
        end    
    end
    else begin :lut_ram
        always@(*)begin
            dout = fifo_data[cnt_rd];
        end
    end
    endgenerate

    always@(posedge clk)begin
        if(srst)
            full <= 1'b0;
        else
        if(wr_chase)
            full <= add_wr && !add_rd;
    end
    always@(posedge clk)begin
        if(srst)
            empty <= 1'b1;
        else
        if(rd_chase)//空满状态的建立没有问题，消除会延后一个clk,对于first word fall through模式来说，将数据放到dout需要一个clk，因此不能在写入之后立即拉低empty
            empty <= add_rd && !add_wr;
    end
endmodule

module FIFO_syn2#(
        parameter width = 8                             ,
        parameter depth = 16
)(
        input						        clk			,
        input						        srst		,
        input                               wr_en       ,
        input			[width-1:0]			din			,
        input                               rd_en       ,
        output  reg     [width-1:0]         dout        ,
        output                              full        ,
        output                              empty

    );
    reg		[$clog2(depth):0]                  cnt_num		;
    reg		[$clog2(depth)-1:0]                cnt_wr		;
    reg		[$clog2(depth)-1:0]                cnt_rd		;
    reg                                        empty_flag   ;
    integer                                    i            ;

(* ram_style = "block" *)    reg		[width-1:0]                        fifo_data[depth-1:0]	;
    initial begin
        for(i = 0; i < depth; i = i + 1)
            fifo_data[i] = 0;
    end
    assign full		=	cnt_num == depth    		             ;
    assign empty	=	cnt_num == 0 || empty_flag               ;

    always@(posedge clk)begin
        if(srst)
            cnt_num <= 'd0;
        else
        if(add_wr)
            cnt_num <= cnt_num + 1'b1;
        else
        if(add_rd)
            cnt_num <= cnt_num - 1'b1;
    end
    assign	add_wr	=   true_wr && !true_rd;
    assign	add_rd	=	true_rd && !true_wr;
    assign  true_wr =   wr_en && !full;
    assign  true_rd =   rd_en && !empty;
    always@(posedge clk)begin
        if(true_wr)
            fifo_data[cnt_wr] <= din;
    end
    always@(posedge clk)begin
        if(srst)
            cnt_wr <= 'd0;
        else
        if(true_wr)
            cnt_wr <= cnt_wr + 1'b1;
    end
    always@(posedge clk)begin
        if(srst)
            cnt_rd <= 'd0;
        else
        if(true_rd)
            cnt_rd <= cnt_rd + 1'b1;
    end
    always@(posedge clk)begin
        if(srst)
            empty_flag <= 1'b1;
        else
            empty_flag <= cnt_num == 0;
    end
    always@(posedge clk)begin
        dout <= fifo_data[cnt_rd + true_rd];
    end
endmodule

module FIFO_syn3#(
        parameter ram_type   = "block"                       ,// "block" or "lut"
        parameter width     = 8                              ,
        parameter depth     = 4096                          //bigger fifo
)(
        input						        clk			,
        input						        srst		,
        input                               wr_en       ,
        input			[width-1:0]			din			,
        input                               rd_en       ,
        output  reg     [width-1:0]         dout        ,
        output                              full        ,
        output                              empty

    );
    reg		[$clog2(depth)-1:0]                cnt_wr		;
    reg		[$clog2(depth)-1:0]                cnt_rd		;

    reg                                        full_flag    ;
    reg                                        empty_flag   ;
    integer                                    i            ;
    reg		[width-1:0]                        fifo_data[depth-1:0]	;
    initial begin
        for(i = 0; i < depth; i = i + 1)
            fifo_data[i] = 0;
    end
    assign full		=	cnt_rd == cnt_wr && full_flag		                ;
    assign empty	=	(cnt_wr == cnt_rd && !full_flag) || empty_flag		;

    always@(posedge clk)begin
        if(srst)
            cnt_wr <= 'd0;
        else
        if(add_wr)
            cnt_wr <= cnt_wr + 1'b1;
    end
    assign	add_wr	=	wr_en && !full;

    always@(posedge clk)begin
        if(add_wr)
            fifo_data[cnt_wr] <= din;
    end

    always@(posedge clk)begin
        if(srst)
            cnt_rd <= 'd0;
        else
        if(add_rd)
            cnt_rd <= cnt_rd + 1'b1;
    end
    assign	add_rd	=	rd_en && !empty;
    generate if(ram_type == "block") begin : block_ram
        always@(posedge clk)begin
            dout <= fifo_data[cnt_rd + add_rd];
        end    
    end
    else begin :lut_ram
        always@(*)begin
            dout = fifo_data[cnt_rd];
        end
    end
    endgenerate

    always@(posedge clk)begin
        if(srst)
            full_flag <= 1'b0;
        else
        if(cnt_rd == cnt_wr + 1'b1)
            full_flag <= 1'b1;
        else 
        if(cnt_wr == cnt_rd + 1'b1)
            full_flag <= 1'b0;
    end
    always@(posedge clk)begin
        if(srst)
            empty_flag <= 1'b1;
        else
        if(cnt_wr == cnt_rd && !full_flag)
            empty_flag <= 1'b1;
        else 
            empty_flag <= 1'b0;
    end
endmodule