`timescale 1ns / 1ps

module immediate_generator_tb;
  integer errors = 0;
  // Objective: Test sign extension for different type of instructions.  
  // First instruction test:(R-type)
  // add $9(s1), $6(t1), $7(t2)
  localparam [31:0] add_instruction = {
    {7'b0}, {5'b00110}, {5'b00111}, {3'b000}, {5'b01001}, {7'b0110011}
  };
  // sub $9(s1), $6(t1), $7(t2)  
  localparam [31:0] sub_instruction = {
    {7'b0100000}, {5'b00110}, {5'b00111}, {3'b000}, {5'b01001}, {7'b0110011}
  };
  // Now lets do some immediate instructions  
  // addi $9(s1), $6(t1), 16
  localparam [31:0] addi_instruction = {
    {12'b000000010000}, {5'b00110}, {3'b000}, {5'b01001}, {7'b0010011}
  };
  // ori $9(s1), $6(t1), 16
  localparam [31:0] ori_instruction = {
    {12'b000000010000}, {5'b00110}, {3'b100}, {5'b01001}, {7'b0010011}
  };
  // Now lets do some S-type instructions(All the info is taken from the RISC-V
  // R32 subset information datasheet)
  // We are going to do sw since this one seems to be particularly tricky and
  // is because of the concartenated way of RISC-V format for that type so as to
  // test the immediate generation module. SO a great 12bit integer that fits
  // this is 011001010101 = 1621(completely random number...Lets forget
  // allignment here)
  // sw $6(t0), 1621($7(t1))
  localparam [31:0] sw_instruction = {
    {7'b0110010}, {5'b00110}, {5'b01001}, {3'b010}, {5'b10101}, {7'b0100011}
  };
  // Now lets do some branches  
  // The logic of the instruction is similar to before though now due to PC
  // relative adressing and allignment we need to sll by 2 bits.
  // lets create a simple example:
  // beq $t0(6th reg), $zero, LABEL(Now we assume that the LABEL with the PC
  // relative adressing is represented by the assembler with the 12 bit const 100000(=32)so 32 lines but we need to shift due to allignment so the expected result is 32*4 = 128bytes difference so the module should produce 128)  
  localparam [31:0] beq_instruction = {
    {7'b0000010}, {5'b00000}, {5'b00110}, {3'b000}, {5'b00000}, {7'b1100011}
  };
  // Now lets do some jumps and we are good to go 
  // So lets do the same and ahh. Just looked at the reference and the field
  // with the J instruction on RISC is scrammbled imm[20|10:1|11|19:12]...
  // So with the help of the AI(who would do that manually really) lets say we
  // want to do: 
  // jal LABEL
  // and lets choose a constant to be lets say the top bits of PC + 4*128(so just 128 will be saved)
  localparam [31:0] jal_instruction = 32'b00001000000000000000000011101111;
  // Now for the LUI lets just do a simple 
  // lui $t0, 16 => immediate = 15'b0 + b10000 => expected value = 2^(4+12)
  // = 2^24!
  localparam [31:0] lui = {{15'b0}, {5'b10000}, {5'b00110}, {7'b0110111}};
  // Now for the fun part!
  reg  [31:0] instruction_input;
  wire [31:0] immediate_output;
  immediate_generator dut (
      .instruction(instruction_input),
      .immediate  (immediate_output)
  );
  initial begin
    // Now check for each case 
    instruction_input = add_instruction;
    #1;
    if (immediate_output != 0) begin
      $display("FAILED R-Type: ADD");
      errors = errors + 1;
    end

    instruction_input = sub_instruction;
    #1;
    if (immediate_output != 0) begin
      $display("FAILED R-Type: SUB");
      errors = errors + 1;
    end

    instruction_input = addi_instruction;
    #1;
    if (immediate_output != $signed(16)) begin
      $display("FAILED I-Type: ADD");
      errors = errors + 1;
    end

    instruction_input = ori_instruction;
    #1;
    if (immediate_output != $signed(16)) begin
      $display("FAILED I-Type: OR");
      errors = errors + 1;
    end

    instruction_input = sw_instruction;
    #1;
    if (immediate_output != $signed(1621)) begin
      $display("FAILED S-Type: SW");
      errors = errors + 1;
    end

    instruction_input = beq_instruction;
    #1;
    if (immediate_output != 64) begin
      $display("FAILED B-Type: BEQ");
      errors = errors + 1;
    end

    instruction_input = jal_instruction;
    #1;
    if (immediate_output != 128) begin
      $display("FAILED J-Type: JAL");
      errors = errors + 1;
    end

    instruction_input = lui;
    #1;
    if (immediate_output != 65536) begin
      $display("FAILED U-Type: LUI");
      errors = errors + 1;
    end
    if (errors == 0) $display("ALL TESTS PASSED!");
    $finish;
  end

endmodule

