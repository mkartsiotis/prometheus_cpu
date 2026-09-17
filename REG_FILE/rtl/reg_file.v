`timescale 1ns / 1ps

module reg_file #(
    parameter BIT_LENGTH = 32,
    parameter REG_NUMBER = 32
) (
    input clk,
    input [BIT_LENGTH-1:0] wb_data,
    input wb_enable,
    input [($clog2(REG_NUMBER) - 1):0] reg1_sel,
    reg2_sel,
    reg3_sel,
    output [BIT_LENGTH-1:0] reg1_data,
    reg2_data
);
  reg [(BIT_LENGTH - 1):0] regfile[1:(REG_NUMBER - 1)];
  assign reg1_data = (reg1_sel == 0) ? 0 : regfile[reg1_sel];
  assign reg2_data = (reg2_sel == 0) ? 0 : regfile[reg2_sel];
  always @(posedge clk) begin
    if (wb_enable == 1 && reg3_sel != 0) regfile[reg3_sel] <= wb_data;
  end
endmodule
