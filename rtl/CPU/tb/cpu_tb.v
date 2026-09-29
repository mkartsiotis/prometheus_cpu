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

  integer errors = 0;
  integer i;

  task check_reg(input integer idx, input [31:0] expected);
    begin
      if (dut.register_file.regfile[idx] !== expected) begin
        $display("[FAIL] x%0d: expected %h, got %h", idx, expected, dut.register_file.regfile[idx]);
        errors = errors + 1;
      end
    end
  endtask

  task check_mem(input integer idx, input [31:0] expected);
    begin
      if (dut.mem.mem[idx] !== expected) begin
        $display("[FAIL] mem[%0d]: expected %h, got %h", idx, expected, dut.mem.mem[idx]);
        errors = errors + 1;
      end
    end
  endtask

  // Fill instruction memory with NOPs, clear registers and data memory, then reset.
  task clear_state;
    begin
      for (i = 0; i < 64; i = i + 1) dut.if_module.imem.mem[i] = 32'h0000_0013;
      for (i = 0; i < 32; i = i + 1) dut.register_file.regfile[i] = 32'b0;
      for (i = 0; i < 8; i = i + 1) dut.mem.mem[i] = 32'b0;
    end
  endtask

  // The pipeline needs 4 cycles to fill plus stalls/flushes, so run for a fixed budget.
  task run(input integer cycles);
    begin
      reset = 1;
      @(posedge clk);
      #1;
      reset = 0;
      repeat (cycles) @(posedge clk);
      #1;
    end
  endtask

  initial begin
    // Test 1: data hazards (forwarding), load-use stall, store-data forwarding
    clear_state;
    dut.if_module.imem.mem[0] = 32'h00500093;
    dut.if_module.imem.mem[1] = 32'hffd00113;
    dut.if_module.imem.mem[2] = 32'h002081b3;
    dut.if_module.imem.mem[3] = 32'h00318233;
    dut.if_module.imem.mem[4] = 32'h123452b7;
    dut.if_module.imem.mem[5] = 32'h00001317;
    dut.if_module.imem.mem[6] = 32'h00102023;
    dut.if_module.imem.mem[7] = 32'h00002383;
    dut.if_module.imem.mem[8] = 32'h00738433;
    dut.if_module.imem.mem[9] = 32'h00802223;
    dut.if_module.imem.mem[10] = 32'h00402483;
    dut.if_module.imem.mem[11] = 32'h00902423;
    run(30);
    check_reg(1, 32'd5);
    check_reg(2, 32'hFFFF_FFFD);
    check_reg(3, 32'd2);            // EX/MEM + MEM/WB forwarding
    check_reg(4, 32'd4);            // back-to-back RAW
    check_reg(5, 32'h1234_5000);    // LUI
    check_reg(6, 32'h0000_1014);    // AUIPC at PC=0x14
    check_reg(7, 32'd5);            // LW
    check_reg(8, 32'd10);           // load-use stall then add
    check_reg(9, 32'd10);           // SW then LW
    check_mem(0, 32'd5);
    check_mem(1, 32'd10);           // store data forwarded from ALU result
    check_mem(2, 32'd10);           // store data forwarded from load
    if (errors == 0) $display("[PASS] Data hazards: forwarding, load-use, store data");

    // Test 2: branches (all six types), JAL, JALR, wrong-path flush
    clear_state;
    dut.if_module.imem.mem[0] = 32'h00500093;
    dut.if_module.imem.mem[1] = 32'h00500113;
    dut.if_module.imem.mem[2] = 32'h00208663;
    dut.if_module.imem.mem[3] = 32'h06300193;
    dut.if_module.imem.mem[4] = 32'h06200193;
    dut.if_module.imem.mem[5] = 32'h00700193;
    dut.if_module.imem.mem[6] = 32'h06209463;
    dut.if_module.imem.mem[7] = 32'h00100213;
    dut.if_module.imem.mem[8] = 32'h0620c063;
    dut.if_module.imem.mem[9] = 32'h0020d463;
    dut.if_module.imem.mem[10] = 32'h06300213;
    dut.if_module.imem.mem[11] = 32'hfff00293;
    dut.if_module.imem.mem[12] = 32'h0050e463;
    dut.if_module.imem.mem[13] = 32'h06300313;
    dut.if_module.imem.mem[14] = 32'h0012f463;
    dut.if_module.imem.mem[15] = 32'h06200313;
    dut.if_module.imem.mem[16] = 32'h00330313;
    dut.if_module.imem.mem[17] = 32'h008003ef;
    dut.if_module.imem.mem[18] = 32'h06300413;
    dut.if_module.imem.mem[19] = 32'h07c00493;
    dut.if_module.imem.mem[20] = 32'h00048567;
    dut.if_module.imem.mem[21] = 32'h06200413;
    dut.if_module.imem.mem[22] = 32'h06100413;
    dut.if_module.imem.mem[23] = 32'h06000413;
    dut.if_module.imem.mem[24] = 32'h05f00413;
    dut.if_module.imem.mem[25] = 32'h05e00413;
    dut.if_module.imem.mem[26] = 32'h05d00413;
    dut.if_module.imem.mem[27] = 32'h05c00413;
    dut.if_module.imem.mem[28] = 32'h05b00413;
    dut.if_module.imem.mem[29] = 32'h05a00413;
    dut.if_module.imem.mem[30] = 32'h05900413;
    dut.if_module.imem.mem[31] = 32'h02a00593;
    dut.if_module.imem.mem[32] = 32'h00100613;
    run(60);
    check_reg(3, 32'd7);            // taken BEQ flushed both wrong-path instructions
    check_reg(4, 32'd1);            // BNE/BLT not taken, BGE taken
    check_reg(5, 32'hFFFF_FFFF);
    check_reg(6, 32'd3);            // BLTU and BGEU taken
    check_reg(7, 32'h0000_0048);    // JAL link
    check_reg(8, 32'd0);            // JAL/JALR wrong-path instructions never commit
    check_reg(10, 32'h0000_0054);   // JALR link
    check_reg(11, 32'd42);          // JALR target reached
    check_reg(12, 32'd1);
    if (errors == 0) $display("[PASS] Control hazards: branches, JAL, JALR, flush");

    // Test 3: byte / halfword memory access
    clear_state;
    dut.if_module.imem.mem[0] = 32'hfff00093;
    dut.if_module.imem.mem[1] = 32'h00102023;
    dut.if_module.imem.mem[2] = 32'h000000a3;
    dut.if_module.imem.mem[3] = 32'h00000103;
    dut.if_module.imem.mem[4] = 32'h00001183;
    dut.if_module.imem.mem[5] = 32'h00004203;
    dut.if_module.imem.mem[6] = 32'h00205283;
    dut.if_module.imem.mem[7] = 32'h00002303;
    dut.if_module.imem.mem[8] = 32'h12300393;
    dut.if_module.imem.mem[9] = 32'h00701223;
    dut.if_module.imem.mem[10] = 32'h00402403;
    run(30);
    check_reg(2, 32'hFFFF_FFFF);    // LB sign-extends 0xFF
    check_reg(3, 32'h0000_00FF);    // LH of 0x00FF
    check_reg(4, 32'h0000_00FF);    // LBU
    check_reg(5, 32'h0000_FFFF);    // LHU
    check_reg(6, 32'hFFFF_00FF);
    check_reg(8, 32'h0000_0123);
    if (errors == 0) $display("[PASS] Byte and halfword memory access");

    if (errors == 0) $display("[PASS] CPU integration regression completed");
    else $display("[FAIL] CPU integration regression: %0d errors", errors);
    $finish;
  end
endmodule
