`timescale 1ns / 1ps

module memory_tb;
  reg clk;
  reg mem_write;
  reg mem_read;
  reg [2:0] mem_size;
  reg [31:0] address;
  reg [31:0] write_data;
  wire [31:0] read_data;

  memory #(
      .ADDRESS_WIDTH(8)
  ) dut (
      .clk(clk),
      .address(address),
      .write_data(write_data),
      .mem_write(mem_write),
      .mem_read(mem_read),
      .mem_size(mem_size),
      .read_data(read_data)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    mem_write = 0;
    mem_read = 0;
    mem_size = 3'b000;
    address = 0;
    write_data = 0;
    #1;

    // Store a known little-endian word at address 4.
    mem_size = 3'b000;  // sw
    mem_write = 1;
    address = 32'h0000_0004;
    write_data = 32'h44332211;
    @(posedge clk);
    #1;
    mem_write = 0;

    // Full-word load.
    mem_size = 3'b000;  // lw
    mem_read = 1;
    address = 32'h0000_0004;
    @(posedge clk);
    #1;
    if (read_data !== 32'h44332211)
      $fatal(1, "lw failed: expected 0x44332211, got 0x%h", read_data);
    mem_read = 0;

    // Signed byte loads: addresses 4, 5, 6, and 7 select lanes 0, 1, 2, 3.
    mem_size = 3'b010;  // lb
    address = 32'h0000_0004;
    mem_read = 1;
    @(posedge clk);
    #1;
    if (read_data !== 32'h00000011)
      $fatal(1, "lb lane 0 failed: got 0x%h", read_data);

    address = 32'h0000_0005;
    @(posedge clk);
    #1;
    if (read_data !== 32'h00000022)
      $fatal(1, "lb lane 1 failed: got 0x%h", read_data);

    address = 32'h0000_0006;
    @(posedge clk);
    #1;
    if (read_data !== 32'h00000033)
      $fatal(1, "lb lane 2 failed: got 0x%h", read_data);

    address = 32'h0000_0007;
    @(posedge clk);
    #1;
    if (read_data !== 32'h00000044)
      $fatal(1, "lb lane 3 failed: got 0x%h", read_data);
    mem_read = 0;

    // Halfword loads: address 4 selects [15:0], address 6 selects [31:16].
    mem_size = 3'b001;  // lh
    mem_read = 1;
    address = 32'h0000_0004;
    @(posedge clk);
    #1;
    if (read_data !== 32'h00002211)
      $fatal(1, "lh lower halfword failed: got 0x%h", read_data);

    address = 32'h0000_0006;
    @(posedge clk);
    #1;
    if (read_data !== 32'h00004433)
      $fatal(1, "lh upper halfword failed: got 0x%h", read_data);
    mem_read = 0;

    // Byte store must preserve the other three bytes.
    mem_size = 3'b010;  // sb
    mem_write = 1;
    address = 32'h0000_0005;
    write_data = 32'h000000aa;
    @(posedge clk);
    #1;
    mem_write = 0;

    mem_size = 3'b000;  // lw
    mem_read = 1;
    address = 32'h0000_0004;
    @(posedge clk);
    #1;
    if (read_data !== 32'h4433aa11)
      $fatal(1, "sb failed: expected 0x4433aa11, got 0x%h", read_data);
    mem_read = 0;

    // Halfword store must preserve the other halfword.
    mem_size = 3'b001;  // sh
    mem_write = 1;
    address = 32'h0000_0006;
    write_data = 32'h0000bbbb;
    @(posedge clk);
    #1;
    mem_write = 0;

    mem_size = 3'b000;  // lw
    mem_read = 1;
    address = 32'h0000_0004;
    @(posedge clk);
    #1;
    if (read_data !== 32'hbbbbaa11)
      $fatal(1, "sh failed: expected 0xbbbbaa11, got 0x%h", read_data);
    mem_read = 0;

    $display("Memory tests completed.");
    $finish;
  end
endmodule
