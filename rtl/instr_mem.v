module instr_mem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    // 1024 words of 32-bit memory (4 KB instruction memory)
    reg [31:0] mem [0:1023];

    // Read instruction at word index (addr / 4)
    assign instr = mem[addr[31:2]];

    // Load machine code from program.mem on startup
    initial begin
        $readmemh("tb/program.mem", mem);
    end

endmodule
