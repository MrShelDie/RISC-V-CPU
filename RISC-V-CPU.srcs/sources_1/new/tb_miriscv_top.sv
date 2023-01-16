`include "miriscv_defines.vh"

`timescale 1ns / 1ps

module tb_miriscv_top();
  parameter HF_CYCLE = 2.5;       		// 200 MHz clock
  parameter RST_WAIT = 10;        		// 10 ns reset
  parameter INT_WAIT = 3000;       		// 3000 ns
  parameter INT_RST_WAIT = 50;        // 20 ns

  parameter RAM_SIZE = 1024;       		// in 32-bit words
  parameter RAM_INIT_FILE = "iram.mem"; 

  reg clk;
  reg rst_n;

  reg BTNU;
  reg BTNR;
  reg BTND;
  reg BTNL;
  reg BTNC;

  reg [15:0] SW;

  wire [7:0] abcdefgh;
  wire [7:0] digit;

  `ifdef _DEBUG_
  wire [31:0] mem [0:RAM_SIZE/4-1];
  `endif

  miriscv_top #(
    .RAM_SIZE       ( RAM_SIZE      ),
    .RAM_INIT_FILE  ( RAM_INIT_FILE )
  ) dut (
    .clk_i   ( clk   ),
    .rst_n_i ( rst_n ),

    .BTNU_i  ( BTNU ),
    .BTNR_i  ( BTNR ),
    .BTND_i  ( BTND ),
    .BTNL_i  ( BTNL ),
    .BTNC_i  ( BTNC ),

    .SW_i    ( SW   ),

    .abcdefgh_o ( abcdefgh ),
    .digit_o    ( digit    )

    `ifdef _DEBUG_
    ,.mem_o    ( mem     )
    `endif
  );

  initial begin

    `ifndef _DEBUG_
      $display("Undefined _DEBUG_ macro");
      $finish;
    `endif // !_DEBUG_

    clk   = 1'b0;
    rst_n = 1'b0;
    
    #RST_WAIT;
    rst_n = 1'b1;

    #INT_WAIT
    BTNC <= 1'b1;
    #INT_RST_WAIT
    BTNC <= 1'b0;

    #INT_WAIT
    BTNC <= 1'b1;
    #INT_RST_WAIT
    BTNC <= 1'b0;

    #INT_WAIT
    BTNC <= 1'b1;
    #INT_RST_WAIT
    BTNC <= 1'b0;

	#INT_WAIT
    $finish;
  end

  initial begin
  	BTNU  = 1'b0;
    BTNR  = 1'b0;
    BTND  = 1'b0;
    BTNL  = 1'b0;
    BTNC  = 1'b0;
              
    SW    = 16'b0;
  end

  initial begin
  	forever begin
    	#HF_CYCLE;
    	clk = ~clk;
    end
  end

endmodule
