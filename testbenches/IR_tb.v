`timescale 1 ns / 10 ps

module IR_tb();

reg clk = 0;
reg reset = 0;
reg IR_in = 0;
wire [15:0] REG_OUT_IR;
wire [3:0] opcode_out;
wire [2:0] rd_out_1;
wire [2:0] rd_out_2;
wire S;
wire [1:0] shift;
wire [2:0] rs_1;
wire [2:0] rs_2;

reg [15:0] w_bus_reg = 16'b1010101010101010;
wire [15:0] w_bus;
assign w_bus = w_bus_reg;

// Simulation time: 10000 * 1 ns = 10 us
localparam DURATION = 10000;

// Generate clock signal: 1 / ((2 * 41.67) * 1 ns) = 11,999,040.08 MHz
always begin
    #41.67
    clk = ~clk;
end

IR uut (
    .clk(clk), 
    .reset(reset),
    .DATA(w_bus), 
    .REG_OUT_IR(REG_OUT_IR),
    .opcode_out(opcode_out),
    .rd_out_1(rd_out_1),
    .rd_out_2(rd_out_2),
    .S(S),
    .shift(shift),
    .rs_1(rs_1),
    .rs_2(rs_2),
    .IR_in(IR_in)
);

initial begin
    #(2 * 41.67)
    IR_in = 1;
    #(2 * 41.67)
    IR_in = 0;
    w_bus_reg = 16'b1111111111111111;
    #(2 * 41.67)
    IR_in = 1;
    #(2 * 41.67)
    IR_in = 0;
end

// Run simulation (output to .vcd file)
initial begin
    // Create simulation output file 
    $dumpfile("IR_tb.vcd");
    $dumpvars(0, IR_tb);
    
    // Wait for given amount of time for simulation to complete
    #(DURATION)
    
    // Notify and end simulation
    $display("Finished!");
    $finish;
end
    
endmodule