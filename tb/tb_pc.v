`timescale 1ns / 1ps

module tb_pc;

    reg         clk;
    reg         reset;
    reg  [31:0] pc_next;
    wire [31:0] pc;

    // Instantiate PC module
    pc uut (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc(pc)
    );

    // Clock generation: 10ns period (100MHz)
    always #5 clk = ~clk;

    initial begin
        // Setup VCD dumping for GTKWave
        $dumpfile("build/tb_pc.vcd");
        $dumpvars(0, tb_pc);

        // Initialize signals
        clk = 0;
        reset = 1;
        pc_next = 32'h0000_0000;

        // Release reset after 12ns
        #12;
        reset = 0;

        // Simulate simple PC increment (PC + 4)
        pc_next = 32'h0000_0004;
        #10;
        pc_next = 32'h0000_0008;
        #10;
        pc_next = 32'h0000_000C;
        #10;

        $finish;
    end

endmodule
