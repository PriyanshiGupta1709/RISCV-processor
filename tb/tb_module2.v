`timescale 1ns / 1ps

module tb_module2;

    reg        clk;
    reg        reset;
    reg        reg_write;
    reg  [4:0] rs1, rs2, rd;
    reg  [31:0] write_data;
    reg  [31:0] pc_addr;

    wire [31:0] instr;
    wire [31:0] read_data1;
    wire [31:0] read_data2;

    // Instantiate Instruction Memory
    instr_mem imem (
        .addr(pc_addr),
        .instr(instr)
    );

    // Instantiate Register File
    reg_file rf (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/tb_module2.vcd");
        $dumpvars(0, tb_module2);

        clk = 0;
        reset = 1;
        reg_write = 0;
        rs1 = 0; rs2 = 0; rd = 0;
        write_data = 0;
        pc_addr = 0;

        #12;
        reset = 0;

        // 1. Verify Instruction Reading from program.mem
        #10; pc_addr = 32'h0000_0004; // Expects 00a00113

        // 2. Write 42 to x1 and verify read
        #10;
        reg_write = 1; rd = 5'd1; write_data = 32'd42;
        #10;
        reg_write = 0; rs1 = 5'd1; // read_data1 should now be 42

        // 3. Attempt to write 99 to x0 (should stay 0)
        #10;
        reg_write = 1; rd = 5'd0; write_data = 32'd99;
        #10;
        reg_write = 0; rs1 = 5'd0; // read_data1 must remain 0

        #20;
        $finish;
    end

endmodule
