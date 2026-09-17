`timescale 1ns / 1ps

module immediate_generator (
    input [31:0] instruction,
    output reg [31:0] immediate
);
  always @(*) begin
    case (instruction[6:0])
      7'b0010011, 7'b0000011:  // I
      immediate = {{20{instruction[31]}}, instruction[31:20]};
      7'b0100011:  // S
      immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
      7'b1100011:  // B
      immediate = {
        {19{instruction[31]}},
        instruction[31],
        instruction[7],
        instruction[30:25],
        instruction[11:8],
        1'b0
      };
      7'b1101111:  // J
      immediate = {
        {11{instruction[31]}},
        instruction[31],
        instruction[19:12],
        instruction[20],
        instruction[30:21],
        1'b0
      };
      7'b0110111: immediate = {instruction[31:12], 12'b0};  // U - Type
      7'b0010111: immediate = {instruction[31:12], 12'b0};
      default: immediate = 32'b0;  // R-type
    endcase
  end

endmodule
