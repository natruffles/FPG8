`timescale 1 ns / 10 ps

module Z_tb();

reg clk = 0;
reg reset = 0;
reg Z_in = 0;
reg Z_out = 0;
wire [15:0] REG_OUT_Z1;
wire [15:0] REG_OUT_Z2;
wire [15:0] out_to_bus;

reg [15:0] w_bus_reg = 16'b1010101110101010;
wire [15:0] w_bus;
assign w_bus = w_bus_reg;

// Simulation time: 10000 * 1 ns = 10 us
localparam DURATION = 10000;

// Generate clock signal: 1 / ((2 * 41.67) * 1 ns) = 11,999,040.08 MHz
always begin
    #41.67
    clk = ~clk;
end

Z uut_Z (
    .clk(clk),
    .reset(reset),
    .from_ALU(w_bus),
    .REG_OUT_Z1(REG_OUT_Z1), 
    .REG_OUT_Z2(REG_OUT_Z2),
    .out_to_bus(out_to_bus),
    .Z_in(Z_in),
    .Z_out(Z_out)
);

initial begin
    reset = 1;
    #(2 * 41.67)
    reset = 0;
    Z_in = 1;
    Z_out = 1;
    #(2 * 41.67)
    w_bus_reg = 16'b0;
    #(2 * 41.67)
    w_bus_reg = 16'b1111111111111111;
    #(2 * 41.67)
    w_bus_reg = 16'b0;
    #(2 * 41.67)
    w_bus_reg = 16'b1111111111111111;
end

// Run simulation (output to .vcd file)
initial begin
    // Create simulation output file 
    $dumpfile("Z_tb.vcd");
    $dumpvars(0, Z_tb);
    
    // Wait for given amount of time for simulation to complete
    #(DURATION)
    
    // Notify and end simulation
    $display("Finished!");
    $finish;
end
    
endmodule