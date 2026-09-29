`timescale 1ns / 1ps
module if_id_reg (
    input [31:0] fetched_instruction_in,
    pc_in,
    input clk,
    stall,
    flush,
    reset,
    output [31:0] fetched_instruction_out,
    pc_out
);
  reg [31:0] fetched_instruction, pc;
  always @(posedge clk) begin
    if (reset || flush) begin
      fetched_instruction <= 32'b0;
      pc <= 32'b0;
    end else if (!stall) begin
      fetched_instruction <= fetched_instruction_in;
      pc <= pc_in;
    end
  end
  assign pc_out = pc;
  assign fetched_instruction_out = fetched_instruction;
endmodule

