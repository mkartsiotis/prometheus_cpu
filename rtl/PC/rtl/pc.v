`timescale 1ns / 1ps

module pc (
    input clk,
    reset,
    stop_pc,
    input [31:0] pc_in,
    output [31:0] pc_out
);
  reg [31:0] PC;
  always @(posedge clk) begin
    if (reset) PC <= 32'b0;
    else if (!stop_pc) PC <= pc_in;
  end
  assign pc_out = PC;
endmodule
