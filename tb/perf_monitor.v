`timescale 1ns / 1ps

// Testbench-only performance counters. It mirrors the pipeline with one valid bit per stage,
// so bubbles (stall/flush) are not counted as instructions.
module perf_monitor (
    input clk,
    input reset,
    input stall,
    input if_id_flush,
    input id_ex_flush,
    input ex_branch,
    input ex_branch_taken,
    input [1:0] ex_jump,
    input mem_read,
    input mem_write
);
  reg v_id, v_ex, v_mem, v_wb;
  integer cycles, retired, stalls, flush_bubbles;
  integer loads, stores, branches, taken_branches, jumps;

  initial begin
    v_id = 0; v_ex = 0; v_mem = 0; v_wb = 0;
    cycles = 0; retired = 0; stalls = 0; flush_bubbles = 0;
    loads = 0; stores = 0; branches = 0; taken_branches = 0; jumps = 0;
  end

  always @(posedge clk) begin
    if (reset) begin
      v_id <= 0; v_ex <= 0; v_mem <= 0; v_wb <= 0;
    end else begin
      cycles = cycles + 1;
      if (v_wb) retired = retired + 1;
      if (stall) stalls = stalls + 1;
      if (v_ex && if_id_flush) flush_bubbles = flush_bubbles + 2;
      if (v_mem && mem_read) loads = loads + 1;
      if (v_mem && mem_write) stores = stores + 1;
      if (v_ex && ex_branch) begin
        branches = branches + 1;
        if (ex_branch_taken) taken_branches = taken_branches + 1;
      end
      if (v_ex && ex_jump != 2'b00) jumps = jumps + 1;

      v_wb  <= v_mem;
      v_mem <= v_ex;
      v_ex  <= id_ex_flush ? 1'b0 : v_id;
      v_id  <= if_id_flush ? 1'b0 : (stall ? v_id : 1'b1);
    end
  end

  function real get_cpi(input integer dummy);
    begin
      get_cpi = (retired > 0) ? (cycles * 1.0 / retired) : 0.0;
    end
  endfunction
endmodule
