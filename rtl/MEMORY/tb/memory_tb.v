`timescale 1ns / 1ps

module memory_tb;
  // DUT Inputs (driven by TB -> reg)
  reg clk;
  reg mem_write;
  reg mem_read;
  reg [31:0] address;
  reg [31:0] write_data;

  // DUT Outputs (observed by TB -> wire)
  wire [31:0] read_data;

  // Instantiate the correct module name
  memory #(
      .ADDRESS_WIDTH(8)
  ) dut (
      .clk(clk),
      .address(address),
      .write_data(write_data),
      .mem_write(mem_write),
      .mem_read(mem_read),
      .read_data(read_data)
  );

  // Clock Generation (10ns period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test Stimulus
  initial begin
    // Initialize signals
    mem_write = 0;
    mem_read = 0;
    address = 0;
    write_data = 0;
    #10;

    // 1. Basic Single Word Write and Read Check
    mem_write  = 1;
    address    = 32'h0000_0004;  // Word index 1
    write_data = 32'hDEADBEEF;
    @(posedge clk);

    #1;  // Wait for write edge to take effect
    mem_write = 0;
    if (read_data !== 32'hDEADBEEF) $error("Read failed! Expected 0xDEADBEEF, Got 0x%h", read_data);

    // 2. Test Word Alignment (Addresses 0x04, 0x05, 0x06, 0x07 map to index 1)
    address = 32'h0000_0007;
    #1;  // Combinational read delay
    if (read_data !== 32'hDEADBEEF)
      $error("Alignment test failed! Expected 0xDEADBEEF, Got 0x%h", read_data);

    $display("Tests Completed.");
    $finish;
  end
endmodule
