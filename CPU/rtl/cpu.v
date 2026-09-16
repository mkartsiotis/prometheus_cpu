module cpu (
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
    Jump,
    Exception,
    cout,
    zero,
    overflow,
    output [1:0] ResultSrc,
    ALUSrc,
    output [3:0] ALUop
);
  wire [31:0] fetched_instruction;
  wire [31:0] immediate_wire;
  wire zero_wire, wb_enable_wire;
  wire [3:0] ALUop_wire;
  wire [1:0] ResultSrc_wire, ALUSrc_wire;
  wire [31:0] reg1_data_wire, reg2_data_wire;
  wire [31:0] alu_second_input, alu_result_wire;
  wire [31:0] pc_wire;
  wire [31:0] wb_data_wire;
  reg [31:0] alu_second_input_reg, wb_reg;
  instruction_fetch if_module (
      .clk(clk),
      .reset(reset),
      .instruction_out(fetched_instruction),
      .pc_out(pc_wire)
  );
  immediate_generator imm_module (
      .instruction(fetched_instruction),
      .immediate  (immediate_wire)
  );
  control_unit cu (
      .instruction(fetched_instruction),
      .MemRead(MemRead),
      .MemWrite(MemWrite),
      .Branch(Branch),
      .Jump(Jump),
      .Exception(Exception),
      .ResultSrc(ResultSrc_wire),
      .ALUSrc(ALUSrc_wire),
      .ALUop(ALUop_wire),
      .RegWrite(wb_enable_wire)
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
      .x(reg1_data_wire),
      .y(alu_second_input),
      .opcode(ALUop_wire),
      .result(alu_result_wire),
      .zero(zero_wire),
      .cout(cout),
      .overflow(overflow)
  );
  always @(*) begin
    case (ALUSrc_wire)
      2'b00:   alu_second_input_reg = reg2_data_wire;
      2'b01:   alu_second_input_reg = immediate_wire;
      2'b10:   alu_second_input_reg = pc;
      default: alu_second_input_reg = 32'b0;
    endcase
    case (ResultSrc_wire)
      2'b00:   wb_reg = alu_result_wire;
      2'b01:   wb_reg = 32'b0;  //Memory Now leave it blank
      2'b10:   wb_reg = pc_wire + 32'd4;
      default: wb_reg = 32'b0;
    endcase
  end
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
endmodule
