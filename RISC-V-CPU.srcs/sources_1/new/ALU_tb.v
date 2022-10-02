`include "miriscv_defines.vh"

`timescale 1ns / 1ps

module ALU_RISCV_tb;

  reg  [4:0]  opcode;
  reg  [31:0] a;
  reg  [31:0] b;
    
  wire [31:0] res;
  wire        flag;

  localparam period = 5;

  task verify(
    input [4:0]  _opcode,
    input [31:0] _a,
    input [31:0] _b,
    
    input [31:0] exp_res,
    input        exp_flag
  );
    begin
      opcode <= _opcode;
      a <= _a;
      b <= _b;

      #period;

      if (res != exp_res || flag != exp_flag) begin
        $display("TEST FAILED\nopcode: %b\na: %b\nb: %b\nres: %b\texpected: %bflag: %b\texpected: %b",
                  opcode, a, b, res, exp_res, flag, exp_flag);
        $finish;
      end
    end
  endtask

  ALU alu(
    .opcode_i ( opcode ),
    .a_i      ( a      ),
    .b_i      ( b      ),
        
    .res_o    ( res    ),
    .flag_o   ( flag   )
  );

  initial begin
    opcode = 0;
    a = 0;
    b = 0;
    #period;
        
    verify(`ALU_EQ, 32'd3, 32'd3, 32'd0, 1'd1);
  end

endmodule
