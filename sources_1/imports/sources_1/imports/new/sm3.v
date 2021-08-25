`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/04 18:09:44
// Design Name: 
// Module Name: sm3
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
module sm3(
        input						clk			,
        input						rst			,
        input       [7:0]           sm3_data    ,
        input                       data_vld    ,
        input                       vld_end     ,
        output  reg [255:0]         sm3_result  ,
        output  reg                 result_vld      
    );
    localparam IV       = 256'h7380166f4914b2b9172442d7da8a0600a96f30bc163138aae38dee4db0fb0e4e;
    localparam T0_15    = 32'h79cc4519      ;
    localparam T16_63   = 32'h7a879d8a      ;
    localparam compute  = 52                ;
    reg		[511:0]			data_comb		;
    reg                     data_end        ;
    wire	[512:0]			din		        ;
    wire	[512:0]			dout		    ;
    reg		[62:0]		    comb_add		;
    reg		[60:0]			cnt_len		    ;
    reg		    			wr_en		    ;
    reg		[31:0]			w[16:0]		    ;
    reg     [31:0]          w_              ;
    reg     [31:0]          w_13            ;
    reg     [31:0]          w_p             ;
    reg     [31:0]          w_3             ;
    reg     [31:0]          p1              ;
    reg		[31:0]			p0		        ;
    reg		[5:0]			cnt_j		    ;
    reg                     comp_flag       ;
    reg		[31:0]			ss1		        ;
    reg		[31:0]			ss1_comb		;
    reg		[31:0]			ss2		        ;
    reg		[31:0]			tt1		        ;
    reg		[31:0]			tt2		        ;
    reg		[31:0]			a		        ;
    reg		[31:0]			b		        ;
    reg		[31:0]			c		        ;
    reg		[31:0]			d		        ;
    reg		[31:0]			e		        ;
    reg		[31:0]			f		        ;
    reg		[31:0]			g		        ;
    reg		[31:0]			h		        ;
    reg	    [31:0]			tj		        ;
    reg		[31:0]			ff		        ;
    reg		[31:0]			gg		        ;  
    reg                     v_valid         ;
    reg                     end_flag        ;
    wire	[255:0]			result		    ;
    wire	[4:0]			j		        ;
    assign din		    =	{data_end, data_comb}			            ;
    assign real_end		=	data_vld & vld_end			                ;   
    assign one_add		=	real_end & &cnt_len[5:0]			        ;
    assign zero_add		=	real_end & cnt_len[5:0] >= 55		        ;
    assign none_add		=	real_end & cnt_len[5:0] < 55	            ;
    assign rd_en		=	!empty & !comp_flag & !end_flag			    ;
    assign result		=	sm3_result ^ {a, b, c, d, e, f, g, h}		;
    assign j		    =	cnt_j >= 52 ? cnt_j - 52 : 0			    ;
    always@(posedge clk)begin
        if(rst)
            comp_flag <= 1'b0;
        else
        if(end_j)
            comp_flag <= 1'b0;
        else
        if(rd_en)
            comp_flag <= 1'b1;
    end

    always@(posedge clk)begin
        if(rst)
            comb_add <= 63'd0;
        else
            comb_add <= {cnt_len + 1'b1, zero_add, one_add};
    end
    always@(posedge clk)begin
        if(rst)
            cnt_len <= 61'd0;
        else
       if(end_len)
            cnt_len <= 61'd0;
       else
       if(add_len)
            cnt_len <= cnt_len + 1'b1;
    end
    assign	add_len	=	data_vld						;
    assign	end_len	=	add_len && vld_end          	;

    always@(posedge clk)begin
        if(rst)
            wr_en <= 1'b0;
        else
            wr_en <= (add_len && &cnt_len[5:0]) || real_end || (|comb_add[1:0]);
    end
    always@(posedge clk)begin
        if(rst)
            data_end <= 1'b0;
        else
            data_end <= none_add || |comb_add[1:0];
    end

    always@(posedge clk)begin//数据拼接及填充
        if(rst)
            data_comb <= 512'd0;
        else
        if(comb_add[1:0])begin
            data_comb <= 512'd0;
            if(comb_add[0])
                data_comb <= {1'b1, 447'd0, comb_add[62:2], 3'b0};
            else
                data_comb <= {448'd0, comb_add[62:2], 3'b0};
        end
        else
        if(data_vld)begin
            if(!cnt_len[5:0])
                data_comb <= 512'd0;
            data_comb[511-cnt_len[5:0]*8-:8] <= sm3_data;
            if(vld_end)begin
                if(!zero_add)begin
                    data_comb[511-cnt_len[5:0]*8-8-:8] <= 8'h80;
                    data_comb[63:3] <= cnt_len + 1;
                end
                else
                if(!one_add)
                    data_comb[511-cnt_len[5:0]*8-8-:8] <= 8'h80;
            end
        end
    end
    genvar i;
    generate for(i=0;i<16;i=i+1) begin :w_value       
            always@(posedge clk)begin
                if(rst)
                    w[i] <= 32'd0;
                else
                if(rd_en)
                    w[i] <= dout[511-i*32-:32];
                else
                if(comp_flag && cnt_j < compute)
                    w[i] <= w[i+1];
            end
        end
    endgenerate

    always@(*)begin
        w_ = w[j] ^ w[j+4];
        w_3 = {w[13][16:0], w[13][31-:15]};
        w_13 = {w[3][24:0], w[3][31-:7]};
        w_p = w[0] ^ w[7] ^ w_3;
        p1 = w_p ^ {w_p[16:0], w_p[31-:15]} ^ {w_p[8:0], w_p[31-:23]};
        w[16] = p1 ^ w_13 ^ w[10];
    end

    always@(posedge clk)begin
        if(rst)
            cnt_j <= 6'd0;
        else
       if(end_j)
            cnt_j <= 6'd0;
       else
       if(add_j)
            cnt_j <= cnt_j + 1'b1;
    end
    assign	add_j	=	comp_flag						;
    assign	end_j	=	add_j && cnt_j >= 64-1	;
    always@(*)begin
        if(cnt_j <= 15)begin
        //    tj = {T0_15[31-cnt_j:0], T0_15[31-:cnt_j]}  ;
            tj = (T0_15 << cnt_j[4:0]) | (T0_15 >> (32-cnt_j[4:0])) ;
            ff = a ^ b ^ c                              ;
            gg = e ^ f ^ g                              ;
        end
        else begin
        //    tj = {T16_63[31-cnt_j:0], T16_63[31-:cnt_j]};
            tj = (T16_63 << cnt_j[4:0]) | (T16_63 >> (32-cnt_j[4:0]));
            ff = (a & b) | (a & c) | (b & c)            ;
            gg = (e & f) | (~e & g)                     ;
        end
    end

    always@(*)begin
        ss1_comb    = {a[19:0], a[31-:12]} + e + tj                             ;
        ss1         = {ss1_comb[24:0], ss1_comb[31-:7]}                         ; 
        ss2         = ss1 ^ {a[19:0], a[31-:12]}                                ;
        tt1         = ff + d + ss2 + w_                                         ;
        tt2         = gg + h + ss1 + w[j]                                       ;
        p0          = tt2 ^ {tt2[22:0], tt2[31-:9]} ^ {tt2[14:0], tt2[31-:17]}  ;
    end
    always@(posedge clk)begin
        if(rst)begin
            a <= IV[255:224]             ;
            b <= IV[223:192]             ;
            c <= IV[191:160]             ;
            d <= IV[159:128]             ;
            e <= IV[127:96]              ;
            f <= IV[95:64]               ;
            g <= IV[63:32]               ;
            h <= IV[31:0]                ;
        end
        else
        if(comp_flag) begin
            d <= c                       ;
            c <= {b[22:0], b[31-:9]}     ;
            b <= a                       ;
            a <= tt1                     ;
            h <= g                       ;
            g <= {f[12:0], f[31-:19]}    ;
            f <= e                       ;
            e <= p0                      ;
        end
        else
        if(result_vld)begin
            a <= IV[255:224]             ;
            b <= IV[223:192]             ;
            c <= IV[191:160]             ;
            d <= IV[159:128]             ;
            e <= IV[127:96]              ;
            f <= IV[95:64]               ;
            g <= IV[63:32]               ;
            h <= IV[31:0]                ;
        end
        else
        if(v_valid)begin
            a <= result[255:224]         ;
            b <= result[223:192]         ;
            c <= result[191:160]         ;
            d <= result[159:128]         ;
            e <= result[127:96]          ;
            f <= result[95:64]           ;
            g <= result[63:32]           ;
            h <= result[31:0]            ;
        end
    end
    always@(posedge clk)begin
        v_valid <= end_j;
    end
    always@(posedge clk)begin
        if(rst)
            end_flag <= 1'b0;
        else
        if(rd_en)
            end_flag <= dout[512]; 
        else
        if(result_vld)
            end_flag <= 1'b0;
    end
    always@(posedge clk)begin
        if(rst)
            sm3_result <= IV;
        else
        if(v_valid)
            sm3_result <= result;
        else
        if(result_vld)
            sm3_result <= IV;
    end
    always@(posedge clk)begin
        if(rst)
            result_vld <= 1'b0;
        else
            result_vld <= end_flag & v_valid;
    end
    FIFO_syn #(
        .width      ( 513       ),
        .depth      ( 64      	)
   )comb_inst (
        .clk        ( clk       ),      // input wire clk
        .srst       ( rst       ),    // input wire srst
        .din        ( din       ),      // input wire [512 : 0] din
        .wr_en      ( wr_en     ),  // input wire wr_en
        .rd_en      ( rd_en     ),  // input wire rd_en
        .dout       ( dout      ),    // output wire [512 : 0] dout
        .full       ( full      ),    // output wire full
        .empty      ( empty     )  // output wire empty
    );
endmodule
