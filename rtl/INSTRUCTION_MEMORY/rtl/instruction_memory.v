`timescale 1ns / 1ps

module instruction_memory #(
    parameter ADDRESS_WIDTH = 8  // 2^8 = 256 words
) (
    input  [31:0] address,
    output [31:0] instruction_out
);
  reg [31:0] mem[0:(2**ADDRESS_WIDTH)-1];
  // Zero-init so synthesis sees a defined value (BRAM needs a real INIT anyway);
  // testbenches always overwrite this with $readmemh/direct pokes before running.
  integer init_i;
  initial begin
    for (init_i = 0; init_i < (2 ** ADDRESS_WIDTH); init_i = init_i + 1) mem[init_i] = 32'b0;
  end
  // READ
  assign instruction_out = mem[address[ADDRESS_WIDTH+1 : 2]];  // combinational read for single cycle
endmodule
