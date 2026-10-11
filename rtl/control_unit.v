module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [7:0] funct7_bit, // instr[30]
    output reg        reg_write,
    output reg        alu_src,
    output reg        mem_read,
    output reg        mem_write,
    output reg [1:0]  mem_to_reg, // 00: ALU, 01: Mem, 10: PC+4
    output reg        branch,
    output reg        jal,
    output reg        jalr,
    output reg        lui,
    output reg        auipc,
    output reg [3:0]  alu_control
);

       always @(*) begin
            // Default Signal Values
            reg_write  = 1'b0;
            alu_src    = 1'b0;
            mem_read   = 1'b0;
            mem_write  = 1'b0;
            mem_to_reg = 2'b00;
            branch     = 1'b0;
            jal        = 1'b0;
            jalr       = 1'b0;
            lui        = 1'b0;
            auipc      = 1'b0;
            alu_control= 4'b0000;

        case (opcode)
            // R-Type Instructions
            7'b0110011: begin
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_control = (funct7_bit) ? 4'b0001 : 4'b0000; // SUB : ADD
                    3'b001: alu_control = 4'b0101; // SLL
                    3'b010: alu_control = 4'b1000; // SLT
                    3'b011: alu_control = 4'b1001; // SLTU
                    3'b100: alu_control = 4'b0100; // XOR
                    3'b101: alu_control = (funct7_bit) ? 4'b0111 : 4'b0110; // SRA : SRL
                    3'b110: alu_control = 4'b0011; // OR
                    3'b111: alu_control = 4'b0010; // AND
                endcase
            end

            // I-Type ALU Instructions
            7'b0010011: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                case (funct3)
                    3'b000: alu_control = 4'b0000; // ADDI
                    3'b001: alu_control = 4'b0101; // SLLI
                    3'b010: alu_control = 4'b1000; // SLTI
                    3'b011: alu_control = 4'b1001; // SLTIU
                    3'b100: alu_control = 4'b0100; // XORI
                    3'b101: alu_control = (funct7_bit) ? 4'b0111 : 4'b0110; // SRAI : SRLI
                    3'b110: alu_control = 4'b0011; // ORI
                    3'b111: alu_control = 4'b0010; // ANDI
                endcase
            end

            // Load Instructions (LB, LH, LW, LBU, LHU)
            7'b0000011: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 2'b01;
                alu_control= 4'b0000; // Address calc: base + offset
            end

            // Store Instructions (SB, SH, SW)
            7'b0100011: begin
                alu_src    = 1'b1;
                mem_write  = 1'b1;
                alu_control= 4'b0000; // Address calc: base + offset
            end

            // Branch Instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU)
            7'b1100011: begin
                branch      = 1'b1;
                alu_control = 4'b0001; // Compare using subtraction
            end

            // JAL
            7'b1101111: begin
                reg_write  = 1'b1;
                jal        = 1'b1;
                mem_to_reg = 2'b10; // Store PC+4 in rd
            end

            // JALR
            7'b1100111: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                jalr       = 1'b1;
                mem_to_reg = 2'b10; // Store PC+4 in rd
                alu_control= 4'b0000;
            end

            // LUI
            7'b0110111: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                lui        = 1'b1;
                alu_control= 4'b1010; // Pass immediate
            end

            // AUIPC
            7'b0010111: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                auipc      = 1'b1;
                alu_control= 4'b0000; // PC + Imm
            end
        endcase
    end

endmodule
