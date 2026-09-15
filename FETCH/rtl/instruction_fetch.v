module instruction_fetch (
    input clk,
    reset,
    output [31:0] instruction_out,
    pc_out
);
  wire [31:0] next_pc;

  pc p_counter (
      .clk(clk),
      .reset(reset),
      .pc_in(next_pc),
      .pc_out(pc_out)
  );
  instruction_memory imem (
      .address(pc_out),
      .instruction_out(instruction_out)
  );
  assign next_pc = pc_out + 32'd4;

endmodule
