`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/05 09:35:07
// Design Name: 
// Module Name: smi
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


module smi(
        input                       clk     ,
        input                       rst     ,
        input                       oper_en ,
        input                       mode    ,
        input           [4:0]       addr    ,
        input           [15:0]      wr_data ,
        output  reg                 md_en   ,
        output  reg     [15:0]      rd_data ,
        output  reg                 rd_vld  ,
        input                       md_in   ,
        output  reg                 md_out  ,
        output  reg                 md_c
    );
    localparam  cycle       =   50      ,
                operate     =   33      ,
                phy_addr    =   5'd1    ,
                wr_start    =   4'b0101 ,
                rd_start    =   4'b0110 ;
    reg     [5:0]       cnt_cycle       ;
    reg     [5:0]       cnt_oper        ;
    reg     [15:0]      start           ;
    reg     [15:0]      rd_data_tmp     ;
    reg     [15:0]      wr_data_tmp     ;
    reg                 oper_flag       ;
    wire                  high_mid; 
    wire                  low_mid;
    always @(posedge clk)begin
        if(rst)
            cnt_cycle <= 6'd0;
        else
        if(end_cycle)
            cnt_cycle <= 6'd0;
        else
        if(add_cycle)
            cnt_cycle <= cnt_cycle + 1'b1;
    end
    assign add_cycle = 1                                                ;
    assign end_cycle = add_cycle & cnt_cycle == cycle - 1               ;
    assign mid_cycle = add_cycle & cnt_cycle == 25 - 1                  ;
    assign high_mid  = add_cycle & cnt_cycle == 12 - 1 & oper_flag      ;
    assign low_mid   = add_cycle & cnt_cycle == 37 - 1 & oper_flag      ;
    
    always @(posedge clk)begin
        if(rst)
            md_c <= 1'b1;
        else
        if(end_cycle)
            md_c <= 1'b1;
        else
        if(mid_cycle)
            md_c <= 1'b0;
    end
    
    always @(posedge clk)begin
        if(rst)
            cnt_oper <= 6'd0;
        else
        if(end_oper)
            cnt_oper <= 6'd0;
        else
        if(add_oper)
            cnt_oper <= cnt_oper + 1'b1;
    end
    assign add_oper = oper_flag & end_cycle                ;
    assign end_oper = add_oper & cnt_oper == operate - 1   ;    
        
    always @(posedge clk)begin
        if(rst)
            oper_flag <= 1'b0;
        else  
        if(oper_en)
            oper_flag <= 1'b1;
        else
        if(end_oper)
            oper_flag <= 1'b0;
    end
    
    always @(posedge clk)begin
        if(oper_en)begin    
            wr_data_tmp <= wr_data;
            if(mode)
                start <= {wr_start, phy_addr, addr, 2'b00};
            else
                start <= {rd_start, phy_addr, addr, 2'b00};
        end
    end
    always @(posedge clk)begin
        if(rst)
            md_out <= 1'b1;
        else      
        if(high_mid & cnt_oper >= 1 & cnt_oper < 17)
            md_out <= start[16 - cnt_oper];
        else
        if(high_mid & start[12] & cnt_oper >= 17)
            md_out <= wr_data_tmp[32-cnt_oper];
        else
        if(end_oper)
            md_out <= 1'b1;
    end
    always @(posedge clk)begin
        if(rst)
            md_en <= 1'b0;
        else      
        if((cnt_oper >= 1 & cnt_oper < 15) || start[12])
            md_en <= oper_flag;
        else
            md_en <= 1'b0;
    end    
    always @(posedge clk)begin
        if(low_mid & cnt_oper >= 17)
            rd_data_tmp <= {rd_data_tmp[14:0], md_in};
        else
        if(end_oper)
            rd_data_tmp <= 16'd0;
    end
    
    always @(posedge clk)begin
        if(end_oper & start[13])
            rd_data <= rd_data_tmp  ;
    end
    always @(posedge clk)begin
        if(end_oper & start[13])
            rd_vld  <= 1'b1         ;
        else 
            rd_vld  <= 1'b0         ; 
    end     
    
endmodule
