`timescale 1ns / 1ps

module tb_module3;

    reg  [31:0] instr;
    wire [31:0] imm_ext;

    reg  [31:0] a, b;
    reg  [3:0]  alu_control;
    wire [31:0] result;
    wire        zero;

    imm_gen u_imm_gen (
        .instr(instr),
        .imm_ext(imm_ext)
    );

    alu u_alu (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    initial begin
        $dumpfile("build/tb_module3.vcd");
        $dumpvars(0, tb_module3);

        // 1. Test I-Type Sign Extension (addi x1, x0, -1) => imm = 0xFFFFFFFF
        instr = 32'hfff00093;
        #5;
        if (imm_ext !== 32'hffff_ffff) $display("Error: I-type ImmGen failed!");

        // 2. Test S-Type Immediate Decoding (sw x1, -4(x2))
        instr = 32'hfe112e23;
        #5;
        if (imm_ext !== 32'hffff_fffc) $display("Error: S-type ImmGen failed!");

        // 3. Test ALU Arithmetic & Logic
        a = 32'd15; b = 32'd5;
        alu_control = 4'b0000; #5; // ADD => 20
        alu_control = 4'b0001; #5; // SUB => 10
        alu_control = 4'b0111; #5; // SRA => 15 >>> 5 = 0

        // 4. Test Negative Comparison
        a = 32'hffff_ffff; // -1
        b = 32'd1;
        alu_control = 4'b1000; #5; // SLT => 1 (-1 < 1)

        $display("Module 3 tests completed successfully!");
        $finish;
    end

endmodule
