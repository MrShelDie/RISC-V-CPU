`include "miriscv_defines.vh"

`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2022 11:32:07
// Design Name: 
// Module Name: ALU_RISCV
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


module ALU_RISCV(
    input [4:0]     opcode,
    input [31:0]    a,
    input [31:0]    b,
    output [31:0]   res,
    output          flag
);

    reg [31:0]  res_reg;
    reg         flag_reg;

    always @(*) begin
        case (opcode)
            `ALU_ADD    : res_reg = a + b;
            `ALU_SUB    : res_reg = a - b;
            `ALU_SLL    : res_reg = a << b;
            `ALU_SLTS   : res_reg = $signed(a) < $signed(b);
            `ALU_SLTU   : res_reg = a < b;
            `ALU_XOR    : res_reg = a ^ b;
            `ALU_SRL    : res_reg = a >> b;
            `ALU_SRA    : res_reg = $signed(a) >>> b;
            `ALU_OR     : res_reg = a | b;
            `ALU_AND    : res_reg = a & b;
            default     : res_reg = 0;
        endcase
    end

    always @(*) begin
        case (opcode)
            `ALU_EQ     : flag_reg = a == b;
            `ALU_NE     : flag_reg = a != b;
            `ALU_LTS    : flag_reg = $signed(a) < $signed(b);
            `ALU_GES    : flag_reg = $signed(a) >= $signed(b);
            `ALU_LTU    : flag_reg = a < b;
            `ALU_GEU    : flag_reg = a >= b;
            default     : flag_reg = 0; 
        endcase
    end

    assign res = res_reg;
    assign flag = flag_reg;

endmodule
