`timescale 1ns / 1ps

module button_controller(
    input             clk_i,
    input             rstn_i,

    /* button protocol */
    input      [4:0]  BTN_i,
    input      [15:0] SW_i,
    input             intr_rst_i,

    /* lsu protocol */
    input             addr_i,
    output     [31:0] out_o,
    output reg        intr_o
);

    wire rst = ~rstn_i;

    assign out_o = addr_i ? { 27'b0, BTN_i } : { 16'b0, SW_i };

    reg  [20:0] last_state;
    wire [20:0] new_state = { SW_i, BTN_i };

    wire need_intr = (last_state != new_state) && !intr_o;

    /* last_state */
    always @(posedge clk_i or posedge rst) begin
        if (rst)
            last_state <= 21'b0;
        else
            last_state <= new_state;
    end

    /* intr */
    always @(posedge clk_i or posedge rst) begin
        if (rst || intr_rst_i)
            intr_o <= 1'b0;
        else if (need_intr)
            intr_o <= 1'b1;
    end

endmodule
