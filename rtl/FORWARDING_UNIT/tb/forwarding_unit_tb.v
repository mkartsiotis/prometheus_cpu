`timescale 1ns / 1ps

module forwarding_unit_tb;
  reg ex_mem_RegWrite, mem_wb_RegWrite;
  reg [4:0] ex_mem_rd, mem_wb_rd, id_ex_rs1, id_ex_rs2;
  wire [1:0] forward_a, forward_b;
  integer errors = 0;

  forwarding_unit dut (
      .ex_mem_RegWrite(ex_mem_RegWrite),
      .mem_wb_RegWrite(mem_wb_RegWrite),
      .ex_mem_rd(ex_mem_rd),
      .mem_wb_rd(mem_wb_rd),
      .id_ex_rs1(id_ex_rs1),
      .id_ex_rs2(id_ex_rs2),
      .forward_a(forward_a),
      .forward_b(forward_b)
  );

  task check(input [1:0] exp_a, input [1:0] exp_b, input [255:0] name);
    begin
      #1;
      if (forward_a !== exp_a || forward_b !== exp_b) begin
        $display("[FAIL] %0s: forward_a=%b (exp %b) forward_b=%b (exp %b)", name, forward_a, exp_a,
                 forward_b, exp_b);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    ex_mem_RegWrite = 0; mem_wb_RegWrite = 0;
    ex_mem_rd = 0; mem_wb_rd = 0; id_ex_rs1 = 1; id_ex_rs2 = 2;
    check(2'b00, 2'b00, "no hazard");

    ex_mem_RegWrite = 1; ex_mem_rd = 1;
    check(2'b01, 2'b00, "EX/MEM -> rs1");
    ex_mem_rd = 2;
    check(2'b00, 2'b01, "EX/MEM -> rs2 only");

    ex_mem_RegWrite = 0; mem_wb_RegWrite = 1; mem_wb_rd = 1;
    check(2'b10, 2'b00, "MEM/WB -> rs1");
    mem_wb_rd = 2;
    check(2'b00, 2'b10, "MEM/WB -> rs2 only");

    // newest result wins when both stages match
    ex_mem_RegWrite = 1; ex_mem_rd = 1; mem_wb_rd = 1;
    check(2'b01, 2'b00, "EX/MEM priority over MEM/WB");

    // x0 is never forwarded
    id_ex_rs1 = 0; id_ex_rs2 = 0; ex_mem_rd = 0; mem_wb_rd = 0;
    check(2'b00, 2'b00, "x0 not forwarded");

    // RegWrite low blocks forwarding
    id_ex_rs1 = 5; id_ex_rs2 = 5; ex_mem_rd = 5; mem_wb_rd = 5;
    ex_mem_RegWrite = 0; mem_wb_RegWrite = 0;
    check(2'b00, 2'b00, "RegWrite low");

    if (errors == 0) $display("[PASS] Forwarding unit tests completed");
    else $display("[FAIL] %0d forwarding errors", errors);
    $finish;
  end
endmodule
