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
  integer cycles, max_cycles;
  integer image_words;
  integer instruction_count;
  integer load_count, store_count;
  integer branch_count, taken_branch_count;
  integer jump_count, alu_count;
  real cpi;
  reg  finished;
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
    // CPU BENCHMARK TESTING
    cycles = 0;
    max_cycles = 10000;
    finished = 1'b0;
    image_words = 0;
    instruction_count = 0;
    load_count = 0;
    store_count = 0;
    branch_count = 0;
    taken_branch_count = 0;
    jump_count = 0;
    alu_count = 0;

    if (!$value$plusargs("IMAGE=%s", image_file)) begin
      $display("[FAIL] Missing +IMAGE=<path>");
      $finish(1);
    end
    if (!$value$plusargs("WORDS=%d", image_words) || image_words < 1) begin
      $display("[FAIL] Missing or invalid +WORDS=<count>");
      $finish(1);
    end
    if ($value$plusargs("EXPECTED=%d", expected_value)) begin
    end
    $display("[ RUN  ] Assembly image: %s", image_file);
    $readmemh(image_file, dut.if_module.imem.mem, 0, image_words - 1);

    dut.mem.mem[0] = 32'b0;
    dut.mem.mem[1] = 32'b0;

    @(posedge clk);
    #1;
    reset = 1'b0;
    while (!finished && cycles < max_cycles) begin
      @(posedge clk);
      cycles = cycles + 1;
      instruction_count = instruction_count + 1;
      if (dut.mem_read) load_count = load_count + 1;
      else if (dut.mem_write) store_count = store_count + 1;
      else if (Branch) begin
        branch_count = branch_count + 1;
        if (zero) taken_branch_count = taken_branch_count + 1;
      end else if (Jump != 2'b00) jump_count = jump_count + 1;
      else alu_count = alu_count + 1;
      #1;
      if (dut.mem.mem[1] === 32'd1) finished = 1'b1;
    end
    #1;
    if (!finished) begin
      $display("[FAIL] Program timeout after %0d cycles", cycles);
      $finish(1);
    end
    if (dut.mem.mem[0] !== expected_value[31:0]) begin
      $display("[FAIL] Image result: expected mem[0]=%0d, got %h", expected_value, dut.mem.mem[0]);
      errors = errors + 1;
    end else begin
      $display("[PASS] Image result: mem[0]=%0d", dut.mem.mem[0]);
      $display("[PASS] Completion marker after %0d cycles", cycles);
    end

    if (instruction_count > 0) cpi = cycles * 1.0 / instruction_count;
    else cpi = 0.0;
    $display(
        "BENCHMARK_RESULT program=%s cycles=%0d instructions=%0d cpi=%0.2f loads=%0d stores=%0d branches=%0d taken_branches=%0d jumps=%0d alu=%0d result=%0d",
        image_file, cycles, instruction_count, cpi, load_count, store_count, branch_count,
        taken_branch_count, jump_count, alu_count, dut.mem.mem[0]);

    if (errors == 0) $display("[PASS] Assembly image execution");
    else $finish(1);
    $finish;
  end
endmodule
