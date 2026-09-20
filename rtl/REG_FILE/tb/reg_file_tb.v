`timescale 1ns / 1ps
module reg_file_tb;
  parameter BIT_LENGTH = 32, REG_NUMBER = 32;

  reg clk = 0;
  always #5 clk = ~clk;

  reg [BIT_LENGTH-1:0] wb_data;
  reg wb_enable;
  reg [$clog2(REG_NUMBER)-1:0] reg1_sel, reg2_sel, reg3_sel;
  wire [BIT_LENGTH-1:0] reg1_data, reg2_data;

  reg_file #(
      .BIT_LENGTH(BIT_LENGTH),
      .REG_NUMBER(REG_NUMBER)
  ) dut (
      .clk(clk),
      .wb_data(wb_data),
      .wb_enable(wb_enable),
      .reg1_sel(reg1_sel),
      .reg2_sel(reg2_sel),
      .reg3_sel(reg3_sel),
      .reg1_data(reg1_data),
      .reg2_data(reg2_data)
  );

  integer errors = 0;

  task write_reg(input [$clog2(REG_NUMBER)-1:0] addr, input [BIT_LENGTH-1:0] data);
    begin
      @(negedge clk);  // safe time to change inputs, away from the write edge
      reg3_sel  = addr;
      wb_data   = data;
      wb_enable = 1;
      @(negedge clk);  // the posedge in between just performed the actual write
      wb_enable = 0;
    end
  endtask

  initial begin
    for (integer i = 1; i < 32; i = i + 1) write_reg(i, (2 * i));
    write_reg(0, 13);
    for (integer i = 1; i < 31; i = i + 1) begin
      reg1_sel = i;
      reg2_sel = i + 1;
      #1;  // Wait 1 time unit for the combinational logic to settle
      if (reg1_data !== (2 * i) || reg2_data !== (2 * (i + 1))) begin
        $display("REGISTER FILE ERROR! reg_1_data=%0d(expected=%0d), reg2_data=%0d(exp=%0d)",
                 reg1_data, 2 * i, reg2_data, (2 * (i + 1)));
        errors = errors + 1;
      end
      reg1_sel = 0;
      #1;
      if (reg1_data !== 0) $display("$t0 REG FAIL!GOT:%0d, EXPECTED:0", reg1_data);
    end
    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d TEST(S) FAILED", errors);
    $finish;
  end
endmodule
