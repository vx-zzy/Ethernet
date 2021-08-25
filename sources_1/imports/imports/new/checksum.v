`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/24 15:09:17
// Design Name: 
// Module Name: checksum
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


module checksum(
        input                   clk         ,
        input                   rst         ,
        input			[16:0]	init		,
        input					en			,  
        input	        [7:0]   data		,      
        output  reg     [16:0]  cali        
    );
    reg		[15:0]			check		        ;
    reg		[0:0]			cnt_check		    ;
    reg		[16:0]			cali_r		        ;
    always@(posedge clk)begin
        if(rst)
            cnt_check <= 1'b0;
        else
       if(end_check)
            cnt_check <= 1'b0;
       else
       if(add_check)
            cnt_check <= cnt_check + 1'b1;
    end
    assign	add_check	=	en						        ;
    assign	end_check	=	add_check && cnt_check == 2 - 1	;
    always@(*)begin//拆分加法
        if(add_check & !cnt_check)
            check = {data, 8'd0};
        else
        if(end_check)
            check = {8'd0, data};
        else
            check = 16'd0;
    end
    always @ * begin
        if(cali_r[16])
            cali = cali_r[16] + cali_r[15:0] + check;
        else
            cali = cali_r + check;
    end
    always @(posedge clk)begin
        if(rst)
            cali_r <= init;
        else
        if(en)
            cali_r <= cali;
    end 
endmodule
