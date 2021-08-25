`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/17 10:12:32
// Design Name: 
// Module Name: gray_bin
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


module gray_bin#(
        parameter width = 8                             
)(
        input			[width-1:0]			gray		,
        output  reg     [width-1:0]         bin        
    );
    integer                            i                ;
    always@* begin
        bin[width-1] = gray[width-1];
        for(i = width - 2; i >= 0; i = i - 1)
            bin[i] = bin[i + 1] ^ gray[i]; 
    end
endmodule
