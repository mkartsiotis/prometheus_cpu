`timescale 1ns / 1ps

module instruction_memory_tb;
  // DUT Inputs (driven by TB -> reg)
  // Instantiate the correct module name
  // Clock Generation (10ns period)

  reg  [31:0] address;
  wire [31:0] instruction_out;
  instruction_memory dut (
      .address(address),
      .instruction_out(instruction_out)
  );
  // Test Stimulus
  initial begin
    dut.mem[0] = 32'h1234_5678;
    dut.mem[1] = 32'hDEAD_BEEF;
    dut.mem[2] = 32'hCAFE_BABE;
    #1;  // Wait for write edge to take effect
    address = 0;
    #1;
    if (instruction_out !== 32'h1234_5678)
      $error("Read failed! Expected h1234_5678, Got 0x%h", instruction_out);
    #1;  // Wait for write edge to take effect
    address = 4;
    #1;
    if (instruction_out !== 32'hDEAD_BEEF)
      $error("Read failed! Expected  hDEAD_BEEF, Got 0x%h", instruction_out);
    #1;  // Wait for write edge to take effect
    address = 8;
    #1;
    if (instruction_out !== 32'hCAFE_BABE)
      $error("Read failed! Expected hCAFE_BABE, Got 0x%h", instruction_out);
    $display("ALL TESTS COMPLETED");
    $finish;
  end
endmodule
