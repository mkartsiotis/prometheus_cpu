`timescale 1ns / 1ps

module cpu_tb;
  reg clk;
  reg reset;

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
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    // addi x1, x0, 5
    dut.if_module.imem.mem[0] = 32'h0050_0093;
    // addi x2, x0, -3
    dut.if_module.imem.mem[1] = 32'hFFD0_0113;
    // add x3, x1, x2
    dut.if_module.imem.mem[2] = 32'h0020_81B3;
    // lui x4, 0x12345
    dut.if_module.imem.mem[3] = 32'h1234_5237;
    // auipc x5, 0x1
    dut.if_module.imem.mem[4] = 32'h0000_1297;
    // sw x1, 0(x0)
    dut.if_module.imem.mem[5] = 32'h0010_2023;
    // lw x6, 0(x0)
    dut.if_module.imem.mem[6] = 32'h0000_2303;

    dut.register_file.regfile[1] = 32'd10;
    dut.register_file.regfile[2] = 32'd20;

    reset = 1;

    @(posedge clk);
    #1;
    if (pc !== 32'd0)
      $error("RESET/PC FAIL: expected PC 0, got %h", pc);
    if (instruction_out !== 32'h0050_0093)
      $error("FETCH 0 FAIL: got %h", instruction_out);
    if (immediate !== 32'd5)
      $error("ADDI 5 IMMEDIATE FAIL: got %h", immediate);
    if (RegWrite !== 1'b0 || ALUSrc !== 2'b01 || ALUop !== 4'b0000)
      $error("ADDI CONTROL FAIL: RegWrite=%b ALUSrc=%b ALUop=%b",
             RegWrite, ALUSrc, ALUop);

    reset = 0;

    @(posedge clk);
    #1;
    if (pc !== 32'd4)
      $error("PC 4 FAIL: got %h", pc);
    if (instruction_out !== 32'hFFD0_0113)
      $error("FETCH 1 FAIL: got %h", instruction_out);
    if (immediate !== 32'hFFFF_FFFD)
      $error("ADDI -3 IMMEDIATE FAIL: got %h", immediate);
    if (result !== 32'hFFFF_FFFD || zero !== 1'b0)
      $error("ADDI ALU FAIL: result=%h zero=%b", result, zero);

    @(posedge clk);
    #1;
    if (pc !== 32'd8)
      $error("PC 8 FAIL: got %h", pc);
    if (instruction_out !== 32'h0020_81B3)
      $error("FETCH 2 FAIL: got %h", instruction_out);
    if (reg1_data !== 32'd5 || reg2_data !== 32'hFFFF_FFFD)
      $error("REGISTER READ FAIL: rs1=%h rs2=%h", reg1_data, reg2_data);
    if (result !== 32'd2 || zero !== 1'b0)
      $error("ADD ALU FAIL: expected 2, result=%h zero=%b", result, zero);
    if (RegWrite !== 1'b1 || ALUSrc !== 2'b00 || ALUop !== 4'b0000)
      $error("ADD CONTROL FAIL: RegWrite=%b ALUSrc=%b ALUop=%b",
             RegWrite, ALUSrc, ALUop);

    @(posedge clk);
    #1;
    if (pc !== 32'd12)
      $error("PC 12 FAIL: got %h", pc);
    if (instruction_out !== 32'h1234_5237)
      $error("LUI FETCH FAIL: got %h", instruction_out);
    if (immediate !== 32'h1234_5000)
      $error("LUI IMMEDIATE FAIL: got %h", immediate);
    if (result !== 32'h1234_5000)
      $error("LUI RESULT FAIL: got %h", result);
    if (ALUSrc !== 2'b01 || ALUop !== 4'b1011 || RegWrite !== 1'b1)
      $error("LUI CONTROL FAIL: RegWrite=%b ALUSrc=%b ALUop=%b",
             RegWrite, ALUSrc, ALUop);

    @(posedge clk);
    #1;
    if (dut.register_file.regfile[4] !== 32'h1234_5000)
      $error("LUI WRITE-BACK FAIL: x4=%h", dut.register_file.regfile[4]);
    if (pc !== 32'd16)
      $error("PC 16 FAIL: got %h", pc);
    if (instruction_out !== 32'h0000_1297)
      $error("AUIPC FETCH FAIL: got %h", instruction_out);
    if (immediate !== 32'h0000_1000)
      $error("AUIPC IMMEDIATE FAIL: got %h", immediate);
    if (result !== 32'h0000_1010)
      $error("AUIPC RESULT FAIL: got %h", result);
    if (ALUSrc !== 2'b01 || ALUop !== 4'b0000 || RegWrite !== 1'b1)
      $error("AUIPC CONTROL FAIL: RegWrite=%b ALUSrc=%b ALUop=%b",
             RegWrite, ALUSrc, ALUop);

    @(posedge clk);
    #1;
    if (dut.register_file.regfile[3] !== 32'd2)
      $error("ADD WRITE-BACK FAIL: x3=%h", dut.register_file.regfile[3]);
    if (dut.register_file.regfile[5] !== 32'h0000_1010)
      $error("AUIPC WRITE-BACK FAIL: x5=%h", dut.register_file.regfile[5]);

    if (pc !== 32'd20 || instruction_out !== 32'h0010_2023)
      $error("STORE FETCH FAIL: PC=%h instruction=%h", pc, instruction_out);
    if (dut.mem_write !== 1'b1 || dut.mem_read !== 1'b0)
      $error("STORE CONTROL FAIL: MemWrite=%b MemRead=%b",
             dut.mem_write, dut.mem_read);

    @(posedge clk);
    #1;
    if (dut.mem.mem[0] !== 32'd5)
      $error("STORE DATA FAIL: mem[0]=%h", dut.mem.mem[0]);
    if (pc !== 32'd24 || instruction_out !== 32'h0000_2303)
      $error("LOAD FETCH FAIL: PC=%h instruction=%h", pc, instruction_out);
    if (dut.mem_read !== 1'b1 || dut.mem_write !== 1'b0)
      $error("LOAD CONTROL FAIL: MemRead=%b MemWrite=%b",
             dut.mem_read, dut.mem_write);

    @(posedge clk);
    #1;
    if (dut.register_file.regfile[6] !== 32'd5)
      $error("LOAD WRITE-BACK FAIL: x6=%h", dut.register_file.regfile[6]);

    $display("[PASS] Arithmetic, upper-immediate, and memory integration");

    // Control-flow integration: taken BEQ skips PC+4 instruction.
    dut.if_module.imem.mem[0] = 32'h0050_0093;  // addi x1, x0, 5
    dut.if_module.imem.mem[1] = 32'h0050_0113;  // addi x2, x0, 5
    dut.if_module.imem.mem[2] = 32'h0020_8463;  // beq x1, x2, +8
    dut.if_module.imem.mem[3] = 32'h0630_0193;  // skipped: addi x3, x0, 99
    dut.if_module.imem.mem[4] = 32'h0070_0193;  // addi x3, x0, 7
    reset = 1;
    @(posedge clk);
    #1;
    reset = 0;
    repeat (3) @(posedge clk);
    #1;
    if (pc !== 32'd16 || instruction_out !== 32'h0070_0193 ||
        dut.register_file.regfile[1] !== 32'd5 ||
        dut.register_file.regfile[2] !== 32'd5)
      $error("BEQ TAKEN FAIL: PC=%h instruction=%h x1=%h x2=%h",
             pc, instruction_out, dut.register_file.regfile[1],
             dut.register_file.regfile[2]);
    else
      $display("[PASS] Taken BEQ redirects to target");

    // JAL writes PC+4 and redirects to its target.
    dut.if_module.imem.mem[5] = 32'h0080_03EF;  // jal x7, +8 (PC 20 -> 28)
    dut.if_module.imem.mem[6] = 32'h0630_0213;  // skipped: addi x4, x0, 99
    dut.if_module.imem.mem[7] = 32'h00B0_0213;  // addi x4, x0, 11
    repeat (2) @(posedge clk);
    #1;
    if (pc !== 32'd28 || dut.register_file.regfile[7] !== 32'd24)
      $error("JAL FAIL: PC=%h x7=%h", pc, dut.register_file.regfile[7]);
    else
      $display("[PASS] JAL redirects and writes link address");

    // JALR uses rs1+immediate, clears bit 0, and writes PC+4.
    dut.if_module.imem.mem[0] = 32'h0280_0093;  // addi x1, x0, 40
    dut.if_module.imem.mem[1] = 32'h0000_8467;  // jalr x8, x1, 0
    dut.if_module.imem.mem[10] = 32'h04D0_0493; // addi x9, x0, 77
    reset = 1;
    @(posedge clk);
    #1;
    reset = 0;
    repeat (2) @(posedge clk);
    #1;
    if (pc !== 32'd40 || dut.register_file.regfile[8] !== 32'd8)
      $error("JALR FAIL: PC=%h x8=%h", pc, dut.register_file.regfile[8]);
    else
      $display("[PASS] JALR redirects and writes link address");

    $display("CPU INTEGRATION REGRESSION COMPLETED");
    $finish;
  end
endmodule
