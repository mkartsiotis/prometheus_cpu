`timescale 1ns / 1ps

module shifter #(
    parameter BIT_LENGTH = 8
) (
    input [BIT_LENGTH-1:0] x,
    input [($clog2(BIT_LENGTH) -1):0] shamt,
    output [BIT_LENGTH-1:0] result_r,
    result_l
);
  assign result_l = x << shamt;
  assign result_r = x >> shamt;
endmodule
