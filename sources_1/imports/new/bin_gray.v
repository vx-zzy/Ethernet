`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/17 10:02:34
// Design Name: 
// Module Name: bin_gray
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


module bin_gray#(
        parameter width = 8                             
)(
        input			[width-1:0]			bin			,
        output reg      [width-1:0]         gray        
    );
    // assign gray		=	(bin >> 1) ^ bin			;
    integer                            i                ;
    always@* begin
        gray[width-1] = bin[width-1];
        for(i = 0; i < width-1; i = i + 1)
            gray[i] = bin[i + 1] ^ bin[i]; 
    end
endmodule
