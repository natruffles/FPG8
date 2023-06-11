`timescale 1 ns / 10 ps

module Y_shifter_tb();

reg clk = 0;
reg reset = 0;
reg Y_in = 0;
reg Y_out = 0;
reg Y_offset_in = 0;
reg Y_shift_left = 0;
reg Y_shift_right = 0;
reg [1:0] shift_amount = 0;

wire [15:0] Y_to_shifter;
wire [15:0] shifter_out;

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

Y uut_Y (
    .clk(clk),
    .reset(reset), 
    .DATA(w_bus), 
    .REG_OUT_Y(Y_to_shifter),
    .Y_in(Y_in),
    .Y_out(Y_out),
    .Y_offset_in(Y_offset_in)
);

shifter uut_shifter (
    .from_Y(Y_to_shifter),
    .Y_shifted(shifter_out),
    .Y_shift_left(Y_shift_left),
    .Y_shift_right(Y_shift_right),
    .shift_amount(shift_amount)
);

initial begin
    reset = 1;
    #(2 * 41.67)
    reset = 0;
    Y_in = 1;
    #(2 * 41.67)
    Y_in = 0;
    reset = 1;
    #(2 * 41.67)
    reset = 0;
    Y_offset_in = 1;
    #(2 * 41.67)
    Y_offset_in = 0;
    Y_shift_left = 1;
    shift_amount = 2'b11;
    #(2 * 41.67)
    Y_shift_left = 0;
    Y_shift_right = 1;
    #(2 * 41.67)
    Y_shift_right = 0;
end

// Run simulation (output to .vcd file)
initial begin
    // Create simulation output file 
    $dumpfile("Y_shifter_tb.vcd");
    $dumpvars(0, Y_shifter_tb);
    
    // Wait for given amount of time for simulation to complete
    #(DURATION)
    
    // Notify and end simulation
    $display("Finished!");
    $finish;
end
    
endmodule