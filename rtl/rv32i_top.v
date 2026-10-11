module rv32i_top (
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] pc_out,
    output wire [31:0] alu_result_out
);

    // Internal Interconnect Wires
    wire [31:0] pc, pc_next, pc_plus_4, branch_target, jalr_target;
    wire [31:0] instr;
    
    wire        reg_write, alu_src, mem_read, mem_write;
    wire [1:0]  mem_to_reg;
    wire        branch, jal, jalr, lui, auipc;
    wire [3:0]  alu_control;

    wire [31:0] read_data1, read_data2, write_back_data;
    wire [31:0] imm_ext;
    wire [31:0] alu_in_b, alu_result;
    wire        alu_zero;
    wire [31:0] mem_read_data;

    wire        take_branch;

    assign pc_out = pc;
    assign alu_result_out = alu_result;

    // 1. Program Counter Register
    pc u_pc (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc(pc)
    );

    assign pc_plus_4 = pc + 32'd4;

    // 2. Instruction Memory
    instr_mem u_imem (
        .addr(pc),
        .instr(instr)
    );

    // 3. Control Unit
    control_unit u_control (
        .opcode(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7_bit(instr[30]),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jal(jal),
        .jalr(jalr),
        .lui(lui),
        .auipc(auipc),
        .alu_control(alu_control)
    );

    // 4. Register File
    reg_file u_regfile (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .rs1(instr[19:15]),
        .rs2(instr[24:20]),
        .rd(instr[11:7]),
        .write_data(write_back_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // 5. Immediate Generator
    imm_gen u_immgen (
        .instr(instr),
        .imm_ext(imm_ext)
    );

    // 6. ALU Input Multiplexers
    assign alu_in_b = (alu_src) ? imm_ext : read_data2;

    // 7. ALU Execution Unit
    alu u_alu (
        .a(read_data1),
        .b(alu_in_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(alu_zero)
    );

    // 8. Data Memory Unit
    data_mem u_dmem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .funct3(instr[14:12]),
        .addr(alu_result),
        .write_data(read_data2),
        .read_data(mem_read_data)
    );

    // 9. Register Writeback Multiplexer
    assign write_back_data = (lui)            ? imm_ext :
                             (auipc)          ? (pc + imm_ext) :
                             (mem_to_reg==2'b10) ? pc_plus_4 :
                             (mem_to_reg==2'b01) ? mem_read_data :
                                                    alu_result;

    // 10. Next PC Target Resolution
    assign branch_target = pc + imm_ext;
    assign jalr_target   = (read_data1 + imm_ext) & ~32'd1;

    // Branch evaluation logic (BEQ, BNE, BLT, BGE)
    assign take_branch = branch & (
        (instr[14:12] == 3'b000 & alu_zero)  | // BEQ
        (instr[14:12] == 3'b001 & ~alu_zero) | // BNE
        (instr[14:12] == 3'b100 & alu_result[0]) | // BLT (SLT evaluation)
        (instr[14:12] == 3'b101 & ~alu_result[0])  // BGE
    );

    assign pc_next = (jalr)        ? jalr_target :
                     (jal | take_branch) ? branch_target :
                                           pc_plus_4;

endmodule
