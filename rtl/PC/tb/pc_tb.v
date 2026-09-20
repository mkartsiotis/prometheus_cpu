`timescale 1ns / 1ps

module pc_tb;
  // DUT Inputs (driven by TB -> reg)
  reg clk;
  reg reset;
  reg [31:0] pc_write_data;
  // DUT Outputs (observed by TB -> wire)
  wire [31:0] pc_out;
  // Instantiate the correct module name
  pc dut (
      .clk(clk),
      .reset(reset),
      .pc_in(pc_write_data),
      .pc_out(pc_out)
  );

  // Clock Generation (10ns period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test Stimulus
  initial begin
    clk = 0;
    reset = 1;
    pc_write_data = 32'hAAA1200;
    // Initialize signals
    @(posedge clk);
    #1;  // Wait for write edge to take effect
    if (pc_out !== 32'b0) $error("RESET FAIL!");
    @(posedge clk);
    #1;
    reset = 0;
    #1;
    @(posedge clk);
    #1;
    if (pc_out !== 32'hAAA1200) $error("WRITE FAIL!");
    #1;
    @(posedge clk);
    #1;
    pc_write_data = 0;
    @(posedge clk);
    #1;
    if (pc_out != 0) $error("Write error for first value");
    #1;
    @(posedge clk);
    #1;
    pc_write_data = 4;
    @(posedge clk);
    #1;
    if (pc_out != 4) $error("Write error for second value");
    #1;
    @(posedge clk);
    #1;
    pc_write_data = 8;
    @(posedge clk);
    #1;
    if (pc_out != 8) $error("Write error for third value");
    #1;
    $display("Tests Completed.");
    $finish;
  end
endmodule
