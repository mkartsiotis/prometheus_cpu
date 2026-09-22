`timescale 1ns / 1ps

module adder_tb;

  parameter BIT_LENGTH = 8;

  reg [BIT_LENGTH-1:0] x, y;
  reg subtract;
  wire [BIT_LENGTH-1:0] sum;
  wire cout, overflow, is_zero, slt, slt_u;

  integer i, j;
  integer errors = 0;

  reg [BIT_LENGTH-1:0] exp_sum;
  reg exp_cout;
  reg exp_ovf;
  reg exp_zero;
  reg exp_cmp_res, exp_cmp_res_u;
  adder #(
      .BIT_LENGTH(BIT_LENGTH)
  ) dut (
      .x(x),
      .y(y),
      .subtract(subtract),
      .sum(sum),
      .cout(cout),
      .overflow(overflow),
      .is_zero(is_zero),
      .slt(slt),
      .slt_u(slt_u)
  );

  initial begin
    for (i = 0; i < (1 << BIT_LENGTH); i = i + 1) begin
      for (j = 0; j < (1 << BIT_LENGTH); j = j + 1) begin

        // --- ADDITION TESTS ---
        x = i;
        y = j;
        subtract = 0;
        #1;  // let combinational logic settle

        exp_sum = x + y;
        exp_cout = ((x + y) >= (1 << BIT_LENGTH));
        exp_ovf  = (x[BIT_LENGTH-1] == y[BIT_LENGTH-1]) && 
                   (exp_sum[BIT_LENGTH-1] != x[BIT_LENGTH-1]);
        exp_zero = (exp_sum == 0);

        if (sum !== exp_sum || cout !== exp_cout || overflow !== exp_ovf || is_zero !== exp_zero) begin
          errors = errors + 1;
          $display(
              "ADD FAIL: x=%0d y=%0d | sum=%0d (exp %0d), cout=%0b (exp %0b), ovf=%0b (exp %0b), zero=%0b (exp %0b)",
              x, y, sum, exp_sum, cout, exp_cout, overflow, exp_ovf, is_zero, exp_zero);
        end

        // --- SUBTRACTION TESTS ---
        x = i;
        y = j;
        subtract = 1;
        #1;  // let combinational logic settle

        exp_sum = x - y;
        exp_cout = (x >= y);  // 2's complement cout is 1 (no borrow) when x >= y
        exp_ovf  = (x[BIT_LENGTH-1] != y[BIT_LENGTH-1]) &&
                   (exp_sum[BIT_LENGTH-1] != x[BIT_LENGTH-1]);
        exp_zero = (exp_sum == 0);

        if (sum !== exp_sum || cout !== exp_cout || overflow !== exp_ovf || is_zero !== exp_zero) begin
          errors = errors + 1;
          $display(
              "SUB FAIL: x=%0d y=%0d | sum=%0d (exp %0d), cout=%0b (exp %0b), ovf=%0b (exp %0b), zero=%0b (exp %0b)",
              x, y, sum, exp_sum, cout, exp_cout, overflow, exp_ovf, is_zero, exp_zero);
        end
        //Comparison tests
        x = i;
        y = j;
        subtract = 1;
        exp_cmp_res = ($signed(x) < $signed(y));
        exp_cmp_res_u = ($unsigned(x) < $unsigned(y));
        // Signed check (SLT)
        if (slt !== exp_cmp_res) begin
          $error("SLT Mismatch! x=%d, y=%d, got=%b, expected=%b", $signed(x), $signed(y), slt,
                 ($signed(x) < $signed(y)));
        end

        // Unsigned check (SLTU)
        if (slt_u !== exp_cmp_res_u) begin
          $error("SLTU Mismatch! x=%d, y=%d, got=%b, expected=%b", x, y, slt_u, (x < y));
        end

      end
    end

    if (errors == 0) $display("ALL %0d TESTS PASSED", (1 << BIT_LENGTH) * (1 << BIT_LENGTH) * 3);
    else $display("%0d TEST(S) FAILED", errors);

    $finish;
  end
endmodule
