`timescale 1ns / 1ps

module pc (
    input clk,
    reset,
    input [31:0] pc_in,
    output [31:0] pc_out
);
  reg [31:0] PC;
  always @(posedge clk) begin
    if (reset == 0) PC <= pc_in;
    else PC <= 32'b0;
  end
  assign pc_out = PC;
endmodule
