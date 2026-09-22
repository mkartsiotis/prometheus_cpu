`timescale 1ns / 1ps

module bitwiseops_tb;

  parameter BIT_LENGTH = 8;

  reg [BIT_LENGTH-1:0] x, y;
  wire [BIT_LENGTH-1:0] or_w, xor_w, and_w, nor_w;

  integer i, j;
  integer errors = 0;

  reg [BIT_LENGTH-1:0] exp_or, exp_and, exp_nor, exp_xor;

  bitwiseops #(
      .BIT_LENGTH(BIT_LENGTH)
  ) dut (
      .x(x),
      .y(y),
      .and_res(and_w),
      .or_res(or_w),
      .xor_res(xor_w),
      .nor_res(nor_w)
  );

  initial begin
    for (i = 0; i < (1 << BIT_LENGTH); i = i + 1) begin
      for (j = 0; j < (1 << BIT_LENGTH); j = j + 1) begin

        // --- TESTS ---
        x = i;
        y = j;
        #1;  // let combinational logic settle
        exp_or  = x | y;
        exp_and = x & y;
        exp_nor = (~(x | y));
        exp_xor = x ^ y;
        if (or_w !== exp_or || xor_w !== exp_xor || nor_w !== exp_nor || and_w !== exp_and) begin
          errors = errors + 1;
          $display(
              "ADD FAIL: x=%0d y=%0d | and=%0d (exp %0d), or=%0b (exp %0b), xor=%0b (exp %0b), nor=%0b(exp %0b)",
              x, y, and_w, exp_and, or_w, exp_or, xor_w, exp_xor, nor_w, exp_xor);
        end
      end
    end

    if (errors == 0) $display("ALL %0d TESTS PASSED", (1 << BIT_LENGTH) * (1 << BIT_LENGTH));
    else $display("%0d TEST(S) FAILED", errors);

    $finish;
  end
endmodule
