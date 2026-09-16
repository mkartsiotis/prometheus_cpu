module control_unit (
    input [31:0] instruction,
    output reg RegWrite,
    MemRead,
    MemWrite,
    Branch,
    Jump,
    Exception,
    output reg [1:0] ResultSrc,
    ALUSrc,
    output reg [3:0] ALUop
);
  always @(*) begin
    case (instruction[6:0])
      7'b0010011: begin  // I
        RegWrite = 1'b1;
        ALUSrc = 2'b01;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        ResultSrc = 2'b00;
        Branch = 1'b0;
        Jump = 1'b0;
        Exception = 1'b0;
        case (instruction[14:12])
          3'b000:  ALUop = 4'b0000;
          3'b100:  ALUop = 4'b0101;
          3'b110:  ALUop = 4'b0100;
          3'b111:  ALUop = 4'b0010;
          3'b001:  ALUop = 4'b1000;
          3'b101:  ALUop = 4'b1001;
          3'b010:  ALUop = 4'b0011;
          3'b011:  ALUop = 4'b0111;
          default: ALUop = 4'b0000;
        endcase
      end
      7'b0000011: begin  // I(load)
        RegWrite = 1'b1;
        ALUSrc = 2'b01;
        MemRead = 1'b1;
        MemWrite = 1'b0;
        ResultSrc = 2'b01;
        Branch = 1'b0;
        Jump = 1'b0;
        Exception = 1'b0;
        ALUop = 4'b0000;
      end
      7'b0100011: begin  // S
        RegWrite = 1'b0;
        ALUSrc = 2'b01;
        MemRead = 1'b0;
        MemWrite = 1'b1;
        ResultSrc = 2'b00;
        Branch = 1'b0;
        Jump = 1'b0;
        Exception = 1'b0;
        ALUop = 4'b0000;
      end
      7'b1100011: begin  // B
        RegWrite = 1'b0;
        ALUSrc = 2'b00;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        ResultSrc = 2'b00;
        Branch = 1'b1;
        Jump = 1'b0;
        Exception = 1'b0;
        ALUop = 4'b0001;
      end
      7'b1101111: begin  // J
        RegWrite = 1'b1;
        ALUSrc = 2'b01;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        ResultSrc = 2'b10;
        Branch = 1'b0;
        Jump = 1'b1;
        Exception = 1'b0;
        ALUop = 4'b0000;
      end
      7'b1100111: begin  // Jalr
        RegWrite = 1'b1;
        ALUSrc = 2'b01;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        ResultSrc = 2'b10;
        Branch = 1'b0;
        Jump = 1'b1;
        Exception = 1'b0;
        ALUop = 4'b0000;

      end
      7'b0110111: begin  // U - Type
        RegWrite = 1'b1;
        ALUSrc = 2'b01;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        ResultSrc = 2'b00;
        Branch = 1'b0;
        Jump = 1'b0;
        Exception = 1'b0;
        ALUop = 4'b1011;
      end
      7'b0010111: begin
        RegWrite = 1'b1;
        ALUSrc = 2'b10;  // This means the the SRC is PC
        MemRead = 1'b0;
        MemWrite = 1'b0;
        ResultSrc = 2'b00;
        Branch = 1'b0;
        Jump = 1'b0;
        Exception = 1'b0;
        ALUop = 4'b0000;
      end
      7'b0110011: begin  // R-type
        RegWrite = 1'b1;
        ALUSrc = 2'b00;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        ResultSrc = 2'b00;
        Branch = 1'b0;
        Jump = 1'b0;
        Exception = 1'b0;
        case ({
          instruction[14:12], instruction[31:25]
        })
          10'b0000000000: ALUop = 4'b0000;
          10'b0000100000: ALUop = 4'b0001;
          10'b1000000000: ALUop = 4'b0101;
          10'b1100000000: ALUop = 4'b0100;
          10'b1110000000: ALUop = 4'b0010;
          10'b0010000000: ALUop = 4'b1000;
          10'b1010000000: ALUop = 4'b1001;
          10'b0100000000: ALUop = 4'b0011;
          10'b0110000000: ALUop = 4'b0111;
          default: ALUop = 4'b0000;
        endcase
      end
      7'b1110011: begin
        RegWrite = 1'b0;
        ALUSrc = 2'b00;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        ResultSrc = 2'b00;
        Branch = 1'b0;
        Jump = 1'b0;
        Exception = 1'b1;
        ALUop = 4'b0000;
      end
      default: begin
        RegWrite = 1'b0;
        ALUSrc = 2'b00;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        ResultSrc = 2'b00;
        Branch = 1'b0;
        Jump = 1'b0;
        Exception = 1'b0;
        ALUop = 4'b0000;
      end
    endcase
  end

endmodule
