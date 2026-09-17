`timescale 1ns / 1ps

module instruction_memory_hex_tb;
  reg [31:0] address;
  wire [31:0] instruction_out;

  instruction_memory dut (
      .address(address),
      .instruction_out(instruction_out)
  );

  initial begin
    $readmemh("integrated_tests/test_1.hex", dut.mem);

    address = 32'd0;
    #1;
    if (instruction_out !== 32'h0050_0093)
      $error("WORD 0 FAIL: %h", instruction_out);
    else
      $display("[PASS] WORD 0: %h", instruction_out);

    address = 32'd4;
    #1;
    if (instruction_out !== 32'h0070_0113)
      $error("WORD 1 FAIL: %h", instruction_out);
    else
      $display("[PASS] WORD 1: %h", instruction_out);

    address = 32'd8;
    #1;
    if (instruction_out !== 32'h0020_81B3)
      $error("WORD 2 FAIL: %h", instruction_out);
    else
      $display("[PASS] WORD 2: %h", instruction_out);

    address = 32'd12;
    #1;
    if (instruction_out !== 32'h0030_2023)
      $error("WORD 3 FAIL: %h", instruction_out);
    else
      $display("[PASS] WORD 3: %h", instruction_out);

    $display("[PASS] $readmemh instruction image loading");
    $finish;
  end
endmodule
