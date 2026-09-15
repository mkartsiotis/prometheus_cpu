`timescale 1ns / 1ps

module instruction_fetch_tb;
  reg clk;
  reg reset;

  wire [31:0] instruction_out;
  wire [31:0] pc_out;

  instruction_fetch dut (
      .clk            (clk),
      .reset          (reset),
      .instruction_out(instruction_out),
      .pc_out         (pc_out)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    dut.imem.mem[0] = 32'h1111_1111;
    dut.imem.mem[1] = 32'h2222_2222;
    dut.imem.mem[2] = 32'h3333_3333;
    dut.imem.mem[3] = 32'h4444_4444;

    reset = 1;

    @(posedge clk);
    #1;
    if (pc_out !== 32'd0 || instruction_out !== 32'h1111_1111)
      $error("RESET/FETCH FAIL: PC=%h instruction=%h", pc_out, instruction_out);

    reset = 0;

    @(posedge clk);
    #1;
    if (pc_out !== 32'd4 || instruction_out !== 32'h2222_2222)
      $error("FETCH 1 FAIL: PC=%h instruction=%h", pc_out, instruction_out);

    @(posedge clk);
    #1;
    if (pc_out !== 32'd8 || instruction_out !== 32'h3333_3333)
      $error("FETCH 2 FAIL: PC=%h instruction=%h", pc_out, instruction_out);

    @(posedge clk);
    #1;
    if (pc_out !== 32'd12 || instruction_out !== 32'h4444_4444)
      $error("FETCH 3 FAIL: PC=%h instruction=%h", pc_out, instruction_out);

    $display("INSTRUCTION FETCH TESTS COMPLETED");
    $finish;
  end
endmodule
