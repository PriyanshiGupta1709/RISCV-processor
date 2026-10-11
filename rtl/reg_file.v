module reg_file (
    input  wire        clk,
    input  wire        reset,
    input  wire        reg_write,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);

    reg [31:0] registers [0:31];
    integer i;

    // Asynchronous Reads: Hardwire x0 to 0
    assign read_data1 = (rs1 == 5'b0) ? 32'h0000_0000 : registers[rs1];
    assign read_data2 = (rs2 == 5'b0) ? 32'h0000_0000 : registers[rs2];

    // Synchronous Writes on rising clock edge
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h0000_0000;
            end
        end else if (reg_write && (rd != 5'b0)) begin
            registers[rd] <= write_data;
        end
    end

endmodule
