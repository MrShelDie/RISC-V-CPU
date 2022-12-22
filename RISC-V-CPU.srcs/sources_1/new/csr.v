`timescale 1ns / 1ps

module csr(
    input           clk_i,
    input           rst_i,

    input   [2:0]   op_i,
    input   [11:0]  addr_i,
    input   [31:0]  wd_i,
    input   [31:0]  pc_i,
    input   [31:0]  mcause_i,

    output  [31:0]  mie_o,
    output  [31:0]  mtvec_o,
    output  [31:0]  mepc_o,
    output  [31:0]  rd_o
);

    localparam MIE_ADDR         = 12'h304;
    localparam MTVEC_ADDR       = 12'h305;
    localparam MSCRATCH_ADDR    = 12'h340;
    localparam MEPS_ADDR        = 12'h341;
    localparam MCAUSE_ADDR      = 12'h342;

    reg [31:0]  mie;
    reg [31:0]  mtvec;
    reg [31:0]  mscratch;
    reg [31:0]  mepc;
    reg [31:0]  mcause;

    reg [31:0]  rd;

    assign mie_o    = mie;
    assign mtvec_o  = mtvec;
    assign mepc_o   = mepc;

    assign rd_o     = rd;

    /* Address multiplexer */
    always @(*) begin
        case (addr_i)
            MIE_ADDR:       rd <= mie;
            MTVEC_ADDR:     rd <= mtvec;
            MSCRATCH_ADDR:  rd <= mscratch;
            MEPS_ADDR:      rd <= mepc;
            MCAUSE_ADDR:    rd <= mcause;
            default:        rd <= 31'b0;
        endcase
    end

    /* Demultiplexer outputs to enabling the corresponding registers */
    reg mie_reg_en;
    reg mtvec_reg_en;
    reg mscratch_reg_en;
    reg meps_reg_en;
    reg mcause_reg_en;

    /* The last two bits of op_i determine whether the reg will be enabled */
    wire will_reg_enabled       = op_i[1] | op_i[0];
    /* MSb of op_i determines wheter mepc and mcause regs will be updated */
    wire will_mepc_mcause_updated = op_i[2];

    /* Address demultiplexer */
    always @(*) begin
        mie_reg_en      <= 1'b0;
        mtvec_reg_en    <= 1'b0;
        mscratch_reg_en <= 1'b0;
        meps_reg_en     <= 1'b0;
        mcause_reg_en   <= 1'b0;

        case (addr_i)
            MIE_ADDR:      mie_reg_en      <= will_reg_enabled;
            MTVEC_ADDR:    mtvec_reg_en    <= will_reg_enabled;
            MSCRATCH_ADDR: mscratch_reg_en <= will_reg_enabled;
            MEPS_ADDR:     meps_reg_en     <= will_reg_enabled;
            MCAUSE_ADDR:   mcause_reg_en   <= will_reg_enabled;
        endcase
    end

    /* Data to be writen to one of the CSR registers */
    reg     [31:0]  data_to_write;
    /* The last two bits of op_i determine which data will writen */
    wire    [1:0]   select_data_to_write = op_i[1:0];

    /* Multiplexer that selects which data will be writen */
    always @(*) begin
        case (select_data_to_write)
            2'b01:      data_to_write <=  wd_i;
            2'b10:      data_to_write <=  wd_i | rd;
            2'b11:      data_to_write <= ~wd_i & rd;
            default:    data_to_write <=  32'b0;
        endcase
    end

    /* mie */
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i)
            mie <= 32'b0;
        else if (mie_reg_en)
            mie <= data_to_write;
    end

    /* mtvec */
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i)
            mtvec <= 32'b0;
        else if (mtvec_reg_en)
            mtvec <= data_to_write;
    end

    /* mscratch */
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i)
            mscratch <= 32'b0;
        else if (mscratch_reg_en)
            mscratch <= data_to_write;
    end
    
    /* mepc */
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i)
            mepc <= 32'b0;
        else if (will_mepc_mcause_updated)
            mepc <= pc_i;
        else if (meps_reg_en)
            mepc <= data_to_write;
    end
    
    /* mcause */
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i)
            mcause <= 32'b0;
        else if (will_mepc_mcause_updated)
            mcause <= mcause_i;
        else if (mcause_reg_en)
            mcause <= data_to_write;
    end

endmodule
