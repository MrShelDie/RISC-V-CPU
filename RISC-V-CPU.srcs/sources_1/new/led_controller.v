`timescale 1ns / 1ps

module led_controller
#(
    parameter DIGIT_CNT_WIDTH = 8,
    parameter BLINK_CNT_WIDTH = 4
) (
    input             clk_i,
    input             rstn_i,

    /* lsu protocol */
    input      [3:2]  addr_i,
    input      [3:0]  be_i,
    input             we_i,
    input      [31:0] wdata_i,
    output     [31:0] out_o,

    /* led protocol */
    output reg [7:0]  abcdefgh_o,
    output reg [7:0]  digit_o
);

    localparam VAL_0   = 8'b00000011;
    localparam VAL_1   = 8'b10011111;
    localparam VAL_2   = 8'b00100101;
    localparam VAL_3   = 8'b00001101;
    localparam VAL_4   = 8'b10011001;
    localparam VAL_5   = 8'b01001001;
    localparam VAL_6   = 8'b01000001;
    localparam VAL_7   = 8'b00011111;
    localparam VAL_8   = 8'b00000001;
    localparam VAL_9   = 8'b00001001;
    localparam VAL_A   = 8'b00010001;
    localparam VAL_B   = 8'b00000001;
    localparam VAL_C   = 8'b01100011;
    localparam VAL_D   = 8'b00000011;
    localparam VAL_E   = 8'b01100001;
    localparam VAL_F   = 8'b01110001;
    localparam VAL_OFF = 8'b11111111;

    wire rst = ~rstn_i;
    wire wrst = we_i && addr_i[3:2] == 2'b10 && be_i[2] && wdata_i[23:16];  // 0x8000100A = RST

    reg [3:0]  values [7:0];                    // 0x80001000 - 0x80001007
    reg [7:0]  on_off;                          // 0x80001008
    reg [7:0]  sel;                             // 0x80001009

    reg [31:0] out;
    assign out_o = out;

    // reg [28:0] counter;
    // wire blink_cnt_overflow = &counter[19:0];    // ~1 msec
    // wire digit_cnt_overflow = &counter;        // ~500 msec

    reg [DIGIT_CNT_WIDTH-1:0] counter;
    wire blink_cnt_overflow = &counter[BLINK_CNT_WIDTH-1:0];
    wire digit_cnt_overflow = &counter;

    reg blink;

    reg [3:0] val_sel;                          // select one register from values[]
    reg [7:0] val_sel_demux;                    // decoder val_sel to abcdefgh_o

    /* counter */
    always @(posedge clk_i or posedge rst) begin
        if (rst || wrst)
            counter <= 29'b0;
        else
            counter <= counter + 29'b1;
    end

    /* digit_o */
    always @(posedge clk_i or posedge rst) begin
        if (rst || wrst)
            digit_o <= 8'b11111110;
        else if (blink_cnt_overflow)
            digit_o <= { digit_o[6:0], digit_o[7] };
    end

    /* blink reg */
    always @(posedge clk_i or posedge rst) begin
        if (rst || wrst)
            blink <= 1'b0;
        else if (digit_cnt_overflow)
            blink <= ~blink;
    end

    /* val_sel */
    always @(*) begin
        case (digit_o)
            8'b11111110: val_sel <= values[0];
            8'b11111101: val_sel <= values[1];
            8'b11111011: val_sel <= values[2];
            8'b11110111: val_sel <= values[3];
            8'b11101111: val_sel <= values[4];
            8'b11011111: val_sel <= values[5];
            8'b10111111: val_sel <= values[6];
            8'b01111111: val_sel <= values[7];
            default:     val_sel <= 4'b0;
        endcase
    end

    /* value decoder */
    always @(*) begin
        case (val_sel)
            4'h1:    val_sel_demux <= VAL_1;
            4'h2:    val_sel_demux <= VAL_2;
            4'h3:    val_sel_demux <= VAL_3;
            4'h4:    val_sel_demux <= VAL_4;
            4'h5:    val_sel_demux <= VAL_5;
            4'h6:    val_sel_demux <= VAL_6;
            4'h7:    val_sel_demux <= VAL_7;
            4'h8:    val_sel_demux <= VAL_8;
            4'h9:    val_sel_demux <= VAL_9;
            4'hA:    val_sel_demux <= VAL_A;
            4'hB:    val_sel_demux <= VAL_B;
            4'hC:    val_sel_demux <= VAL_C;
            4'hD:    val_sel_demux <= VAL_D;
            4'hE:    val_sel_demux <= VAL_E;
            4'hF:    val_sel_demux <= VAL_F;
            default: val_sel_demux <= VAL_0;
        endcase
    end

    /* abcdefgh_o */
    always @(*) begin
        if (sel & digit_o)  // check wheter select mode for this digit is on
            abcdefgh_o <= blink ? val_sel_demux : VAL_OFF;
        else
            abcdefgh_o <= (on_off & digit_o) ? val_sel_demux : VAL_OFF;
    end

    /* write to values register */
    always @(posedge clk_i or posedge rst) begin
        if (rst || wrst) begin
        	values[0] <= 4'b0;
        	values[1] <= 4'b0;
        	values[2] <= 4'b0;
        	values[3] <= 4'b0;
        	values[4] <= 4'b0;
        	values[5] <= 4'b0;
        	values[6] <= 4'b0;
        	values[7] <= 4'b0;
        end
        else if (we_i && addr_i[3:2] == 2'b00) begin
            if (be_i[0])
                values[0] <= wdata_i[3:0];
            if (be_i[1])
                values[1] <= wdata_i[11:8];
            if (be_i[2])
                values[2] <= wdata_i[19:16];
            if (be_i[3])
                values[3] <= wdata_i[27:24];
        end
        else if (we_i && addr_i[3:2] == 2'b01) begin
            if (be_i[0])
                values[4] <= wdata_i[3:0];
            if (be_i[1])
                values[5] <= wdata_i[11:8];
            if (be_i[2])
                values[6] <= wdata_i[19:16];
            if (be_i[3])
                values[7] <= wdata_i[27:24];
        end
    end

    /* write to on_off register */
    always @(posedge clk_i or posedge rst) begin
        if (rst || wrst)
            on_off <= 8'hff;
        else if (we_i && addr_i[3:2] == 2'b10 && be_i[0])
            on_off <= wdata_i[7:0];
    end

    /* write sel reg */
    always @(posedge clk_i or posedge rst) begin
        if (rst || wrst)
            sel <= 8'h00;
        else if (we_i && addr_i[3:2] == 2'b10 && be_i[1])
            sel <= wdata_i[15:8];
    end

    /* read */
    always @(*) begin
        case (addr_i[3:2])
            2'b00:   out <= { 4'b0, values[3], 4'b0, values[2], 4'b0, values[1], 4'b0, values[0] };
            2'b01:   out <= { 4'b0, values[7], 4'b0, values[6], 4'b0, values[5], 4'b0, values[4] };
            2'b10:   out <= { 16'b0, sel, on_off };
            default: out <= 32'b0;
        endcase
    end

endmodule
