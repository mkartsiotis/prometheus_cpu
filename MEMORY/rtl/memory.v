`timescale 1ns / 1ps

module memory #(
    parameter ADDRESS_WIDTH = 8  // 2^8 = 256 words
) (
    input clk,
    input [31:0] address,
    input [31:0] write_data,
    input mem_write,
    input mem_read,
    output [31:0] read_data
);
  //Since memory is combinational for single stage architecture we do not need
  //anything as a mem_read. So it is fine!
  reg [31:0] mem[0:(2**ADDRESS_WIDTH)-1];

  // READ
  assign read_data = mem[address[ADDRESS_WIDTH+1 : 2]];  // combinational read for single cycle
  // write logic
  always @(posedge clk) begin
    if (mem_write) begin
      mem[address[ADDRESS_WIDTH+1 : 2]] <= write_data;
    end
  end
endmodule
