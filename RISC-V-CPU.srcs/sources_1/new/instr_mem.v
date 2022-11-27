`timescale 1ns / 1ps

module instr_mem(
  input  [31:0] addr_i,
  
  output [31:0] rd_o
);

  reg [31:0] data [0:255];
  
  wire [9:2] word_addr = addr_i[9:2];
  
  assign rd_o = data[word_addr];

  initial $readmemh( "D:/VivadoProj/RISC-V-cpu/RISC-V-cpu.srcs/sources_1/new/iram.mem", data );

endmodule
