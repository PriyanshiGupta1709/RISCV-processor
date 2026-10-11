module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_control,
    output reg  [31:0] result,
    output wire        zero
);

    assign zero = (result == 32'h0000_0000);

    always @(*) begin
        case (alu_control)
            4'b0000: result = a + b;                  // ADD / ADDI
            4'b0001: result = a - b;                  // SUB
            4'b0010: result = a & b;                  // AND / ANDI
            4'b0011: result = a | b;                  // OR / ORI
            4'b0100: result = a ^ b;                  // XOR / XORI
            4'b0101: result = a << b[4:0];            // SLL / SLLI
            4'b0110: result = a >> b[4:0];            // SRL / SRLI
            4'b0111: result = $signed(a) >>> b[4:0];  // SRA / SRAI
            4'b1000: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // SLT / SLTI
            4'b1001: result = (a < b) ? 32'b1 : 32'b0; // SLTU / SLTIU
            4'b1010: result = b;                      // LUI (pass immediate)
            default: result = 32'h0000_0000;
        endcase
    end

endmodule
