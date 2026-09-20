`timescale 1ns / 1ps

module bitwiseops #(
    parameter BIT_LENGTH = 8
) (
    input  [BIT_LENGTH-1:0] x,
    y,
    output [BIT_LENGTH-1:0] and_res,
    or_res,
    xor_res,
    nor_res
);
  assign and_res = x & y;
  assign or_res  = x | y;
  assign xor_res = (x ^ y);
  assign nor_res = (~or_res);
endmodule
