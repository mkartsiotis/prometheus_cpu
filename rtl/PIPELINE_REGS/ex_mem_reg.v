`timescale 1ns / 1ps
module ex_mem_reg (
    input clk,
    reset,
    flush,
    input [4:0] rd_in,
    input [31:0] alu_result_in,
    pc_in,
    store_data_in,
    input MemRead_in,
    MemWrite_in,
    input [2:0] mem_size_in,
    input RegWrite_in,
    input [1:0] ResultSrc_in,
    output [31:0] alu_result_out,
    pc_out,
    store_data_out,
    output MemRead_out,
    MemWrite_out,
    output [2:0] mem_size_out,
    output RegWrite_out,
    output [1:0] ResultSrc_out,
    output [4:0] rd_out
);
  reg [31:0] alu_result_reg, pc_reg, store_data_reg;
  reg MemRead_reg;
  reg [4:0] rd_reg;
  reg MemWrite_reg;
  reg [2:0] mem_size_reg;
  reg RegWrite_reg;
  reg [1:0] ResultSrc_reg;
  always @(posedge clk) begin
    if (reset || flush) begin
      alu_result_reg <= 32'b0;
      MemRead_reg <= 1'b0;
      MemWrite_reg <= 1'b0;
      mem_size_reg <= 3'b0;
      RegWrite_reg <= 1'b0;
      ResultSrc_reg <= 2'b0;
      pc_reg <= 32'b0;
      store_data_reg <= 32'b0;
      rd_reg <= 5'b0;
    end else begin
      alu_result_reg <= alu_result_in;
      MemRead_reg <= MemRead_in;
      MemWrite_reg <= MemWrite_in;
      mem_size_reg <= mem_size_in;
      RegWrite_reg <= RegWrite_in;
      ResultSrc_reg <= ResultSrc_in;
      pc_reg <= pc_in;
      store_data_reg <= store_data_in;
      rd_reg <= rd_in;
    end
  end
  assign rd_out         = rd_reg;
  assign alu_result_out = alu_result_reg;
  assign MemWrite_out   = MemWrite_reg;
  assign MemRead_out    = MemRead_reg;
  assign mem_size_out   = mem_size_reg;
  assign RegWrite_out   = RegWrite_reg;
  assign ResultSrc_out  = ResultSrc_reg;
  assign pc_out         = pc_reg;
  assign store_data_out = store_data_reg;
endmodule
