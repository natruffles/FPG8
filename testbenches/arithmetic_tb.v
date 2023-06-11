// Value ABAA (hex) driven to the bus
// Value input into Y register
// Value arithmetically shifted right 3 bits
// ALU subtract bus value (ABAA) with shifted value (F575)
// ALU outputs final value (B635) to comparator and Z register
// On next clock cycle, Z register outputs back to the bus
// Comparator says that B635 is a negative value and nonzero

`timescale 1 ns / 10 ps

module arithmetic_tb();

reg clk = 0;
reg reset = 0;
reg Z_in = 0;
reg Z_out = 0;
reg Y_in = 0;
reg Y_out = 0;
reg Y_offset_in = 0;
reg Y_shift_left = 0;
reg Y_shift_right = 0;
reg [1:0] shift_amount = 0;
reg [2:0] control = 3'b000;
wire [15:0] REG_OUT_Z1;
wire [15:0] REG_OUT_Z2;
wire [15:0] y_shifted;
wire [15:0] Y_to_shifter;
wire [15:0] ALU_out;
wire [15:0] after_z;
wire CC_Z;
wire CC_N;

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

alu uut_alu (
    .bus(w_bus),
    .y_shifted(y_shifted),
    .ALU_out(ALU_out),
    .ALU_control(control)
);

comparator uut_comparator (
    .from_ALU(ALU_out),
    .CC_Z(CC_Z),
    .CC_N(CC_N)
);

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
    .Y_shifted(y_shifted),
    .Y_shift_left(Y_shift_left),
    .Y_shift_right(Y_shift_right),
    .shift_amount(shift_amount)
);

Z uut_Z (
    .clk(clk),
    .reset(reset),
    .from_ALU(ALU_out),
    .REG_OUT_Z1(REG_OUT_Z1), 
    .REG_OUT_Z2(REG_OUT_Z2),
    .out_to_bus(after_z),
    .Z_in(Z_in),
    .Z_out(Z_out)
);

initial begin
    reset = 1;
    #(2 * 41.67)
    reset = 0;
    Y_in = 1;
    #(2 * 41.67)
    Y_in = 0;
    Y_shift_right = 1;
    shift_amount = 2'b11;
    control = 3'b110;
    Z_in = 1;
    #(2 * 41.67)
    Y_shift_right = 0;
    shift_amount = 2'b00;
    control = 3'b000;
    Z_in = 0;
    Z_out = 1;
end

// Run simulation (output to .vcd file)
initial begin
    // Create simulation output file 
    $dumpfile("arithmetic_tb.vcd");
    $dumpvars(0, arithmetic_tb);
    
    // Wait for given amount of time for simulation to complete
    #(DURATION)
    
    // Notify and end simulation
    $display("Finished!");
    $finish;
end
    
endmodule