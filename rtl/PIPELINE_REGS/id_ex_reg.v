`timescale 1ns / 1ps

module id_ex_reg (
    input        clk,
    input        reset,
    input        flush,         // insert a bubble into EX
    // Data from ID
    input [31:0] pc_in,
    input [31:0] reg1_data_in,
    input [31:0] reg2_data_in,
    input [31:0] immediate_in,
    // Register identifiers
    input [ 4:0] rs1_in,
    input [ 4:0] rs2_in,
    input [ 4:0] rd_in,
    // Control signals
    input        RegWrite_in,
    input        MemRead_in,
    input        MemWrite_in,
    input        Branch_in,
    input [ 1:0] Jump_in,
    input        Exception_in,
    input        AluA_Src_in,
    input [ 1:0] ALUSrc_in,
    input [ 1:0] ResultSrc_in,
    input [ 3:0] ALUop_in,
    input [ 2:0] mem_size_in,

    // Corresponding output regs to EX
    // Data from ID
    output [31:0] pc_out,
    output [31:0] reg1_data_out,
    output [31:0] reg2_data_out,
    output [31:0] immediate_out,
    // Register identifiers
    output [ 4:0] rs1_out,
    output [ 4:0] rs2_out,
    output [ 4:0] rd_out,
    // Control signals
    output        RegWrite_out,
    output        MemRead_out,
    output        MemWrite_out,
    output        Branch_out,
    output [ 1:0] Jump_out,
    output        Exception_out,
    output        AluA_Src_out,
    output [ 1:0] ALUSrc_out,
    output [ 1:0] ResultSrc_out,
    output [ 3:0] ALUop_out,
    output [ 2:0] mem_size_out
);
  reg [31:0] pc_reg;
  reg [31:0] reg1_data_reg;
  reg [31:0] reg2_data_reg;
  reg [31:0] immediate_reg;
  // Register identifiers
  reg [ 4:0] rs1_reg;
  reg [ 4:0] rs2_reg;
  reg [ 4:0] rd_reg;
  // Control signals
  reg        RegWrite_reg;
  reg        MemRead_reg;
  reg        MemWrite_reg;
  reg        Branch_reg;
  reg [ 1:0] Jump_reg;
  reg        Exception_reg;
  reg        AluA_Src_reg;
  reg [ 1:0] ALUSrc_reg;
  reg [ 1:0] ResultSrc_reg;
  reg [ 3:0] ALUop_reg;
  reg [ 2:0] mem_size_reg;

  always @(posedge clk) begin
    if (reset || flush) begin
      pc_reg <= 32'b0;
      reg1_data_reg <= 32'b0;
      reg2_data_reg <= 32'b0;
      immediate_reg <= 32'b0;
      // Register identifiers
      rs1_reg <= 5'b0;
      rs2_reg <= 5'b0;
      rd_reg <= 5'b0;
      // Control signals
      RegWrite_reg <= 1'b0;
      MemRead_reg <= 1'b0;
      MemWrite_reg <= 1'b0;
      Branch_reg <= 1'b0;
      Jump_reg <= 2'b0;
      Exception_reg <= 1'b0;
      AluA_Src_reg <= 1'b0;
      ALUSrc_reg <= 2'b0;
      ResultSrc_reg <= 2'b0;
      ALUop_reg <= 4'b0;
      mem_size_reg <= 3'b0;
    end else begin
      pc_reg <= pc_in;
      reg1_data_reg <= reg1_data_in;
      reg2_data_reg <= reg2_data_in;
      immediate_reg <= immediate_in;
      // Register identifiers
      rs1_reg <= rs1_in;
      rs2_reg <= rs2_in;
      rd_reg <= rd_in;
      // Control signals
      RegWrite_reg <= RegWrite_in;
      MemRead_reg <= MemRead_in;
      MemWrite_reg <= MemWrite_in;
      Branch_reg <= Branch_in;
      Jump_reg <= Jump_in;
      Exception_reg <= Exception_in;
      AluA_Src_reg <= AluA_Src_in;
      ALUSrc_reg <= ALUSrc_in;
      ResultSrc_reg <= ResultSrc_in;
      ALUop_reg <= ALUop_in;
      mem_size_reg <= mem_size_in;
    end
  end

  assign pc_out        = pc_reg;
  assign reg1_data_out = reg1_data_reg;
  assign reg2_data_out = reg2_data_reg;
  assign immediate_out = immediate_reg;
  // Register identifiers
  assign rs1_out       = rs1_reg;
  assign rs2_out       = rs2_reg;
  assign rd_out        = rd_reg;
  // Control signals
  assign RegWrite_out  = RegWrite_reg;
  assign MemRead_out   = MemRead_reg;
  assign MemWrite_out  = MemWrite_reg;
  assign Branch_out    = Branch_reg;
  assign Jump_out      = Jump_reg;
  assign Exception_out = Exception_reg;
  assign AluA_Src_out  = AluA_Src_reg;
  assign ALUSrc_out    = ALUSrc_reg;
  assign ResultSrc_out = ResultSrc_reg;
  assign ALUop_out     = ALUop_reg;
  assign mem_size_out  = mem_size_reg;
endmodule
