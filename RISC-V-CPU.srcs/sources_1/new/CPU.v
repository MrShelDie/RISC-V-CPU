`timescale 1ns / 1ps

module CPU(
  input         clk_i,
  input         rst_i,
  
  input  [31:0] IN_i,
  
  output [31:0] OUT_o
);

  reg [7:0]   PC;
  
  wire [31:0] bus;
  
  reg  [31:0] rf_wd;
  wire        rf_we = bus[28] | bus[29];
    
  wire [31:0] op1;
  wire [31:0] op2;
  
  wire [31:0] alu_res;
  wire        alu_flag;

  RAM iram (
    .addr_i ( PC    ),
    
    .rd_o   ( bus   )
  );
  
  RF rf(
    .clk_i    ( clk_i      ),
    
    .addr1_i ( bus[22:18] ),
    .addr2_i ( bus[17:13] ),
    .addr3_i ( bus[4:0]   ),
    
    .wd3_i   ( rf_wd      ),
    .we3_i   ( rf_we      ),
    
    .rd1_o   ( op1 ),
    .rd2_o   ( op2 )
  );
    
  ALU alu(
    .opcode_i ( bus[27:23] ),
    .a_i      ( op1        ),
    .b_i      ( op2        ),
    
    .res_o    ( alu_res    ),
    .flag_o   ( alu_flag   )
  );
  
  always @( * )
    case ( bus[29:28] )
      2'b01: rf_wd <= IN_i;
      2'b10: rf_wd <= { 9'd0, bus[27:5] };
      2'b11: rf_wd <= alu_res;
      default: rf_wd <= 0;
    endcase
  
  always @( posedge clk_i or posedge rst_i )
    if ( rst_i )
      PC <= 8'd0;
    else if ( bus[31] || ( bus[30] && alu_flag ) )
      PC <= PC + bus[12:5];
    else
      PC <= PC + 8'd1;
  
  assign OUT_o = op1;
  
endmodule
