`timescale 1 ns / 10 ps

module PSW_tb();

reg clk = 0;
reg reset = 0;
reg latch = 0;
reg enable = 0;
reg [3:0] opcode = 4'b1000;
reg S = 0;
reg Z_in = 0;
reg CC_Z = 0;
reg CC_N = 0;

wire [15:0] reg_out;

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

PSW uut (
    .clk(clk),
    .reset(reset),
    .DATA(w_bus),  
    .REG_OUT_PSW(reg_out), 
    .latch(latch), 
    .enable(enable), 
    .IR_opcode(opcode),
    .IR_S(S),
    .Z_in(Z_in),
    .CC_Z_in(CC_Z),
    .CC_N_in(CC_N)
);

initial begin
    reset = 1;
    #(2 * 41.67)
    reset = 0;
    latch = 1;
    #(2 * 41.67)
    latch = 0;
    Z_in = 1;
    #(2 * 41.67)
    S = 1;
    #(2 * 41.67)
    latch = 1;
    #(2 * 41.67)
    Z_in = 0;
    S = 0;
    latch = 0;
    #(2 * 41.67)
    reset = 1;
    #(2 * 41.67)
    reset = 0;
end

// Run simulation (output to .vcd file)
initial begin
    // Create simulation output file 
    $dumpfile("PSW_tb.vcd");
    $dumpvars(0, PSW_tb);
    
    // Wait for given amount of time for simulation to complete
    #(DURATION)
    
    // Notify and end simulation
    $display("Finished!");
    $finish;
end
    
endmodule