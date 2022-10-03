`timescale 1ns / 1ps

module RF_tb;

  reg         clk;
  
  reg  [4:0]  addr1;
  reg  [4:0]  addr2;
  reg  [4:0]  addr3;
  
  reg  [31:0] wd3;
  reg         we3;
  
  wire [31:0] rd1;
  wire [31:0] rd2;

  RF rf (
    .clk_i   ( clk   ),
    
    .addr1_i ( addr1 ),
    .addr2_i ( addr2 ),
    .addr3_i ( addr3 ),
    
    .wd3_i   ( wd3   ),
    .we3_i   ( we3   ),
    
    .rd1_o   ( rd1   ),
    .rd2_o   ( rd2   )
  );
  
  integer i;
  
  initial
    begin
      $display("Test started...\n");
    
      we3 = 1;
    
      for (i = 1; i < 32; i = i + 1)
        begin
          #10 clk = 0;
          
          wd3 = i;
          addr3 = i;
          
          #10 clk = 1; 
        end
      
      we3 = 0;
      
      for (i = 1; i < 32; i = i + 1)
        begin
          #10      
          addr1 = i;
          addr2 = i;
          
          #10
          $display("reg: %3d, loaded: %3d, rd1: %3d, rd2: %3d", i, i, rd1, rd2);
          
          if (rd1 == i && rd2 == i)
            $display("good\n");
          else
            $display("bad\n");
        end
        
        $display("Test finished!\n");
    end

endmodule
