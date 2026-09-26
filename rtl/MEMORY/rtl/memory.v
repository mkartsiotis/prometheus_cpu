`timescale 1ns / 1ps

module memory #(
    parameter ADDRESS_WIDTH = 8  // 2^8 = 256 words
) (
    input clk,
    input [31:0] address,
    input [31:0] write_data,
    input mem_write,
    input mem_read,
    input [2:0] mem_size,
    output reg [31:0] read_data
);
  //Since memory is combinational for single stage architecture we do not need
  //anything as a mem_read. So it is fine!
  reg [31:0] mem[0:(2**ADDRESS_WIDTH)-1];
  wire [ADDRESS_WIDTH-1:0] word_addr = address[ADDRESS_WIDTH+1:2];
  wire half_sel = address[1];
  wire [1:0] byte_sel = address[1:0];
  always @(*) begin
    //READ LOGIC
    if (mem_read == 1) begin
      case (mem_size)
        3'b000: begin  // lw
          read_data = mem[word_addr];  // combinational read for single cycle 
        end
        3'b001: begin  // lh
          if (half_sel == 0)
            read_data = $signed(mem[word_addr][15:0]);  // combinational read for single cycle
          else read_data = $signed(mem[word_addr][31:16]);  // combinational read for single cycle
        end
        3'b010: begin  // lb
          case (byte_sel)
            2'b00: read_data = $signed(mem[word_addr][7:0]);  // combinational read for single cycle
            2'b01:
            read_data = $signed(mem[word_addr][15:8]);  // combinational read for single cycle
            2'b10:
            read_data = $signed(mem[word_addr][23:16]);  // combinational read for single cycle
            2'b11:
            read_data = $signed(mem[word_addr][31:24]);  // combinational read for single cycle
            default: read_data = $signed(0);  // default
          endcase
        end
        3'b101: begin  // lhu
          if (half_sel == 0)
            read_data = $unsigned(mem[word_addr][15:0]);  // combinational read for single cycle
          else read_data = $unsigned(mem[word_addr][31:16]);  // combinational read for single cycle
        end
        3'b110: begin  // lbu
          case (byte_sel)
            2'b00:
            read_data = $unsigned(mem[word_addr][7:0]);  // combinational read for single cycle
            2'b01:
            read_data = $unsigned(mem[word_addr][15:8]);  // combinational read for single cycle
            2'b10:
            read_data = $unsigned(mem[word_addr][23:16]);  // combinational read for single cycle
            2'b11:
            read_data = $unsigned(mem[word_addr][31:24]);  // combinational read for single cycle
            default: read_data = $signed(0);  // default
          endcase
        end
        default: begin
          read_data = 32'b0;
        end
      endcase
    end else read_data = 32'b0;
  end
  always @(posedge clk) begin
    //Write logic
    if (mem_write) begin
      case (mem_size)
        3'b000: begin  // sw
          mem[word_addr] <= write_data;
        end
        3'b001: begin  // sh
          if (half_sel == 0) mem[word_addr][15:0] <= write_data[15:0];
          else mem[word_addr][31:16] <= write_data[15:0];
        end
        3'b010: begin  // sb
          case (byte_sel)
            2'b00:   mem[word_addr][7:0] <= write_data[7:0];
            2'b01:   mem[word_addr][15:8] <= write_data[7:0];
            2'b10:   mem[word_addr][23:16] <= write_data[7:0];
            2'b11:   mem[word_addr][31:24] <= write_data[7:0];
            default: ;  // default
          endcase
        end
        default: ;
      endcase
    end
  end
endmodule
