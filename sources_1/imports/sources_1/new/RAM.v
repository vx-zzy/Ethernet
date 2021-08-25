`timescale 1ns / 1ps
module RAM_1PORT#(
    parameter RAM_WIDTH = 32      ,                      
    parameter RAM_DEPTH = 1024    ,       
    parameter pipeline  = 1       ,             
    parameter INIT_FILE = ""                     
)(
    input [$clog2(RAM_DEPTH-1)-1:0]   addra   , 
    input [RAM_WIDTH-1:0]             dina    ,           
    input                             clka    ,                         
    input                             wea     ,                            
    input                             ena     ,                           
    output [RAM_WIDTH-1:0]            douta      
);

  reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
  genvar  i   ;

  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
    end 
    else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          BRAM[ram_index] = {RAM_WIDTH{1'b0}};
    end
  endgenerate

  always @(posedge clka)
    if (ena)
      if (wea)
        BRAM[addra] <= dina; 

  generate 
    if(pipeline == 0)begin:delay_0
      assign douta = BRAM[addra];
    end
    else begin:delay_n
      reg [RAM_WIDTH-1:0] ram_dataa [pipeline-1:0];
      assign douta = ram_dataa[pipeline-1];
      for(i=0; i<pipeline; i=i+1)
        if(i == 0)begin:get_value
          always @(posedge clka)begin
            if (ena)
              if (wea) 
                ram_dataa[0] <= dina;
              else
                ram_dataa[0] <= BRAM[addra];  
          end  
        end
        else begin:delay
          always @(posedge clka)begin
            ram_dataa[i] <= ram_dataa[i-1];
          end
        end
    end
  endgenerate
  
endmodule


module RAM_2PORT#(
    parameter RAM_WIDTH = 32      ,                      
    parameter RAM_DEPTH = 1024    ,      
    parameter pipeline  = 1       ,                     
    parameter INIT_FILE = ""                     
)(
    input [$clog2(RAM_DEPTH-1)-1:0]   addra   , 
    input [RAM_WIDTH-1:0]             dina    ,           
    input                             clka    ,                         
    input                             wea     ,                            
    input                             ena     ,                           
    output [RAM_WIDTH-1:0]            douta   ,      
    input [$clog2(RAM_DEPTH-1)-1:0]   addrb   , 
    input [RAM_WIDTH-1:0]             dinb    ,          
    input                             clkb    ,                         
    input                             web     ,                         
    input                             enb     ,                         
    output [RAM_WIDTH-1:0]            doutb          
);

  reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] ram_dataa = {RAM_WIDTH{1'b0}};
  reg [RAM_WIDTH-1:0] ram_datab = {RAM_WIDTH{1'b0}};
  genvar  i   ;
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
    end 
    else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          BRAM[ram_index] = {RAM_WIDTH{1'b0}};
    end
  endgenerate

  always @(posedge clka)
    if (ena)
      if (wea)
        BRAM[addra] <= dina;    
 
  always @(posedge clkb)
    if (enb)
      if (web)
        BRAM[addrb] <= dinb; 

  generate 
    if(pipeline == 0)begin:delay_0
      assign douta = BRAM[addra];
      assign doutb = BRAM[addrb];
    end
    else begin:delay_n
      reg [RAM_WIDTH-1:0] ram_dataa [pipeline-1:0];
      reg [RAM_WIDTH-1:0] ram_datab [pipeline-1:0];
      assign douta = ram_dataa[pipeline-1];
      assign doutb = ram_datab[pipeline-1];
      for(i=0; i<pipeline; i=i+1)
        if(i == 0)begin:get_value
          always @(posedge clka)begin
            if (ena)
              if (wea) 
                ram_dataa[0] <= dina;
              else
                ram_dataa[0] <= BRAM[addra];  
          end  
          always @(posedge clkb)begin
            if (enb)
              if (web) 
                ram_datab[0] <= dinb;
              else
                ram_datab[0] <= BRAM[addrb];  
          end  
        end
        else begin:delay
          always @(posedge clka)begin
            ram_dataa[i] <= ram_dataa[i-1];
          end
          always @(posedge clkb)begin
            ram_datab[i] <= ram_datab[i-1];
          end
        end
    end
  endgenerate
endmodule
