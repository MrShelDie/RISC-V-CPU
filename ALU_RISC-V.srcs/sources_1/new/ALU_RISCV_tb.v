`include "miriscv_defines.vh"

`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2022 12:26:01
// Design Name: 
// Module Name: ALU_RISCV_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU_RISCV_tb;

    reg  [4:0]   opcode;
    reg  [31:0]  a;
    reg  [31:0]  b;
    wire [31:0]  res;
    wire         flag;

    localparam period = 5;

    task verify(
        input [4:0] _opcode,
        input [31:0] _a,
        input [31:0] _b,
        input [31:0] exp_res,
        input exp_flag
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

    ALU_RISCV alu(
        .opcode(opcode),
        .a(a),
        .b(b),
        .res(res),
        .flag(flag)
    );

    initial begin
        opcode = 0;
        a = 0;
        b = 0;
        #period;
        
        verify(`ALU_EQ, 32'd3, 32'd3, 32'd0, 1'd1);

    end

endmodule
