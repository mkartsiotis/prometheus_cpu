`timescale 1ns / 1ps

module hazard_detection_unit_tb;
  reg id_ex_MemRead, branch_taken;
  reg [4:0] id_ex_rd, if_id_rs1, if_id_rs2;
  wire stall, stall_pc, if_id_flush, id_ex_flush;
  integer errors = 0;

  hazard_detection_unit dut (
      .id_ex_MemRead(id_ex_MemRead),
      .id_ex_rd(id_ex_rd),
      .if_id_rs1(if_id_rs1),
      .if_id_rs2(if_id_rs2),
      .branch_taken(branch_taken),
      .stall(stall),
      .stall_pc(stall_pc),
      .if_id_flush(if_id_flush),
      .id_ex_flush(id_ex_flush)
  );

  task check(input exp_stall, input exp_if_flush, input exp_id_flush, input [255:0] name);
    begin
      #1;
      if (stall !== exp_stall || stall_pc !== exp_stall || if_id_flush !== exp_if_flush ||
          id_ex_flush !== exp_id_flush) begin
        $display("[FAIL] %0s: stall=%b stall_pc=%b if_id_flush=%b id_ex_flush=%b", name, stall,
                 stall_pc, if_id_flush, id_ex_flush);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    id_ex_MemRead = 0; branch_taken = 0; id_ex_rd = 3; if_id_rs1 = 3; if_id_rs2 = 4;
    check(0, 0, 0, "not a load");

    id_ex_MemRead = 1;
    check(1, 0, 1, "load-use on rs1");
    if_id_rs1 = 1; if_id_rs2 = 3;
    check(1, 0, 1, "load-use on rs2");
    if_id_rs2 = 4;
    check(0, 0, 0, "load, no dependency");

    id_ex_rd = 0; if_id_rs1 = 0;
    check(0, 0, 0, "load into x0 never stalls");

    id_ex_MemRead = 0; branch_taken = 1;
    check(0, 1, 1, "taken branch flushes IF/ID and ID/EX");

    if (errors == 0) $display("[PASS] Hazard detection unit tests completed");
    else $display("[FAIL] %0d hazard errors", errors);
    $finish;
  end
endmodule
