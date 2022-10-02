`include "miriscv_defines.vh"

`timescale 1ns / 1ps

module ALU(
  input  [4:0]  opcode_i,
  input  [31:0] a_i,
  input  [31:0] b_i,
    
  output [31:0] res_o,
  output        flag_o
);

  reg [31:0]  res_reg;
  reg         flag_reg;

  always @( * )
    case ( opcode_i )
      `ALU_ADD  : res_reg = a_i + b_i;
      `ALU_SUB  : res_reg = a_i - b_i;
      `ALU_SLL  : res_reg = a_i << b_i;
      `ALU_SLTS : res_reg = $signed( a_i ) < $signed( b_i );
      `ALU_SLTU : res_reg = a_i < b_i;
      `ALU_XOR  : res_reg = a_i ^ b_i;
      `ALU_SRL  : res_reg = a_i >> b_i;
      `ALU_SRA  : res_reg = $signed( a_i ) >>> b_i;
      `ALU_OR   : res_reg = a_i | b_i;
      `ALU_AND  : res_reg = a_i & b_i;
      default   : res_reg = 0;
    endcase
    
  always @( * )
    case ( opcode_i )
      `ALU_EQ   : flag_reg = a_i == b_i;
      `ALU_NE   : flag_reg = a_i != b_i;
      `ALU_LTS  : flag_reg = $signed(a_i) < $signed(b_i);
      `ALU_GES  : flag_reg = $signed(a_i) >= $signed(b_i);
      `ALU_LTU  : flag_reg = a_i < b_i;
      `ALU_GEU  : flag_reg = a_i >= b_i;
      default   : flag_reg = 0; 
    endcase
  
  assign res_o = res_reg;
  assign flag_o = flag_reg;
  
endmodule
