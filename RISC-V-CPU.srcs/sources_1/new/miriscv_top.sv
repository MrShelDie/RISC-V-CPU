`include "miriscv_defines.vh"

module miriscv_top
#(
    parameter RAM_SIZE      = 1024, // bytes
    parameter RAM_INIT_FILE = ""
)
(
    input         clk_i,
    input         rst_n_i,

    /* Buttons */
    input         BTNU_i,
    input         BTNR_i,
    input         BTND_i,
    input         BTNL_i,
    input         BTNC_i,

    /* Switches */
    input  [15:0] SW_i,

    output [7:0]  abcdefgh_o,
    output [7:0]  digit_o
    
    `ifdef _DEBUG_
    ,output [31:0] mem_o [0:RAM_SIZE/4-1]
    `endif
);

    logic  [31:0]  instr_rdata;
    logic  [31:0]  instr_addr;

    logic  [31:0]  data_rdata;
    logic          data_req;
    logic          data_we;
    logic  [3:0]   data_be;
    logic  [31:0]  data_addr;
    logic  [31:0]  data_wdata;

    logic          data_req_ram;
    logic          data_we_ram;
    logic          data_we_d0;
    logic          data_we_d1;

    logic  [31:0]  data_rdata_ram;
    logic  [31:0]  data_rdata_d0;
    logic  [31:0]  data_rdata_d1;
    logic  [1:0]   rd_sel;

    logic          intr;
    logic          int_rst;
    logic  [31:0]  mcause;
    logic  [31:0]  mie;

    logic  [31:0]  int_req;
    wire  [31:0]  int_fin;

    wire  [4:0]   BTN_i      = { BTNU_i, BTNR_i, BTND_i, BTNL_i, BTNC_i };
    wire          btn_intr;
    wire          btn_int_fin = int_fin[0];
    assign         int_req[0] = btn_intr;
    assign		   int_req[31:1] = 31'b0;

    miriscv_core core (
        .clk_i   ( clk_i   ),
        .arstn_i ( rst_n_i ),

        .int_i     ( intr    ),
        .mcause_i  ( mcause  ),
        .mie_o     ( mie     ),
        .int_rst_o ( int_rst ),

        .instr_rdata_i ( instr_rdata ),
        .instr_addr_o  ( instr_addr  ),

        .data_rdata_i  ( data_rdata  ),
        .data_req_o    ( data_req    ),
        .data_we_o     ( data_we     ),
        .data_be_o     ( data_be     ),
        .data_addr_o   ( data_addr   ),
        .data_wdata_o  ( data_wdata  )
    );

    addr_decoder #(
        .RAM_SIZE ( RAM_SIZE )
    ) addr_decoder(
        .we_i   ( data_we   ),
        .req_i  ( data_req  ),
        .addr_i ( data_addr ),

        .req_mem_o ( data_req_ram ),
        .we_mem_o  ( data_we_ram  ),
        .we_d0_o   ( data_we_d0   ),
        .we_d1_o   ( data_we_d1   ),
        .rd_sel_o  ( rd_sel       )
    );

    miriscv_ram #(
        .RAM_SIZE      (RAM_SIZE),
        .RAM_INIT_FILE (RAM_INIT_FILE)
    ) ram (
        .clk_i   ( clk_i   ),
        .rst_n_i ( rst_n_i ),

        .instr_rdata_o ( instr_rdata ),
        .instr_addr_i  ( instr_addr  ),

        .data_rdata_o  ( data_rdata_ram ),
        .data_req_i    ( data_req_ram   ),
        .data_we_i     ( data_we_ram    ),
        .data_be_i     ( data_be        ),
        .data_addr_i   ( data_addr      ),
        .data_wdata_i  ( data_wdata     )
        
        `ifdef _DEBUG_
        ,.mem_o        ( mem_o )
        `endif
    );

    led_controller led_controller(
        .clk_i  ( clk_i   ),
        .rstn_i ( rst_n_i ),

        .addr_i  ( data_addr[3:2] ),
        .be_i    ( data_be        ),
        .we_i    ( data_we_d0     ),
        .wdata_i ( data_wdata     ),
        .out_o   ( data_rdata_d0  ),

        .abcdefgh_o ( abcdefgh_o ),
        .digit_o    ( digit_o    )
    );

    button_controller button_controller(
        .clk_i  ( clk_i   ),
        .rstn_i ( rst_n_i ),

        .BTN_i      ( BTN_i       ),
        .SW_i       ( SW_i        ),
        .intr_rst_i ( btn_int_fin ),

        .addr_i ( data_addr[2]  ),
        .out_o  ( data_rdata_d1 ),
        .intr_o ( btn_intr      )
    );

    interrupt_controller interrupt_controller(
        .clk_i  ( clk_i   ),
        .rstn_i ( rst_n_i ),

        .mie_i     ( mie     ),
        .int_req_i ( int_req ),
        .int_rst_i ( int_rst ),

        .mcause_o  ( mcause  ),
        .int_o     ( intr    ),
        .int_fin_o ( int_fin )
    );

    always @(*) begin
        case (rd_sel)
            2'b00:   data_rdata <= data_rdata_ram;
            2'b01:   data_rdata <= data_rdata_d0;
            2'b10:   data_rdata <= data_rdata_d1;
            default: data_rdata <= 32'b0;
        endcase
    end

endmodule