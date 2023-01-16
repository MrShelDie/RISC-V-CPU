`include "miriscv_defines.vh"

`timescale 1ns / 1ps

module addr_decoder
#(
    parameter RAM_SIZE = 256    // bytes
)
(
    input            we_i,
    input            req_i,
    input     [31:0] addr_i,

    output           req_mem_o,
    output           we_mem_o,
    output           we_d0_o,
    output           we_d1_o,
    output reg [1:0] rd_sel_o
);

    wire data_mem_valid = addr_i >= RAM_SIZE ? 1'b0 : 1'b1;

    wire req_d0         = addr_i[31:12] == 28'h80001;
    wire req_d1         = addr_i[31:12] == 28'h80002;
    assign req_mem_o    = ~(req_d0 | req_d1) & data_mem_valid;

    assign we_d0_o      = req_i & we_i & req_d0;
    assign we_d1_o      = req_i & we_i & req_d1;
    assign we_mem_o     = req_i & we_i & req_mem_o;

    always @(*) begin
        if (req_d0)
            rd_sel_o <= `RDSEL_DEV0;
        else if (req_d1)
            rd_sel_o <= `RDSEL_DEV1;
        else
            rd_sel_o <= `RDSEL_MEM;
    end

endmodule
