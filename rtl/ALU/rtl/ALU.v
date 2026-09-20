`timescale 1ns / 1ps

module alu #(
    parameter WIDTH = 32
) (
    input      [WIDTH-1:0] x,
    y,
    input      [      3:0] opcode,
    output reg [WIDTH-1:0] result,
    output                 zero,
    cout,
    overflow
);
  wire subtract = opcode[0];
  // MATRIX WITH THE OPCODES
  localparam [3:0] ADD = 4'b0000;
  localparam [3:0] SUB = 4'b0001;
  localparam [3:0] SLT = 4'b0011;
  localparam [3:0] SLTU = 4'b0111;
  localparam [3:0] AND = 4'b0010;
  localparam [3:0] OR = 4'b0100;
  localparam [3:0] XOR = 4'b0101;
  localparam [3:0] NOR = 4'b0110;
  localparam [3:0] SLL = 4'b1000;
  localparam [3:0] SRL = 4'b1001;
  localparam [3:0] PASS_Y = 4'b1011;
  wire [WIDTH-1:0] sum;
  wire adder_cout, adder_overflow, adder_zero, slt, sltu;
  adder #(
      .BIT_LENGTH(WIDTH)
  ) u_adder (
      .x(x),
      .y(y),
      .subtract(subtract),
      .sum(sum),
      .cout(adder_cout),
      .overflow(adder_overflow),
      .is_zero(adder_zero),
      .slt(slt),
      .slt_u(sltu)
  );

  wire [WIDTH-1:0] and_res, or_res, xor_res, nor_res;
  bitwiseops #(
      .BIT_LENGTH(WIDTH)
  ) u_bitwise (
      .x(x),
      .y(y),
      .and_res(and_res),
      .or_res(or_res),
      .xor_res(xor_res),
      .nor_res(nor_res)
  );

  wire [WIDTH-1:0] sll_res, srl_res;
  shifter #(
      .BIT_LENGTH(WIDTH)
  ) u_shifter (
      .x(x),
      .shamt(y[$clog2(WIDTH)-1:0]),
      .result_l(sll_res),
      .result_r(srl_res)
  );

  always @(*) begin
    case (opcode)
      ADD: result = sum;
      SUB: result = sum;
      SLT: result = {{(WIDTH - 1) {1'b0}}, slt};
      SLTU: result = {{(WIDTH - 1) {1'b0}}, sltu};
      AND: result = and_res;
      OR: result = or_res;
      XOR: result = xor_res;
      NOR: result = nor_res;
      SLL: result = sll_res;
      SRL: result = srl_res;
      PASS_Y: result = y;
      default: result = {WIDTH{1'b0}};
    endcase
  end
  assign zero     = (result == {WIDTH{1'b0}});
  assign cout     = adder_cout;
  assign overflow = adder_overflow;
endmodule
