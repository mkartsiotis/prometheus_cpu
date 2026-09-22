`timescale 1ns / 1ps
module shifter_tb;

  parameter BIT_LENGTH = 8;

  reg [BIT_LENGTH-1:0] x;
  reg [($clog2(BIT_LENGTH) - 1):0] shamt;
  wire [BIT_LENGTH-1:0] result_l, result_r;

  integer i, l;
  integer errors = 0;

  reg [BIT_LENGTH-1:0] expected_r, expected_l, true_r, true_l;

  shifter #(
      .BIT_LENGTH(BIT_LENGTH)
  ) dut (
      .x(x),
      .shamt(shamt),
      .result_l(result_l),
      .result_r(result_r)
  );

  initial begin
    for (i = 0; i < (1 << BIT_LENGTH); i = i + 1) begin
      for (l = 0; l < (1 << ($clog2(BIT_LENGTH) - 1)); l = l + 1) begin
        // --- TESTS ---
        x = i;
        shamt = l;
        #1;
        true_l = result_l;
        true_r = result_r;
        expected_l = x << shamt;
        expected_r = x >> shamt;
        if (expected_l !== true_l || expected_r !== true_r) begin
          errors = errors + 1;
          $display(
              "SHIFT FAIL: x=%0d, shamt=%0d, shift_right=%0d (expected_r=%0d), shift_left=%0d(expected_l=%0d)",
              x, shamt, true_r, expected_r, true_l, expected_l);
        end
      end
    end

    if (errors == 0) $display("ALL %0d TESTS PASSED", (1 << BIT_LENGTH) * (1 << BIT_LENGTH) * 2);
    else $display("%0d TEST(S) FAILED", errors);
    $finish;
  end
endmodule
