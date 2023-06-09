// testbench for ram, from shawn hymel tutorial series:
// https://github.com/ShawnHymel/introduction-to-fpga/blob/main/08-memory/example-02-memory-initialization/memory_tb.v

`timescale 1 ns / 10 ps

// Define our testbench
module RAM_MAR_MDR_tb();

// control signals
reg clk = 0;
reg reset = 0;
reg MAR_in = 0;
reg MDR_in = 0;
reg MDR_out = 0;
reg RAM_write = 0;
reg RAM_read = 0;

reg [15:0] bus_reg = 16'b1111111111111111;

// Storage elements (set initial values to 0)
wire [15:0] REG_OUT_MAR;
wire [15:0] REG_OUT_MDR;
wire [15:0] w_bus;
wire [15:0] MDR_RAM_connect;

assign w_bus = bus_reg;

// Simulation time: 10000 * 1 ns = 10 us
localparam DURATION = 10000;

// Generate clock signal: 1 / ((2 * 41.67) * 1 ns) = 11,999,040.08 MHz
always begin
    #41.67
    clk = ~clk;
end

MAR uut_MAR (
    .clk(clk),
    .reset(reset), 
    .DATA(w_bus), 
    .REG_OUT_MAR(REG_OUT_MAR),
    .MAR_in(MAR_in)
);

MDR uut_MDR (
    .clk(clk), 
    .reset(reset), 
    .from_bus(w_bus),
    .MDR_bus_connect(w_bus),
    .REG_OUT_MDR(REG_OUT_MDR),
    .MDR_RAM_connect(MDR_RAM_connect),
    .MDR_in(MDR_in),
    .MDR_out(MDR_out),
    .write_to_MM(RAM_write),
    .read_from_MM(RAM_read)
);

ram #(   
    .INIT_FILE("mem_init.txt")
) uut_RAM (
    .clk(clk),
    .w_en(RAM_write),
    .r_en(RAM_read),
    .addr(REG_OUT_MAR[7:0]),
    .MDR_RAM_connect(MDR_RAM_connect)
);

initial begin
    #(2 * 41.67)
    reset = 1;
    #(2 * 41.67)
    reset = 0;
    RAM_read = 1;
    #(2 * 41.67)
    RAM_read = 0;
    MDR_in = 1;
    #(2 * 41.67)
    MDR_in = 0;
    bus_reg = 16'b0000000000000001;
    RAM_write = 1;
    #(2 * 41.67)
    RAM_write = 0;
    MDR_in = 1;
    #(2 * 41.67)
    MDR_in = 0;
    RAM_read = 1;
    #(2 * 41.67)
    RAM_read = 0;
end

// Run simulation (output to .vcd file)
initial begin
    // Create simulation output file 
    $dumpfile("RAM_MAR_MDR_tb.vcd");
    $dumpvars(0, RAM_MAR_MDR_tb);
    
    // Wait for given amount of time for simulation to complete
    #(DURATION)
    
    // Notify and end simulation
    $display("Finished!");
    $finish;
end
    
endmodule