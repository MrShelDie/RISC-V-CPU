`timescale 1ns / 1ps

module RAM_tb;

  reg  [7:0]  addr;
  wire [31:0] rd;

  RAM iram(
    .addr_i(addr),
    
    .rd_o(rd)
  );
  
  integer i;
  
  initial
    for (i = 0; i < 32; i = i + 1)
      begin
        #10 addr = i;
        #10 $display ("%b", rd);
      end
endmodule
