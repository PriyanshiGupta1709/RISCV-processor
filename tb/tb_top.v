`timescale 1ns / 1ps

module tb_top;

    reg         clk;
    reg         reset;
    wire [31:0] pc_out;
    wire [31:0] alu_result_out;

    rv32i_top uut (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out),
        .alu_result_out(alu_result_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/tb_top.vcd");
        $dumpvars(0, tb_top);

        clk = 0;
        reset = 1;

        #12;
        reset = 0;

        // Execute program loops
        #150;

        $display("\n==============================================");
        $display("    FINAL REGISTER FILE & EXECUTION SNAPSHOT  ");
        $display("==============================================");
        $display("PC Address : 0x%h", pc_out);
        $display("x1 (val  5): %d", uut.u_regfile.registers[1]);
        $display("x2 (val 10): %d", uut.u_regfile.registers[2]);
        $display("x3 (val 15): %d", uut.u_regfile.registers[3]);
        $display("x4 (val 15): %d", uut.u_regfile.registers[4]);
        $display("==============================================\n");

        $finish;
    end

endmodule
