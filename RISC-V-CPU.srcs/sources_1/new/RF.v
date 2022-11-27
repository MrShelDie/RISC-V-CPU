`timescale 1ns / 1ps

module reg_file(
  input         clk_i,
  
  input  [4:0]  addr1_i,
  input  [4:0]  addr2_i,
  input  [4:0]  addr3_i,
  
  input  [31:0] wd3_i,
  input         we3_i,
  
  output [31:0] rd1_o,
  output [31:0] rd2_o
);

  reg [31:0] regs [1:31];
  
  assign rd1_o = ( addr1_i ) ? ( regs[addr1_i] ) : ( 32'd0 );
  assign rd2_o = ( addr2_i ) ? ( regs[addr2_i] ) : ( 32'd0 );

  always @( posedge clk_i ) begin
    if ( we3_i )
      regs[addr3_i] <= wd3_i;
  end

endmodule
