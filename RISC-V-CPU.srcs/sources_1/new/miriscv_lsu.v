`include "miriscv_defines.vh"

`timescale 1ns / 1ps

module miriscv_lsu(
    input           clk_i,              // Sync
    input           arstn_i,            // Reset internal registers

    /* core protocol */
    input   [31:0]  lsu_addr_i,         // The address where we want to get the data
    input           lsu_we_i,           // 1 - if you need to write to memory
    input   [2:0]   lsu_size_i,         // Size of processed data
    input   [31:0]  lsu_data_i,         // Data to be written to memory
    input           lsu_req_i,          // 1 - access memory
    output          lsu_stall_req_o,    // Used as !enable pc
    output  [31:0]  lsu_data_o,         // Data read from memory
    output          lsu_ill_addr_o,     // 1 - when accessing to memory at an unaligned address

    /* memory protocol */
    input   [31:0]  data_rdata_i,       // Requested data
    output          data_req_o,         // 1 - access the memory
    output          data_we_o,          // 1 is a write request
    output  [3:0]   data_be_o,          // Which bytes of the word are being accessed
    output  [31:0]  data_addr_o,        // The address to which the appeal is being sent
    output  [31:0]  data_wdata_o        // Data to be written to memory
);

    reg         lsu_clk;
    reg         lsu_ill_addr;
    reg [3:0]   data_be;
    reg [31:0]  data_wdata;
    reg [31:0]  lsu_data;

    reg [3:0]   data_be_byte;
    reg [3:0]   data_be_hw;

    reg [31:0]  lsu_data_byte;
    reg [31:0]  lsu_data_hw;
    reg [31:0]  lsu_data_ubyte;
    reg [31:0]  lsu_data_uhw;

    wire rst = ~arstn_i;

    assign lsu_stall_req_o  = ( lsu_req_i ^ lsu_clk ) & ~lsu_ill_addr_o;
    assign data_req_o       = lsu_stall_req_o;
    assign data_we_o        = lsu_stall_req_o & lsu_we_i;

    assign data_addr_o      = { lsu_addr_i[31:2], 2'b0 };
    assign lsu_ill_addr_o   = lsu_ill_addr;

    assign data_be_o        = data_be;
    assign data_wdata_o     = data_wdata;
    
    assign lsu_data_o       = lsu_data;

    /* Illegal address flag */
    always @( * ) begin
        if (    ( lsu_size_i == `LDST_H  && lsu_addr_i[0]   != 1'b0 )
             || ( lsu_size_i == `LDST_HU && lsu_addr_i[0]   != 1'b0 )
             || ( lsu_size_i == `LDST_W  && lsu_addr_i[1:0] != 2'b0 )
        )
            lsu_ill_addr <= 1;
        else
            lsu_ill_addr <= 0;
    end

    /* lsu_size to byte number decoder */
    always @( * ) begin
        case ( lsu_addr_i[1:0] )
            2'b00:      data_be_byte <= 4'b0001;
            2'b01:      data_be_byte <= 4'b0010;
            2'b10:      data_be_byte <= 4'b0100;
            default:    data_be_byte <= 4'b1000;
        endcase
    end

    /* lsu_size to half word number decoder */
    always @( * ) begin
        case ( lsu_addr_i[1] )
            1'b0:       data_be_hw <= 4'b0011;
            default:    data_be_hw <= 4'b1100;
        endcase
    end

    /* Selecting the result of the desired data_be_ decoder */
    always @( * ) begin
        case ( lsu_size_i )
            `LDST_B:    data_be <= data_be_byte;
            `LDST_H:    data_be <= data_be_hw;
            default:    data_be <= 4'b1111;
        endcase
    end

    /* lsu_data_byte */
    always @( * ) begin
        case ( lsu_addr_i[1:0] )
            2'b00:      lsu_data_byte <= { { 24 { data_rdata_i[7]  } }, data_rdata_i[7:0]   };
            2'b01:      lsu_data_byte <= { { 24 { data_rdata_i[15] } }, data_rdata_i[15:8]  };
            2'b10:      lsu_data_byte <= { { 24 { data_rdata_i[23] } }, data_rdata_i[23:16] };
            default:    lsu_data_byte <= { { 24 { data_rdata_i[31] } }, data_rdata_i[31:24] };
        endcase
    end

    /* lsu_data_ubyte */
    always @( * ) begin
        case ( lsu_addr_i[1:0] )
            2'b00:      lsu_data_ubyte <= {{ 24'b0, data_rdata_i[7:0]  }};
            2'b01:      lsu_data_ubyte <= {{ 24'b0, data_rdata_i[15:8] }};
            2'b10:      lsu_data_ubyte <= {{ 24'b0, data_rdata_i[23:16] }};
            default:    lsu_data_ubyte <= {{ 24'b0, data_rdata_i[31:24] }};
        endcase
    end

    /* lsu_data_hw */
    always @( * ) begin
        case ( lsu_addr_i[1] )
            1'b0:       lsu_data_hw <= { { 16 { data_rdata_i[15] } }, data_rdata_i[15:0]  };
            default:    lsu_data_hw <= { { 16 { data_rdata_i[31] } }, data_rdata_i[31:16] };
        endcase
    end

    /* lsu_data_uhw */
    always @( * ) begin
        case ( lsu_addr_i[1] )
            1'b0:       lsu_data_uhw <= { 16'b0, data_rdata_i[15:0]  };
            default:    lsu_data_uhw <= { 16'b0, data_rdata_i[31:16] };
        endcase
    end

    always @( * ) begin
        data_wdata <= lsu_data_i[31:0];
        lsu_data   <= data_rdata_i;

        case ( lsu_size_i )
            `LDST_B: begin
                data_wdata <= { 4 { lsu_data_i[7:0]  } };
                lsu_data   <= lsu_data_byte;
            end
            `LDST_H: begin
                data_wdata <= { 2 { lsu_data_i[15:0] } };
                lsu_data   <= lsu_data_hw;
            end
            `LDST_BU: begin
                lsu_data <= lsu_data_ubyte;
            end
            `LDST_HU: begin
                lsu_data <= lsu_data_uhw;
            end
        endcase
    end

    /* lsu_clk */
    always @( posedge clk_i or posedge rst ) begin
        if ( rst )
            lsu_clk <= 0;
        else if ( lsu_req_i )
            lsu_clk <= ~lsu_clk;
    end

endmodule
