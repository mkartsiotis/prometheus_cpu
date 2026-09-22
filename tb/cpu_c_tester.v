`timescale 1ns / 1ps

module cpu_c_tester;
  // Define the restrained words(for result verification and program
  // termination)
  localparam integer DATA_MEMORY_WORDS = 4096;
  localparam integer DATA_IMAGE_BASE_WORD = 2;
  reg clk;
  reg reset;
  reg [1023:0] instruction_image_file;  // Stores the path of the instruction 
  reg [1023:0] data_image_file;  // Stores the path of the image 
  integer instruction_words;  // Number of words needed to be loaded the instruction memory
  integer data_words;  // Number of words needed to be stored in the data memory  
  integer index;  // index used for zeroing data memory
  // termination logic
  integer cycles;  // number of elapsed cycle
  integer max_cycles;  // Number of cycles after which CPU stalls
  reg finished;  // Finish flag

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
    // Variable initialization
    reset = 1'b1;  // RESET kept at 1 while loading takes place!
    cycles = 0;
    max_cycles = 10000;
    finished = 1'b0;
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

    // Memory starting state:
    for (index = 0; index < DATA_MEMORY_WORDS; index = index + 1) begin
      dut.mem.mem[index] = 32'b0;
    end
    // Load the instruction image
    $readmemh(instruction_image_file, dut.if_module.imem.mem, 0, instruction_words - 1);
    // Load data image
    if (data_words > 0) begin
      $readmemh(data_image_file, dut.mem.mem, DATA_IMAGE_BASE_WORD,
                DATA_IMAGE_BASE_WORD + data_words - 1);
    end


    $display("[PASS] Instruction memory initialized");
    $display("[PASS] Data memory initialized");
    $display("        result mailbox: dut.mem.mem[0]");
    $display("        status mailbox: dut.mem.mem[1]");
    $display("        data image base: dut.mem.mem[%0d]", DATA_IMAGE_BASE_WORD);
    // Release RESET and start execution
    @(posedge clk);
    #1;
    reset = 1'b0;
    // Cycle count logic
    while (!finished && cycles < max_cycles) begin
      @(posedge clk);
      cycles = cycles + 1;

      #1;

      if (dut.mem.mem[1] === 32'd1 || dut.mem.mem[1] === 32'd2) begin
        finished = 1'b1;  // So finished is essentially drawn from reg 1...(status)
      end
    end
    // Based on the cycles termiate successfully or not the simulation
    if (!finished) begin
      $display("[FAIL] Program timeout after %0d cycles", cycles);
      $finish(1);
    end

    if (dut.mem.mem[1] === 32'd2) begin
      $display("[FAIL] Program reported runtime failure");
      $display("PROGRAM_RESULT result=%0d status=%0d cycles=%0d", dut.mem.mem[0], dut.mem.mem[1],
               cycles);
      $finish(1);
    end

    $display("[PASS] Program completed");
    $display("PROGRAM_RESULT result=%0d status=%0d cycles=%0d", dut.mem.mem[0], dut.mem.mem[1],
             cycles);
    $finish(0);
  end
endmodule
