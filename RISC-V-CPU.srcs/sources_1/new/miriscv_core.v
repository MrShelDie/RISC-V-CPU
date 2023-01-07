`timescale 1ns / 1ps

module miriscv_core(
	input         clk_i,
	input         arstn_i,

	/* interrupt controller */
	input           int_i,
	input   [31:0]  mcause_i,
	output  [31:0]  mie_o,
	output          int_rst_o,

	/* instruction memory */
	input   [31:0]  instr_rdata_i,
	output  [31:0]  instr_addr_o,

	/* data memory */
	input   [31:0]  data_rdata_i,
	output          data_req_o,
	output          data_we_o,
	output  [3:0]   data_be_o,
	output  [31:0]  data_addr_o,
	output  [31:0]  data_wdata_o
);

	wire rst = ~arstn_i;

	wire [31:0] pc;
	wire        en_n_pc;
	
	/* Main decoder wires */
	wire [31:0] instr;
	wire [1:0]  ex_op_a_sel;
	wire [2:0]  ex_op_b_sel;
	wire [4:0]  alu_op;
	wire        mem_req;
	wire        mem_we;
	wire [2:0]  mem_size;
	wire        gpr_we_a;
	wire        wb_src_sel;
	wire        illegal_instr;
	wire        illegal_instr_decoder;
	wire        illegal_instr_lsu;
	wire        branch;
	wire        jal;
	wire [1:0]  jalr; 
	wire        csr_src_sel;
	wire [2:0]	csr_op;
	
	/* CSR wires */
	wire [31:0] mtvec;
	wire [31:0] mepc;
	wire [31:0] csr_rd;

	wire [31:0] rf_wd_mux_1;
	wire [31:0] rf_wd_mux_2;
	wire        rf_we;
	
	wire [31:0] rf_rd1;
	wire [31:0] rf_rd2;
	reg  [31:0] op1;
	reg  [31:0] op2;

	wire [31:0] alu_res;
	wire        alu_flag;
	
	wire [31:0] data_mem_rd;
	
	wire [31:0] imm_B = { { 20 { instr[31] } }, instr[7],     instr[30:25], instr[11:8],  1'b0 };
	wire [31:0] imm_J = { { 12 { instr[31] } }, instr[19:12], instr[20],    instr[30:21], 1'b0 };
	wire [31:0] imm_S = { { 21 { instr[31] } }, instr[30:25], instr[11:7]                      };
	wire [31:0] imm_I = { { 21 { instr[31] } }, instr[30:20]                                   };

	assign instr_addr_o = pc;
	assign instr        = instr_rdata_i;

	assign rf_wd_mux_1 = wb_src_sel  ? data_mem_rd : alu_res;
	assign rf_wd_mux_2 = csr_src_sel ? csr_rd      : rf_wd_mux_1;
	assign rf_we = gpr_we_a;
	
	assign illegal_instr = illegal_instr_decoder | illegal_instr_lsu; 

	pc_module pc_module(
		.clk_i      ( clk_i     ),
		.rst_i      ( rst       ),
		.en_n_i     ( en_n_pc   ),
		
		.imm_I_i    ( imm_I     ),
		.imm_J_i    ( imm_J     ),
		.imm_B_i    ( imm_B     ),
		
		.mtvec_i	( mtvec		),
		.mepc_i		( mepc		),

		.rf_rd1_i   ( rf_rd1    ),
		
		.jal_i      ( jal       ),
		.jalr_i     ( jalr      ),
		.branch_i   ( branch    ),
		.alu_flag_i ( alu_flag  ),
		
		.pc_o       ( pc        )
	);

	csr csr(
		.clk_i		( clk_i 					),
		.rst_i		( rst   					),

		.op_i		( csr_op					),
		.addr_i 	( instr[31:20]				),
		.wd_i		( rf_rd1 					),
		.pc_i		( pc						),
		.mcause_i	( mcause_i 					),

		.mie_o		( mie_o						),
		.mtvec_o	( mtvec						),
		.mepc_o		( mepc 						),	
		.rd_o		( csr_rd					)
	);
	
	main_decoder main_decoder (
		.fetched_instr_i ( instr                  ),
		.int_i			 ( int_i				  ),
		
		.ex_op_a_sel_o   ( ex_op_a_sel            ),
		.ex_op_b_sel_o   ( ex_op_b_sel            ),
		.alu_op_o        ( alu_op                 ),
		.mem_req_o       ( mem_req                ),
		.mem_we_o        ( mem_we                 ),
		.mem_size_o      ( mem_size               ),
		.gpr_we_a_o      ( gpr_we_a               ),
		.wb_src_sel_o    ( wb_src_sel             ),
		.illegal_instr_o ( illegal_instr_decoder  ),
		.branch_o        ( branch                 ),
		.jal_o           ( jal                    ),
		.jalr_o          ( jalr                   ),
		.int_rst_o		 ( int_rst_o			  ),
		.csr_op_o		 ( csr_op				  ),
		.csr_o			 ( csr_src_sel			  )
	);
	
	reg_file rf(
		.clk_i   ( clk_i        ),
		
		.addr1_i ( instr[19:15] ),
		.addr2_i ( instr[24:20] ),
		.addr3_i ( instr[11:7]  ),
		
		.wd3_i   ( rf_wd_mux_2  ),
		.we3_i   ( rf_we        ),
		
		.rd1_o   ( rf_rd1       ),
		.rd2_o   ( rf_rd2       )
	);
	
	/* alu_op1 */
	always @( * ) begin
	case ( ex_op_a_sel )
		2'd0:    op1 = rf_rd1;
		2'd1:    op1 = pc;
		default: op1 = 32'd0;
	endcase
	end
	
	/* alu_op2 */
	always @( * ) begin
	case ( ex_op_b_sel )
		3'd0:    op2 = rf_rd2;
		3'd1:    op2 = imm_I;
		3'd2:    op2 = { instr[31:12], 12'd0 };
		3'd3:    op2 = imm_S;
		default: op2 = 32'd4;
	endcase
	end
	
	alu alu(
		.opcode_i ( alu_op       ),
		.a_i      ( op1          ),
		.b_i      ( op2          ),
		
		.res_o    ( alu_res      ),
		.flag_o   ( alu_flag     )
	);
	
	miriscv_lsu lsu(
		.clk_i            ( clk_i             ),
		.arstn_i          ( arstn_i           ),
	
		.lsu_addr_i       ( alu_res           ),
		.lsu_we_i         ( mem_we            ),
		.lsu_size_i       ( mem_size          ),
		.lsu_data_i       ( rf_rd2            ),
		.lsu_req_i        ( mem_req           ),
		.lsu_stall_req_o  ( en_n_pc           ),
		.lsu_data_o       ( data_mem_rd       ),
		.lsu_ill_addr_o   ( illegal_instr_lsu ),
	
		.data_rdata_i     ( data_rdata_i      ),
		.data_req_o       ( data_req_o        ),
		.data_we_o        ( data_we_o         ),
		.data_be_o        ( data_be_o         ),
		.data_addr_o      ( data_addr_o       ),
		.data_wdata_o     ( data_wdata_o      )
	);
	
endmodule
