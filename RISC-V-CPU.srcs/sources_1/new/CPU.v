`timescale 1ns / 1ps

module cpu(
  input         clk_i,
  input         rst_i
);

  wire [31:0] pc;
  
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
  wire        branch;
  wire        jal;
  wire        jalr; 
  
  wire [31:0] rf_wd;
  wire        rf_we = gpr_we_a;
  
  wire [31:0] rf_rd1;
  wire [31:0] rf_rd2;
  reg  [31:0] op1;
  reg  [31:0] op2;
  
  wire [31:0] alu_res;
  wire        alu_flag;
  
  wire [31:0] data_mem_rd;
  
  wire [31:0] imm_B = { 19'b0, instr[31],    instr[7],     instr[30:25], instr[11:8],  1'b0 };
  wire [31:0] imm_J = { 11'b0, instr[31],    instr[19:12], instr[20],    instr[30:21], 1'b0 };
  wire [31:0] imm_S = { 20'b0, instr[31:25], instr[11:7]                                    };
  wire [31:0] imm_I = { 20'b0, instr[31:20]                                                 };

  pc_module pc_module(
    .clk_i     ( clk_i    ),
    .rst_i     ( rst_i    ),
    
    .imm_I_i   ( imm_I    ),
    .imm_J_i   ( imm_J    ),
    .imm_B_i   ( imm_B    ),
    
    .rf_rd1_i  ( rf_rd1   ),
    
    .jal_i     ( jal      ),
    .jalr_i    ( jalr     ),
    .branch_i  ( branch   ),
    .alu_flag_i( alu_flag ),
    
    .pc_o      ( pc       )
  );

  instr_mem instr_mem(
    .addr_i ( pc ),
    
    .rd_o   ( instr )
  );
  
  main_decoder main_decoder (
    .fetched_instr_i ( instr         ),
    
    .ex_op_a_sel_o   ( ex_op_a_sel   ),
    .ex_op_b_sel_o   ( ex_op_b_sel   ),
    .alu_op_o        ( alu_op        ),
    .mem_req_o       ( mem_req       ),
    .mem_we_o        ( mem_we        ),
    .mem_size_o      ( mem_size      ),
    .gpr_we_a_o      ( gpr_we_a      ),
    .wb_src_sel_o    ( wb_src_sel    ),
    .illegal_instr_o ( illegal_instr ),
    .branch_o        ( branch        ),
    .jal_o           ( jal           ),
    .jalr_o          ( jalr          )
  );
  
  reg_file rf(
    .clk_i   ( clk_i        ),
    
    .addr1_i ( instr[19:15] ),
    .addr2_i ( instr[24:20] ),
    .addr3_i ( instr[11:7]  ),
    
    .wd3_i   ( rf_wd        ),
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
  
  data_mem data_mem(
    .clk_i  ( clk_i       ),
  
    .we_i   ( mem_we      ),
    .addr_i ( alu_res     ),
    .wd_i   ( rf_rd2      ),
    
    .rd_o   ( data_mem_rd )
  );

  assign rf_wd = wb_src_sel ? data_mem_rd : alu_res;
  
endmodule
