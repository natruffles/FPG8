// testbench for ALU

`timescale 1 ns / 10 ps

module alu_tb();

reg [15:0] bus = 16'b0101010101010101;
reg [15:0] y_shifted = 16'b1010101010101010;
reg [2:0] control = 3'b000;
wire [15:0] ALU_out;

localparam DURATION = 10000; // 10 us simulation time

alu uut (
    .bus(bus),
    .y_shifted(y_shifted),
    .ALU_out(ALU_out),
    .ALU_control(control)
);

initial begin
    #10
    control = 3'b001;
    #10
    control = 3'b010;
    #10
    control = 3'b011;
    #10
    control = 3'b100;
    #10
    control = 3'b101;
    #10
    control = 3'b110;
end

initial begin
    $dumpfile("alu_tb.vcd");
    $dumpvars(0, alu_tb);
    #(DURATION);
    $display("Finished!");
    $finish;
end

endmodule
