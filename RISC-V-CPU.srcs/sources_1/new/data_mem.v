`timescale 1ns / 1ps

module data_mem(
  input         clk_i,

  input         we_i,
  input  [31:0] addr_i,
  input  [31:0] wd_i,
  
  output [31:0] rd_o
);

  reg [31:0]   regs [0:255];

  wire         valid_addr = addr_i[31:10] == 22'b1000_0010_0000_0000_0000_00; 
  wire [9:2]   word_addr  = addr_i[9:2];

  always @( posedge clk_i ) begin
    if ( we_i && valid_addr )
      regs[word_addr] = wd_i;
  end

  assign rd_o = valid_addr ? regs[word_addr] : 32'd0; 

endmodule
