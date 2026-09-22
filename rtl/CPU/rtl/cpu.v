`timescale 1ns / 1ps

module cpu #(
    parameter DATA_ADDRESS_WIDTH = 12
) (
    input clk,
    reset,
    output [31:0] pc,
    reg1_data,
    reg2_data,
    instruction_out,
    immediate,
    result,
    output RegWrite,
    MemRead,
    MemWrite,
    Branch,
    Exception,
    cout,
    zero,
    overflow,
    mem_read,
    mem_write,
    output [1:0] ResultSrc,
    ALUSrc,
    Jump,
    output [3:0] ALUop
);
  wire [31:0] fetched_instruction;
  wire [31:0] immediate_wire;
  wire zero_wire, reg_write_wire, wb_enable_wire, AluA_Src_wire, Branch_wire;
  wire [3:0] ALUop_wire;
  wire [1:0] ResultSrc_wire, ALUSrc_wire, Jump_wire;
  wire [31:0] reg1_data_wire, reg2_data_wire;
  wire [31:0] alu_second_input, alu_first_input, alu_result_wire;
  wire [31:0] pc_wire, next_pc_wire;
  wire [31:0] wb_data_wire;
  reg [31:0] alu_second_input_reg, alu_first_input_reg, wb_reg, next_pc;
  wire [31:0] mem_address_wire, mem_write_data_wire, mem_output_data_wire;
  wire mem_read_wire, mem_write_wire;
  memory #(
      .ADDRESS_WIDTH(DATA_ADDRESS_WIDTH)
  ) mem (
      .clk(clk),
      .address(mem_address_wire),
      .write_data(mem_write_data_wire),
      .mem_write(mem_write_wire),
      .mem_read(mem_read_wire),
      .read_data(mem_output_data_wire)
  );
  instruction_fetch if_module (
      .clk(clk),
      .reset(reset),
      .pc_input(next_pc_wire),
      .instruction_out(fetched_instruction),
      .pc_out(pc_wire)
  );
  immediate_generator imm_module (
      .instruction(fetched_instruction),
      .immediate  (immediate_wire)
  );
  control_unit cu (
      .instruction(fetched_instruction),
      .MemRead(mem_read_wire),
      .MemWrite(mem_write_wire),
      .Branch(Branch_wire),
      .Jump(Jump_wire),
      .Exception(Exception),
      .AluA_Src(AluA_Src_wire),
      .ResultSrc(ResultSrc_wire),
      .ALUSrc(ALUSrc_wire),
      .ALUop(ALUop_wire),
      .RegWrite(reg_write_wire)
  );
  reg_file register_file (
      .clk(clk),
      .wb_data(wb_data_wire),
      .wb_enable(wb_enable_wire),
      .reg1_sel(fetched_instruction[19:15]),
      .reg2_sel(fetched_instruction[24:20]),
      .reg3_sel(fetched_instruction[11:7]),
      .reg1_data(reg1_data_wire),
      .reg2_data(reg2_data_wire)
  );
  alu alu_module (
      .x(alu_first_input),
      .y(alu_second_input),
      .opcode(ALUop_wire),
      .result(alu_result_wire),
      .zero(zero_wire),
      .cout(cout),
      .overflow(overflow)
  );
  wire should_branch;
  wire [31:0] pc_plus_4, branch_target, jal_target, jalr_target;
  reg branch_condition;

  always @(*) begin
    case (fetched_instruction[14:12])
      3'b000: branch_condition = zero_wire;                    // BEQ
      3'b001: branch_condition = ~zero_wire;                   // BNE
      3'b100: branch_condition = $signed(reg1_data_wire) < $signed(reg2_data_wire); // BLT
      3'b101: branch_condition = $signed(reg1_data_wire) >= $signed(reg2_data_wire); // BGE
      3'b110: branch_condition = reg1_data_wire < reg2_data_wire; // BLTU
      3'b111: branch_condition = reg1_data_wire >= reg2_data_wire; // BGEU
      default: branch_condition = 1'b0;
    endcase
  end

  assign should_branch = Branch_wire && branch_condition;
  // Program Counter Datapath and Connection
  assign pc_plus_4     = pc_wire + 4;
  assign branch_target = pc_wire + immediate_wire;
  assign jal_target    = pc_wire + immediate_wire;
  assign jalr_target   = (reg1_data_wire + immediate_wire) & ~32'b1;

  always @(*) begin
    case (ALUSrc_wire)
      2'b00:   alu_second_input_reg = reg2_data_wire;
      2'b01:   alu_second_input_reg = immediate_wire;
      2'b10:   alu_second_input_reg = pc;
      default: alu_second_input_reg = 32'b0;
    endcase
    case (ResultSrc_wire)
      2'b00:   wb_reg = alu_result_wire;
      2'b01:   wb_reg = mem_output_data_wire;  //Memory Now leave it blank
      2'b10:   wb_reg = pc_wire + 32'd4;
      default: wb_reg = 32'b0;
    endcase
    if (AluA_Src_wire == 1) alu_first_input_reg = pc_wire;
    else alu_first_input_reg = reg1_data_wire;
    // 1. Check if Jump / Jump Register
    // 2. Check for brach
    // 3. Opt for normal behaviour
    if (Jump_wire == 2'b01) next_pc = jal_target;
    else if (Jump_wire == 2'b10) next_pc = jalr_target;
    else if (should_branch == 1) next_pc = branch_target;
    else next_pc = pc_plus_4;
  end
  assign mem_write_data_wire = reg2_data_wire;
  assign mem_address_wire = alu_result_wire;
  assign next_pc_wire = next_pc;
  assign Jump = Jump_wire;
  assign Branch = Branch_wire;
  assign alu_first_input = alu_first_input_reg;
  assign wb_enable_wire = reg_write_wire & ~reset;
  assign RegWrite = wb_enable_wire;
  assign wb_data_wire = wb_reg;
  assign pc = pc_wire;
  assign result = alu_result_wire;
  assign alu_second_input = alu_second_input_reg;
  assign zero = zero_wire;
  assign ALUop = ALUop_wire;
  assign ALUSrc = ALUSrc_wire;
  assign ResultSrc = ResultSrc_wire;
  assign reg1_data = reg1_data_wire;
  assign reg2_data = reg2_data_wire;
  assign instruction_out = fetched_instruction;
  assign immediate = immediate_wire;
  assign mem_write = mem_write_wire;
  assign mem_read = mem_read_wire;
endmodule
