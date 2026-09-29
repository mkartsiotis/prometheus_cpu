`timescale 1ns / 1ps
// forward_x encoding: 00 = ID/EX register value, 01 = EX/MEM result, 10 = MEM/WB write-back value
module forwarding_unit (
    input ex_mem_RegWrite,
    mem_wb_RegWrite,
    input [4:0] ex_mem_rd,
    mem_wb_rd,
    id_ex_rs1,
    id_ex_rs2,
    output reg [1:0] forward_a,
    forward_b
);
  always @(*) begin
    if (ex_mem_RegWrite && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs1) forward_a = 2'b01;
    else if (mem_wb_RegWrite && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs1) forward_a = 2'b10;
    else forward_a = 2'b00;
    if (ex_mem_RegWrite && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs2) forward_b = 2'b01;
    else if (mem_wb_RegWrite && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs2) forward_b = 2'b10;
    else forward_b = 2'b00;
  end
endmodule
