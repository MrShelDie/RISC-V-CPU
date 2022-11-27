`timescale 1ns / 1ps

module cpu_tb;

  reg         clk;
  reg         rst;
    
  cpu cpu(
    .clk_i ( clk ),
    .rst_i ( rst )
  );
  
  initial begin
      rst = 1;
      # 30
      rst = 0;   
  end

  initial begin
    clk = 1'b0;
    
    forever
      #10 clk = ~clk;
  end

endmodule
