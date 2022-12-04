`include "miriscv_defines.vh"

`timescale 1ns / 1ps

module main_decoder(
  input       [31:0]  fetched_instr_i,
  
  output  reg [1:0]   ex_op_a_sel_o,
  output  reg [2:0]   ex_op_b_sel_o, 
  output  reg [4:0]   alu_op_o,
  output  reg         mem_req_o, 
  output  reg         mem_we_o,
  output  reg [2:0]   mem_size_o,
  output  reg         gpr_we_a_o,
  output  reg         wb_src_sel_o,
  output  reg         illegal_instr_o,
  output  reg         branch_o,
  output  reg         jal_o,
  output  reg         jalr_o 
);

  wire [2:0] funct3 = fetched_instr_i[14:12];

  always @(*) begin
    ex_op_a_sel_o   <= 2'b00;
    ex_op_b_sel_o   <= 3'b000;
    alu_op_o        <= 4'b0000;
    mem_req_o       <= 1'b0;
    mem_we_o        <= 1'b0;
    mem_size_o      <= 3'b000;
    gpr_we_a_o      <= 1'b0;
    wb_src_sel_o    <= 1'b0;
    illegal_instr_o <= 1'b0;
    branch_o        <= 1'b0;
    jal_o           <= 1'b0;
    jalr_o          <= 1'b0;
    
    if ( fetched_instr_i[1:0] != 2'b11 )
      illegal_instr_o <= 1;
    else
      case ( fetched_instr_i[6:2] )
        `LUI_OPCODE:   begin
                          ex_op_a_sel_o <= `OP_A_ZERO;
                          ex_op_b_sel_o <= `OP_B_IMM_U;
                          alu_op_o      <= `ALU_ADD;
                          wb_src_sel_o  <= `WB_EX_RESULT;
                          gpr_we_a_o    <= 1'b1;
                        end
        `AUIPC_OPCODE: begin
                           ex_op_a_sel_o <= `OP_A_CURR_PC;
                           ex_op_b_sel_o <= `OP_B_IMM_U;
                           alu_op_o      <= `ALU_ADD;
                           wb_src_sel_o  <= `WB_EX_RESULT;
                           gpr_we_a_o    <= 1'b1;
                        end
        `JAL_OPCODE:    begin
                          ex_op_a_sel_o <= `OP_A_CURR_PC;
                          ex_op_b_sel_o <= `OP_B_INCR;
                          alu_op_o      <= `ALU_ADD;
                          wb_src_sel_o  <= `WB_EX_RESULT;
                          gpr_we_a_o    <= 1'b1;
                          jal_o         <= 1'b1;
                        end
        `JALR_OPCODE:   begin
                          if ( funct3 != 3'b000 )
                            illegal_instr_o <= 1;
                          else begin
                            ex_op_a_sel_o <= `OP_A_CURR_PC;
                            ex_op_b_sel_o <= `OP_B_INCR;
                            alu_op_o      <= `ALU_ADD;
                            wb_src_sel_o  <= `WB_EX_RESULT;
                            gpr_we_a_o    <= 1'b1;
                            jalr_o        <= 1'b1;
                          end
                        end
        `BRANCH_OPCODE: begin
                          if ( funct3 == 3'b010 || funct3 == 3'b011 )
                            illegal_instr_o <= 1;
                          else begin
                            ex_op_a_sel_o <= `OP_A_RS1;
                            ex_op_b_sel_o <= `OP_B_RS2;
                            alu_op_o      <= { 2'b11, funct3 };
                            branch_o      <= 1'b1;
                          end
                        end
        `LOAD_OPCODE:   begin
                          if ( funct3 == 3'b011 || funct3 == 3'b110 || funct3 == 3'b111 )
                            illegal_instr_o <= 1;
                          else begin
                            ex_op_a_sel_o <= `OP_A_RS1;
                            ex_op_b_sel_o <= `OP_B_IMM_I;
                            alu_op_o      <= `ALU_ADD;
                            mem_req_o     <= 1'b1;
                            mem_size_o    <= funct3;
                            gpr_we_a_o    <= 1'b1;
                            wb_src_sel_o  <= `WB_LSU_DATA;
                          end
                        end
        `STORE_OPCODE:  begin
          if ( fetched_instr_i[14] == 1'b1 ||  fetched_instr_i[13 : 12] == 2'b11 )
                            illegal_instr_o <= 1;
                          else begin
                            ex_op_a_sel_o <= `OP_A_RS1;
                            ex_op_b_sel_o <= `OP_B_IMM_S;
                            alu_op_o      <= `ALU_ADD;
                            mem_req_o     <= 1'b1;
                            mem_we_o      <= 1'b1;
                            mem_size_o    <= funct3;
                          end
                        end
        `OP_IMM_OPCODE: begin
                          if (    ( funct3 == 3'b001 && fetched_instr_i[31:25] != 7'b000_0000 )
                               || ( funct3 == 3'b101 && fetched_instr_i[31:25] != 7'b000_0000
                                                     && fetched_instr_i[31:25] != 7'b010_0000 )
                          )
                            illegal_instr_o <= 1;
                          else begin
                            ex_op_a_sel_o <= `OP_A_RS1;
                            ex_op_b_sel_o <= `OP_B_IMM_I;
                            alu_op_o      <= { 2'b00, funct3 };
                            wb_src_sel_o  <= `WB_EX_RESULT;
                            gpr_we_a_o    <= 1'b1;
                          end
                        end
        `OP_OPCODE:     begin
                          if (      fetched_instr_i[31:25] != 7'b000_0000
                               && !(fetched_instr_i[31:25] == 7'b010_0000 && funct3 == 3'b000
                               && !(fetched_instr_i[31:25] == 7'b010_0000 && funct3 == 3'b101))
                          )
                            illegal_instr_o <= 1;
                          else begin
                            ex_op_a_sel_o <= `OP_A_RS1;
                            ex_op_b_sel_o <= `OP_B_RS2;
                            alu_op_o      <= fetched_instr_i[30] ? { 2'b01, funct3 } : { 2'b00, funct3 };
                            wb_src_sel_o  <= `WB_EX_RESULT;
                            gpr_we_a_o    <= 1'b1;
                          end
                        end
        `MISC_MEM_OPCODE: begin end
        `SYSTEM_OPCODE:   begin end
        default:
          illegal_instr_o <= 1;
      endcase
  end

endmodule
