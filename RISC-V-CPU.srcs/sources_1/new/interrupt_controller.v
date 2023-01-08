`timescale 1ns / 1ps

module interrupt_controller(
    input           clk_i,
    input           rstn_i,

    input   [31:0]  mie_i,
    input   [31:0]  int_req_i,
    input           int_rst_i,

    output  [31:0]  mcause_o,
    output          int_o,
    output  [31:0]  int_fin_o
);

    wire            rst = ~rstn_i;

    reg     [4:0]   counter;
    wire            counter_en;

    wire    [31:0]  decoder = 32'b1 << counter;
    wire    [31:0]  selected_interrupt = mie_i & int_req_i & decoder;

    reg             is_interrupt_reg;
    wire            is_interrupt = |selected_interrupt;

	assign			counter_en = ~is_interrupt;
    assign          int_fin_o = selected_interrupt & { 32 { int_rst_i } };
    assign          int_o = is_interrupt ^ is_interrupt_reg;
    assign          mcause_o = { 27'b0, counter };

    /* Counter */
    always @(posedge clk_i or posedge rst or posedge int_rst_i) begin
        if (rst || int_rst_i)
            counter <= 5'b0;
        else if (counter_en)
            counter <= counter + 5'b1;
    end

    /* Interrupt register */
    always @(posedge clk_i or posedge rst or posedge int_rst_i) begin
        if (rst || int_rst_i)
            is_interrupt_reg <= 1'b0;
        else
            is_interrupt_reg <= is_interrupt;
    end

endmodule
