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
  wire [31:0] fetched_instruction, fetched_instruction_pre_id;
  wire [31:0] immediate_wire;
  wire zero_wire, reg_write_wire, wb_enable_wire, AluA_Src_wire, Branch_wire;
  wire exception_wire;
  wire [3:0] ALUop_wire;
  wire [1:0] ResultSrc_wire, ALUSrc_wire, Jump_wire;
  wire [31:0] reg1_data_wire, reg2_data_wire;
  wire [31:0] alu_second_input, alu_first_input, alu_result_wire;
  wire [31:0] mem_wb_memory_read_data_wire, mem_wb_alu_result_wire, mem_wb_pc_wire;
  wire mem_wb_reg_write_wire;
  wire [31:0] pc_wire, next_pc_wire, pc_pre_id;
  wire [31:0] wb_data_wire;
  reg [31:0] alu_second_input_reg, alu_first_input_reg, wb_reg, next_pc;
  wire [31:0] mem_address_wire, mem_write_data_wire, mem_output_data_wire;
  wire mem_read_wire, mem_write_wire;
  wire stall_wire, if_id_flush_wire, id_ex_flush_wire, ex_mem_flush_wire, mem_wb_flush_wire;
  wire [31:0] id_ex_pc_wire, ex_mem_pc_wire, ex_mem_alu_result_wire, ex_mem_store_data_wire;
  wire ex_mem_mem_write_wire, ex_mem_mem_read_wire, ex_mem_regwrite_wire;
  wire [31:0] id_ex_reg1_data_wire, id_ex_reg2_data_wire;
  wire [31:0] id_ex_immediate_wire;
  wire [4:0] id_ex_rs1_wire, id_ex_rs2_wire, id_ex_rd_wire, ex_mem_rd_wire, mem_wb_rd_wire;
  wire id_ex_reg_write_wire, id_ex_mem_read_wire, id_ex_mem_write_wire;
  wire id_ex_branch_wire, id_ex_exception_wire, id_ex_alu_a_src_wire;
  wire [1:0] id_ex_jump_wire, id_ex_alu_src_wire, id_ex_result_src_wire, ex_mem_result_src_wire, mem_wb_result_src_wire;
  wire [3:0] id_ex_alu_op_wire;
  wire [2:0] id_ex_mem_size_wire, ex_mem_mem_size_wire;
  wire [2:0] mem_size_wire;  // This is for lb, sb etc
  memory #(
      .ADDRESS_WIDTH(DATA_ADDRESS_WIDTH)
  ) mem (
      .clk(clk),
      .address(mem_address_wire),
      .write_data(mem_write_data_wire),
      .mem_write(ex_mem_mem_write_wire),
      .mem_read(ex_mem_mem_read_wire),
      .mem_size(ex_mem_mem_size_wire),
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
      .instruction(fetched_instruction_pre_id),
      .immediate  (immediate_wire)
  );
  control_unit cu (
      .instruction(fetched_instruction_pre_id),
      .MemRead(mem_read_wire),
      .MemWrite(mem_write_wire),
      .Branch(Branch_wire),
      .Jump(Jump_wire),
      .Exception(exception_wire),
      .AluA_Src(AluA_Src_wire),
      .ResultSrc(ResultSrc_wire),
      .ALUSrc(ALUSrc_wire),
      .ALUop(ALUop_wire),
      .RegWrite(reg_write_wire),
      .mem_sel(mem_size_wire)
  );
  reg_file register_file (
      .clk(clk),
      .wb_data(wb_data_wire),
      .wb_enable(wb_enable_wire),
      .reg1_sel(fetched_instruction_pre_id[19:15]),
      .reg2_sel(fetched_instruction_pre_id[24:20]),
      .reg3_sel(mem_wb_rd_wire),
      .reg1_data(reg1_data_wire),
      .reg2_data(reg2_data_wire)
  );
  alu alu_module (
      .x(alu_first_input),
      .y(alu_second_input),
      .opcode(id_ex_alu_op_wire),
      .result(alu_result_wire),
      .zero(zero_wire),
      .cout(cout),
      .overflow(overflow)
  );

  // Registers
  if_id_reg if_id_register (
      .fetched_instruction_in(fetched_instruction),
      .pc_in(pc_wire),
      .clk(clk),
      .stall(stall_wire),
      .reset(reset),
      .flush(if_id_flush_wire),
      .fetched_instruction_out(fetched_instruction_pre_id),
      .pc_out(pc_pre_id)
  );

  id_ex_reg id_ex_register (
      .clk(clk),
      .reset(reset),
      .flush(id_ex_flush_wire),
      .pc_in(pc_pre_id),
      .reg1_data_in(reg1_data_wire),
      .reg2_data_in(reg2_data_wire),
      .immediate_in(immediate_wire),
      .rs1_in(fetched_instruction_pre_id[19:15]),
      .rs2_in(fetched_instruction_pre_id[24:20]),
      .rd_in(fetched_instruction_pre_id[11:7]),
      .RegWrite_in(reg_write_wire),
      .MemRead_in(mem_read_wire),
      .MemWrite_in(mem_write_wire),
      .Branch_in(Branch_wire),
      .Jump_in(Jump_wire),
      .Exception_in(exception_wire),
      .AluA_Src_in(AluA_Src_wire),
      .ALUSrc_in(ALUSrc_wire),
      .ResultSrc_in(ResultSrc_wire),
      .ALUop_in(ALUop_wire),
      .mem_size_in(mem_size_wire),
      .pc_out(id_ex_pc_wire),
      .reg1_data_out(id_ex_reg1_data_wire),
      .reg2_data_out(id_ex_reg2_data_wire),
      .immediate_out(id_ex_immediate_wire),
      .rs1_out(id_ex_rs1_wire),
      .rs2_out(id_ex_rs2_wire),
      .rd_out(id_ex_rd_wire),
      .RegWrite_out(id_ex_reg_write_wire),
      .MemRead_out(id_ex_mem_read_wire),
      .MemWrite_out(id_ex_mem_write_wire),
      .Branch_out(id_ex_branch_wire),
      .Jump_out(id_ex_jump_wire),
      .Exception_out(id_ex_exception_wire),
      .AluA_Src_out(id_ex_alu_a_src_wire),
      .ALUSrc_out(id_ex_alu_src_wire),
      .ResultSrc_out(id_ex_result_src_wire),
      .ALUop_out(id_ex_alu_op_wire),
      .mem_size_out(id_ex_mem_size_wire)
  );
  ex_mem_reg ex_mem_register (
      .clk(clk),
      .reset(reset),
      .flush(ex_mem_flush_wire),
      .alu_result_in(alu_result_wire),
      .pc_in(id_ex_pc_wire),
      .rd_in(id_ex_rd_wire),
      .store_data_in(id_ex_reg2_data_wire),
      .MemRead_in(id_ex_mem_read_wire),
      .MemWrite_in(id_ex_mem_write_wire),
      .mem_size_in(id_ex_mem_size_wire),
      .RegWrite_in(id_ex_reg_write_wire),
      .ResultSrc_in(id_ex_result_src_wire),
      .alu_result_out(ex_mem_alu_result_wire),
      .pc_out(ex_mem_pc_wire),
      .store_data_out(ex_mem_store_data_wire),
      .mem_size_out(ex_mem_mem_size_wire),
      .MemRead_out(ex_mem_mem_read_wire),
      .MemWrite_out(ex_mem_mem_write_wire),
      .RegWrite_out(ex_mem_regwrite_wire),
      .ResultSrc_out(ex_mem_result_src_wire),
      .rd_out(ex_mem_rd_wire)
  );
  mem_wb_reg mem_wb_register (
      .clk(clk),
      .flush(mem_wb_flush_wire),
      .reset(reset),
      .rd_in(ex_mem_rd_wire),
      .alu_result_in(ex_mem_alu_result_wire),
      .RegWrite_in(ex_mem_regwrite_wire),
      .ResultSrc_in(ex_mem_result_src_wire),
      .memory_read_data_in(mem_output_data_wire),
      .pc_in(ex_mem_pc_wire),
      .alu_result_out(mem_wb_alu_result_wire),
      .pc_out(mem_wb_pc_wire),
      .memory_read_data_out(mem_wb_memory_read_data_wire),
      .RegWrite_out(mem_wb_reg_write_wire),
      .ResultSrc_out(mem_wb_result_src_wire),
      .rd_out(mem_wb_rd_wire)
  );
  wire should_branch;
  wire [31:0] pc_plus_4, branch_target, jal_target, jalr_target;
  reg branch_condition;

  always @(*) begin
    case (fetched_instruction_pre_id[14:12])
      3'b000:  branch_condition = (reg1_data_wire == reg2_data_wire);  // BEQ
      3'b001:  branch_condition = (reg1_data_wire != reg2_data_wire);  // BNE
      3'b100:  branch_condition = $signed(reg1_data_wire) < $signed(reg2_data_wire);  // BLT
      3'b101:  branch_condition = $signed(reg1_data_wire) >= $signed(reg2_data_wire);  // BGE
      3'b110:  branch_condition = reg1_data_wire < reg2_data_wire;  // BLTU
      3'b111:  branch_condition = reg1_data_wire >= reg2_data_wire;  // BGEU
      default: branch_condition = 1'b0;
    endcase
  end
  assign should_branch     = Branch_wire && branch_condition;
  // Hazard unit placeholders. Control-flow redirect (resolved in ID) flushes the wrong-path fetch
  assign ex_mem_flush_wire = 1'b0;
  assign mem_wb_flush_wire = 1'b0;
  assign stall_wire        = 1'b0;
  assign id_ex_flush_wire  = 1'b0;
  assign if_id_flush_wire  = should_branch || (Jump_wire != 2'b00);
  // Program Counter Datapath and Connection
  assign pc_plus_4         = pc_wire + 4;  // sequential fetch, not the ID-stage PC
  assign branch_target     = pc_pre_id + immediate_wire;
  assign jal_target        = pc_pre_id + immediate_wire;
  assign jalr_target       = (reg1_data_wire + immediate_wire) & ~32'b1;

  always @(*) begin
    case (id_ex_alu_src_wire)
      2'b00:   alu_second_input_reg = id_ex_reg2_data_wire;
      2'b01:   alu_second_input_reg = id_ex_immediate_wire;
      2'b10:   alu_second_input_reg = id_ex_pc_wire;
      default: alu_second_input_reg = 32'b0;
    endcase
    case (mem_wb_result_src_wire)
      2'b00:   wb_reg = mem_wb_alu_result_wire;
      2'b01:   wb_reg = mem_wb_memory_read_data_wire;  //Memory Now leave it blank
      2'b10:   wb_reg = mem_wb_pc_wire + 32'd4;
      default: wb_reg = 32'b0;
    endcase
    if (id_ex_alu_a_src_wire == 1) alu_first_input_reg = id_ex_pc_wire;
    else alu_first_input_reg = id_ex_reg1_data_wire;
    // 1. Check if Jump / Jump Register
    // 2. Check for brach
    // 3. Opt for normal behaviour
    if (Jump_wire == 2'b01) next_pc = jal_target;
    else if (Jump_wire == 2'b10) next_pc = jalr_target;
    else if (should_branch == 1) next_pc = branch_target;
    else next_pc = pc_plus_4;
  end
  assign mem_write_data_wire = ex_mem_store_data_wire;
  assign mem_address_wire = ex_mem_alu_result_wire;
  assign next_pc_wire = next_pc;
  assign Jump = id_ex_jump_wire;
  assign Branch = id_ex_branch_wire;
  assign alu_first_input = alu_first_input_reg;
  assign wb_enable_wire = mem_wb_reg_write_wire & ~reset;
  assign RegWrite = wb_enable_wire;
  assign wb_data_wire = wb_reg;
  assign pc = pc_wire;
  assign result = alu_result_wire;
  assign alu_second_input = alu_second_input_reg;
  assign zero = zero_wire;
  assign ALUop = id_ex_alu_op_wire;
  assign ALUSrc = id_ex_alu_src_wire;
  assign ResultSrc = id_ex_result_src_wire;
  assign reg1_data = id_ex_reg1_data_wire;
  assign reg2_data = id_ex_reg2_data_wire;
  assign instruction_out = fetched_instruction;
  assign immediate = id_ex_immediate_wire;
  assign mem_write = id_ex_mem_write_wire;
  assign mem_read = id_ex_mem_read_wire;
  assign Exception = id_ex_exception_wire;
endmodule
