`timescale 1ns / 1ps

module control_unit_tb;

  reg  [31:0] instruction;
  wire        RegWrite;
  wire        MemRead;
  wire        MemWrite;
  wire        Branch;
  wire [1:0]  Jump;
  wire        Exception;
  wire [ 1:0] ResultSrc;
  wire [ 1:0] ALUSrc;
  wire [ 3:0] ALUop;

  // Instantiate the Control Unit module
  control_unit uut (
      .instruction(instruction),
      .RegWrite   (RegWrite),
      .MemRead    (MemRead),
      .MemWrite   (MemWrite),
      .Branch     (Branch),
      .Jump       (Jump),
      .Exception  (Exception),
      .ResultSrc  (ResultSrc),
      .ALUSrc     (ALUSrc),
      .ALUop      (ALUop)
  );

  // Helper task to check outputs against expected values
  task check_outputs;
    input [255:0] test_name;
    input exp_RegWrite, exp_MemRead, exp_MemWrite, exp_Branch;
    input [1:0] exp_Jump;
    input exp_Exception;
    input [1:0] exp_ResultSrc, exp_ALUSrc;
    input [3:0] exp_ALUop;
    begin
      #10;
      if (RegWrite === exp_RegWrite && MemRead === exp_MemRead &&
          MemWrite === exp_MemWrite && Branch === exp_Branch &&
          Jump === exp_Jump && Exception === exp_Exception &&
          ResultSrc === exp_ResultSrc && ALUSrc === exp_ALUSrc &&
          ALUop === exp_ALUop) begin
        $display("[PASS] %s", test_name);
      end else begin
        $display("[FAIL] %s", test_name);
        $display("  Got: RegW=%b MemR=%b MemW=%b Br=%b Jmp=%b Exc=%b ResSrc=%b ALUSrc=%b ALUop=%b",
                 RegWrite, MemRead, MemWrite, Branch, Jump, Exception, ResultSrc, ALUSrc, ALUop);
        $display("  Exp: RegW=%b MemR=%b MemW=%b Br=%b Jmp=%b Exc=%b ResSrc=%b ALUSrc=%b ALUop=%b",
                 exp_RegWrite, exp_MemRead, exp_MemWrite, exp_Branch, exp_Jump, exp_Exception,
                 exp_ResultSrc, exp_ALUSrc, exp_ALUop);
      end
    end
  endtask

  initial begin
    $display("--- Starting Control Unit Verification ---");

    // 1. R-Type ADD (funct3: 000, funct7: 0000000)
    instruction = 32'h00000033;
    check_outputs("R-Type ADD", 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 2'b00, 2'b00, 4'b0000);

    // 2. R-Type SUB (funct3: 000, funct7: 0100000)
    instruction = 32'h40000033;
    check_outputs("R-Type SUB", 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 2'b00, 2'b00, 4'b0001);

    // 3. I-Type ADDI (funct3: 000)
    instruction = 32'h00000013;
    check_outputs("I-Type ADDI", 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 2'b00, 2'b01, 4'b0000);

    // 4. Load LW
    instruction = 32'h00000003;
    check_outputs("I-Type LW", 1'b1, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 2'b01, 2'b01, 4'b0000);

    // 5. Store SW
    instruction = 32'h00000023;
    check_outputs("S-Type SW", 1'b0, 1'b0, 1'b1, 1'b0, 2'b00, 1'b0, 2'b00, 2'b01, 4'b0000);

    // 6. Branch BEQ
    instruction = 32'h00000063;
    check_outputs("B-Type BEQ", 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 1'b0, 2'b00, 2'b00, 4'b0001);

    // 7. JAL
    instruction = 32'h0000006f;
    check_outputs("J-Type JAL", 1'b1, 1'b0, 1'b0, 1'b0, 2'b01, 1'b0, 2'b10, 2'b01, 4'b0000);

    // 8. JALR
    instruction = 32'h00000067;
    check_outputs("I-Type JALR", 1'b1, 1'b0, 1'b0, 1'b0, 2'b10, 1'b0, 2'b10, 2'b01, 4'b0000);

    // 9. ECALL / System Exception
    instruction = 32'h00000073;
    check_outputs("SYSTEM ECALL", 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b1, 2'b00, 2'b00, 4'b0000);

    $display("--- Verification Complete ---");
    $finish;
  end

endmodule
