`timescale 1ns / 1ps

module cpu_image_tb;
  reg clk;
  reg reset;
  reg [1023:0] image_file;
  integer expected_value;
  integer cycle_limit;
  integer errors;

  wire [31:0] pc;
  wire [31:0] reg1_data;
  wire [31:0] reg2_data;
  wire [31:0] instruction_out;
  wire [31:0] immediate;
  wire [31:0] result;
  wire RegWrite;
  wire MemRead;
  wire MemWrite;
  wire Branch;
  wire [1:0] Jump;
  wire Exception;
  wire cout;
  wire zero;
  wire overflow;
  wire [1:0] ResultSrc;
  wire [1:0] ALUSrc;
  wire [3:0] ALUop;

  cpu dut (
      .clk(clk),
      .reset(reset),
      .pc(pc),
      .reg1_data(reg1_data),
      .reg2_data(reg2_data),
      .instruction_out(instruction_out),
      .immediate(immediate),
      .result(result),
      .RegWrite(RegWrite),
      .MemRead(MemRead),
      .MemWrite(MemWrite),
      .Branch(Branch),
      .Jump(Jump),
      .Exception(Exception),
      .cout(cout),
      .zero(zero),
      .overflow(overflow),
      .ResultSrc(ResultSrc),
      .ALUSrc(ALUSrc),
      .ALUop(ALUop)
  );

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
    errors = 0;
    expected_value = 0;
    cycle_limit = 20;
    reset = 1'b1;

    if (!$value$plusargs("IMAGE=%s", image_file)) begin
      $display("[FAIL] Missing +IMAGE=<path>");
      $finish(1);
    end
    if ($value$plusargs("EXPECTED=%d", expected_value)) begin end
    if ($value$plusargs("CYCLES=%d", cycle_limit)) begin end

    $display("[ RUN  ] Assembly image: %s", image_file);
    $readmemh(image_file, dut.if_module.imem.mem);

    @(posedge clk);
    #1;
    reset = 1'b0;
    repeat (cycle_limit) @(posedge clk);
    #1;

    if (dut.mem.mem[0] !== expected_value[31:0]) begin
      $display("[FAIL] Image result: expected mem[0]=%0d, got %h",
               expected_value, dut.mem.mem[0]);
      errors = errors + 1;
    end else begin
      $display("[PASS] Image result: mem[0]=%0d", dut.mem.mem[0]);
    end

    if (errors == 0)
      $display("[PASS] Assembly image execution");
    $finish;
  end
endmodule
