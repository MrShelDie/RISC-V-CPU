`timescale 1ns / 1ps

module instr_mem_tb;

  reg  [7:0]  addr;
  wire [31:0] rd;

  instr_mem instr_mem(
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
