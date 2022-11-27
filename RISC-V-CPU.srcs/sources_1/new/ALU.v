`include "miriscv_defines.vh"

`timescale 1ns / 1ps

module alu(
  input  [4:0]  opcode_i,
  input  [31:0] a_i,
  input  [31:0] b_i,
    
  output reg [31:0] res_o,
  output reg        flag_o
);

  always @( * )
    case ( opcode_i )
      `ALU_ADD  : res_o = a_i + b_i;
      `ALU_SUB  : res_o = a_i - b_i;
      `ALU_SLL  : res_o = a_i << b_i;
      `ALU_SLTS : res_o = $signed( a_i ) < $signed( b_i );
      `ALU_SLTU : res_o = a_i < b_i;
      `ALU_XOR  : res_o = a_i ^ b_i;
      `ALU_SRL  : res_o = a_i >> b_i;
      `ALU_SRA  : res_o = $signed( a_i ) >>> b_i;
      `ALU_OR   : res_o = a_i | b_i;
      `ALU_AND  : res_o = a_i & b_i;
      default   : res_o = 0;
    endcase
    
  always @( * )
    case ( opcode_i )
      `ALU_EQ   : flag_o = a_i == b_i;
      `ALU_NE   : flag_o = a_i != b_i;
      `ALU_LTS  : flag_o = $signed(a_i) < $signed(b_i);
      `ALU_GES  : flag_o = $signed(a_i) >= $signed(b_i);
      `ALU_LTU  : flag_o = a_i < b_i;
      `ALU_GEU  : flag_o = a_i >= b_i;
      default   : flag_o = 0; 
    endcase
  
endmodule
