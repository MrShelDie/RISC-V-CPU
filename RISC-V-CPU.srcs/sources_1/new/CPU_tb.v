`timescale 1ns / 1ps

module CPU_tb;

  reg         clk;
  reg         rst;
  
  reg  [31:0] IN;
  
  wire [31:0] OUT;
    
  CPU cpu(
    .clk_i ( clk ),
    .rst_i ( rst ),
    
    .IN_i  ( IN  ),
    
    .OUT_o ( OUT )
  );
  
  initial
    begin
      clk <= 0;
      IN  <= 32'd0;
    
      rst <= 1;
      # 30
      rst <= 0;
    
      forever
        #10 clk <= !clk;
          
    end

endmodule
