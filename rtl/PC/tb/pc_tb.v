`timescale 1ns / 1ps

module pc_tb;
  reg clk;
  reg reset;
  reg stop_pc;
  reg [31:0] pc_write_data;
  wire [31:0] pc_out;
  integer errors = 0;

  pc dut (
      .clk(clk),
      .reset(reset),
      .stop_pc(stop_pc),
      .pc_in(pc_write_data),
      .pc_out(pc_out)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  task check(input [31:0] expected, input [255:0] name);
    begin
      if (pc_out !== expected) begin
        $display("[FAIL] %0s: expected %h, got %h", name, expected, pc_out);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    reset = 1;
    stop_pc = 0;
    pc_write_data = 32'h0AAA1200;
    @(posedge clk);
    #1;
    check(32'h0, "reset");

    reset = 0;
    @(posedge clk);
    #1;
    check(32'h0AAA1200, "load value");

    pc_write_data = 4;
    @(posedge clk);
    #1;
    check(32'd4, "second value");

    // stall: PC must hold while stop_pc is high
    stop_pc = 1;
    pc_write_data = 32'd8;
    @(posedge clk);
    #1;
    check(32'd4, "hold on stall");
    @(posedge clk);
    #1;
    check(32'd4, "hold on stall (2nd cycle)");

    stop_pc = 0;
    @(posedge clk);
    #1;
    check(32'd8, "resume after stall");

    // reset has priority over stall
    stop_pc = 1;
    reset = 1;
    @(posedge clk);
    #1;
    check(32'h0, "reset beats stall");

    if (errors == 0) $display("[PASS] PC tests completed");
    else $display("[FAIL] %0d PC errors", errors);
    $finish;
  end
endmodule
