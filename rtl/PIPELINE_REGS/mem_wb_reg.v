`timescale 1ns / 1ps
module mem_wb_reg (
    input clk,
    flush,
    reset,
    RegWrite_in,
    input [4:0] rd_in,
    input [1:0] ResultSrc_in,
    input [31:0] memory_read_data_in,
    alu_result_in,
    pc_in,
    output [31:0] alu_result_out,
    pc_out,
    memory_read_data_out,
    output RegWrite_out,
    output [1:0] ResultSrc_out,
    output [4:0] rd_out
);
  reg [31:0] alu_result_reg, pc_reg, memory_read_data_reg;
  reg [4:0] rd_reg;
  reg RegWrite_reg;
  reg [1:0] ResultSrc_reg;
  always @(posedge clk) begin
    if (reset || flush) begin
      alu_result_reg <= 32'b0;
      RegWrite_reg <= 1'b0;
      ResultSrc_reg <= 2'b0;
      pc_reg <= 32'b0;
      memory_read_data_reg <= 32'b0;
      rd_reg <= 5'b0;
    end else begin
      alu_result_reg <= alu_result_in;
      RegWrite_reg <= RegWrite_in;
      ResultSrc_reg <= ResultSrc_in;
      pc_reg <= pc_in;
      memory_read_data_reg <= memory_read_data_in;
      rd_reg <= rd_in;
    end
  end
  assign rd_out               = rd_reg;
  assign alu_result_out       = alu_result_reg;
  assign RegWrite_out         = RegWrite_reg;
  assign ResultSrc_out        = ResultSrc_reg;
  assign pc_out               = pc_reg;
  assign memory_read_data_out = memory_read_data_reg;
endmodule
