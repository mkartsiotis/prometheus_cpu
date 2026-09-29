`timescale 1ns / 1ps
// Load-use stall: hold PC and IF/ID, bubble ID/EX.
// Control hazard: a taken branch/jump in EX flushes IF/ID and ID/EX.
// The two cases cannot overlap: the instruction in EX is either a load or a branch/jump.
module hazard_detection_unit (
    input id_ex_MemRead,
    input [4:0] id_ex_rd,
    if_id_rs1,
    if_id_rs2,
    input branch_taken,
    output stall,
    stall_pc,
    if_id_flush,
    id_ex_flush
);
  assign stall = id_ex_MemRead && id_ex_rd != 0 && (id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2);
  assign stall_pc = stall;
  assign if_id_flush = branch_taken;
  assign id_ex_flush = stall || branch_taken;
endmodule
