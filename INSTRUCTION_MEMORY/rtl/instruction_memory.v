module instruction_memory #(
    parameter ADDRESS_WIDTH = 8  // 2^8 = 256 words
) (
    input  [31:0] address,
    output [31:0] instruction_out
);
  reg [31:0] mem[0:(2**ADDRESS_WIDTH)-1];
  // READ
  assign instruction_out = mem[address[ADDRESS_WIDTH+1 : 2]];  // combinational read for single cycle
endmodule
