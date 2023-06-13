`timescale 1 ns / 10 ps

module conrom_timer_tb ();

reg clk = 0;
reg reset = 0;
reg conrom_enable = 0;
reg timer_in = 0;
wire timeout;

wire [15:0] timer_out;
wire [15:0] w_bus;

// Simulation time: 10000 * 1 ns = 10 us
localparam DURATION = 10000;

// Generate clock signal: 1 / ((2 * 41.67) * 1 ns) = 11,999,040.08 MHz
always begin
    #41.67
    clk = ~clk;
end

constant_ROM uut_conrom (
    .DATA(w_bus),
    .reset_to_constant_val(reset),
    .enable(conrom_enable)
);

timer uut_timer (
    .clk(clk),
    .reset(reset), 
    .DATA(w_bus), 
    .REG_OUT_TIMER(timer_out), 
    .timer_in(timer_in),
    .timeout(timeout)
);

initial begin
    reset = 1;
    #(2 * 41.67)
    reset = 0;
    conrom_enable = 1;
    #(2 * 41.67)
    timer_in = 1;
    #(2 * 41.67)
    timer_in = 0;
    #(10 * 41.67)
    timer_in = 1;
    #(2 * 41.67)
    timer_in = 0;
end

// Run simulation (output to .vcd file)
initial begin
    // Create simulation output file 
    $dumpfile("conrom_timer_tb.vcd");
    $dumpvars(0, conrom_timer_tb);
    
    // Wait for given amount of time for simulation to complete
    #(DURATION)
    
    // Notify and end simulation
    $display("Finished!");
    $finish;
end
    
endmodule