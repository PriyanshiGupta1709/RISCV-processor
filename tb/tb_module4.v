`timescale 1ns / 1ps

module tb_module4;

    reg        clk;
    reg        mem_read, mem_write;
    reg  [2:0] funct3;
    reg  [31:0] addr, write_data;
    wire [31:0] read_data;

    data_mem dmem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .funct3(funct3),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/tb_module4.vcd");
        $dumpvars(0, tb_module4);

        clk = 0; mem_read = 0; mem_write = 0;
        addr = 0; write_data = 0; funct3 = 0;

        #10;
        // 1. Store Word (SW) at addr 4: 0xDEADBEEF
        mem_write = 1; funct3 = 3'b010; addr = 32'd4; write_data = 32'hDEADBEEF;
        #10;
        mem_write = 0;

        // 2. Read Word (LW)
        mem_read = 1; funct3 = 3'b010; addr = 32'd4;
        #5;
        if (read_data !== 32'hDEADBEEF) $display("Error in SW/LW!");

        // 3. Read Unsigned Byte (LBU) from addr 4 (Expect 0xEF)
        funct3 = 3'b100; addr = 32'd4;
        #5;
        if (read_data !== 32'h000000EF) $display("Error in LBU!");

        $display("Module 4 tests completed successfully!");
        $finish;
    end

endmodule
