`timescale 1ns / 1ps

module instruction_fetch (
    input clk,
    reset,
    input [31:0] pc_input,
    output [31:0] instruction_out,
    pc_out
);
  pc p_counter (
      .clk(clk),
      .reset(reset),
      .pc_in(pc_input),
      .pc_out(pc_out)
  );
  instruction_memory imem (
      .address(pc_out),
      .instruction_out(instruction_out)
  );
endmodule
