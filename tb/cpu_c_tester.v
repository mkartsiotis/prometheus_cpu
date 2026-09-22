`timescale 1ns / 1ps

module cpu_c_tester;
  reg clk;
  reg reset;
  reg [1023:0] instruction_image_file;  // Stores the path of the instruction 
  reg [1023:0] data_image_file;  // Stores the path of the image 
  integer instruction_words;  // Number of words needed to be loaded the instruction memory
  integer data_words;  // Number of words needed to be stored in the data memory  
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
    // Read arguments and store them to variables(that will be used later for
    // readmh)
    instruction_words = 0;
    data_words = 0;

    if (!$value$plusargs("INSTRUCTION_IMAGE=%s", instruction_image_file)) begin
      $display("[FAIL] Missing +INSTRUCTION_IMAGE=<path>");
      $finish(1);
    end

    if (!$value$plusargs("DATA_IMAGE=%s", data_image_file)) begin
      $display("[FAIL] Missing +DATA_IMAGE=<path>");
      $finish(1);
    end

    if (!$value$plusargs("INSTRUCTION_WORDS=%d", instruction_words) || instruction_words < 1) begin
      $display("[FAIL] Missing or invalid +INSTRUCTION_WORDS=<count>");
      $finish(1);
    end

    if (!$value$plusargs("DATA_WORDS=%d", data_words) || data_words < 0) begin
      $display("[FAIL] Missing or invalid +DATA_WORDS=<count>");
      $finish(1);
    end

    $display("[PASS] Image arguments received");
    $display("        instruction image: %s", instruction_image_file);
    $display("        instruction words: %0d", instruction_words);
    $display("        data image:        %s", data_image_file);
    $display("        data words:        %0d", data_words);

    $finish;
  end
endmodule
