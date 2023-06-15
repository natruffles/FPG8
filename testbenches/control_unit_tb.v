`timescale 1 ns / 10 ps

module control_unit_tb();

reg clk = 0;
reg reset = 0;
reg [3:0] opcode = 1;
reg [2:0] PSW_bits = 3'b100;
reg [2:0] IR_Rs2 = 0;
reg timeout = 1;
wire [4:0] REG_OUT_CONTROL_UNIT;
wire [2:0] ALU_control;
wire con_ROM_out;
wire GPR_in;
wire GPR_out;
wire [2:0] GPR_select;
wire IR_in;
wire MAR_in;
wire MDR_in;
wire MDR_out;
wire PSW_in;
wire PSW_out;
wire RAM_enable_read;
wire RAM_enable_write;
wire timer_in;
wire Y_in;
wire Y_out;
wire Y_offset_in;
wire Y_shift_left;
wire Y_shift_right;
wire Z_in;
wire Z_out;

control_unit uut (
    .clk(clk),
    .reset(reset),
    .opcode(opcode),
    .PSW_bits(PSW_bits),
    .IR_Rs2(IR_Rs2),
    .timeout(timeout),
    .REG_OUT_CONTROL_UNIT(REG_OUT_CONTROL_UNIT),
    .ALU_control(ALU_control),
    .con_ROM_out(con_ROM_out),
    .GPR_in(GPR_in),
    .GPR_out(GPR_out),
    .GPR_select(GPR_select),
    .IR_in(IR_in),
    .MAR_in(MAR_in),
    .MDR_in(MDR_in),
    .MDR_out(MDR_out),
    .PSW_in(PSW_in),
    .PSW_out(PSW_out),
    .RAM_enable_read(RAM_enable_read),
    .RAM_enable_write(RAM_enable_write),
    .timer_in(timer_in),
    .Y_in(Y_in),
    .Y_out(Y_out),
    .Y_offset_in(Y_offset_in),
    .Y_shift_left(Y_shift_left),
    .Y_shift_right(Y_shift_right),
    .Z_in(Z_in),
    .Z_out(Z_out)
);

// Simulation time: 10000 * 1 ns = 10 us
localparam DURATION = 10000;

// Generate clock signal: 1 / ((2 * 41.67) * 1 ns) = 11,999,040.08 MHz
always begin
    #41.67
    clk = ~clk;
end



initial begin
    reset = 1;
    #(2 * 41.67)
    reset = 0;
end

// Run simulation (output to .vcd file)
initial begin
    // Create simulation output file 
    $dumpfile("control_unit_tb.vcd");
    $dumpvars(0, control_unit_tb);
    
    // Wait for given amount of time for simulation to complete
    #(DURATION)
    
    // Notify and end simulation
    $display("Finished!");
    $finish;
end
    
endmodule