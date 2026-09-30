`timescale 1ns / 1ps

module instruction_fetch #(
    parameter IMEM_SEED_HEX = ""  // optional $readmemh file for synthesis-time BRAM content
) (
    input clk,
    reset,
    stop_pc,
    input [31:0] pc_input,
    output [31:0] instruction_out,
    pc_out
);
  pc p_counter (
      .clk(clk),
      .stop_pc(stop_pc),
      .reset(reset),
      .pc_in(pc_input),
      .pc_out(pc_out)
  );
  instruction_memory #(
      .ADDRESS_WIDTH(15),
      .SEED_HEX(IMEM_SEED_HEX)
  ) imem (
      .address(pc_out),
      .instruction_out(instruction_out)
  );
endmodule
