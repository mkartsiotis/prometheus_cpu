module fpga_top (
    input  clk,
    input  reset,
    output led
);
  wire [31:0] pc;

  cpu core (
      .clk(clk),
      .reset(reset),
      .pc(pc)
      // Internal/debug outputs should not become board pins.
  );
  assign led = pc[0];
endmodule
