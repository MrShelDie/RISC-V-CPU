`timescale 1ns / 1ps

module RAM(
  input         clk_i,
  input  [7:0]  addr_i,
  
  output [31:0] rd_o
);

  reg [7:0]  addr;
  reg [31:0] data [0:63];

  always @( posedge clk_i )
    addr <= addr_i;
  
  assign rd_o = data[addr];

  initial $readmemb( "D:/VivadoProj/RISC-V-CPU/RISC-V-CPU.srcs/sources_1/new/iram.mem", data );

endmodule
