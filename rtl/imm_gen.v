module imm_gen (
    input  wire [31:0] instr,
    output reg  [31:0] imm_ext
);

    wire [6:0] opcode = instr[6:0];

    always @(*) begin
        case (opcode)
            // I-Type: Jalr, Loads, ALU Immediate
            7'b1100111, 7'b0000011, 7'b0010011: begin
                imm_ext = {{20{instr[31]}}, instr[31:20]};
            end

            // S-Type: Stores
            7'b0100011: begin
                imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            // B-Type: Branches
            7'b1100011: begin
                imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            // U-Type: LUI, AUIPC
            7'b0110111, 7'b0010111: begin
                imm_ext = {instr[31:12], 12'b0};
            end

            // J-Type: JAL
            7'b1101111: begin
                imm_ext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            end

            default: imm_ext = 32'h0000_0000;
        endcase
    end

endmodule
