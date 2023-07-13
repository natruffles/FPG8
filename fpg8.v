module fpg8 (
    output [4:0] led, 
    output top_left, top, top_right, middle, bottom_left, bottom, bottom_right,
    input button, clk,
    input rx, output tx
);

// physical buttons
wire one_shot_clock;
wire reset = ~button;

// bus wire and register to drive the bus
wire [15:0] w_bus;

// output debugging registers
wire [15:0] GPR_reg_out_1;
wire [15:0] GPR_reg_out_7;
wire [15:0] IR_reg_out;
wire [15:0] Y_reg_out;
wire [15:0] ALU_reg_out;
wire [1:0] PSW_reg_out;
// MAR_to_RAM is debug register for MAR
wire [15:0] MDR_reg_out;
wire [15:0] RAM_reg_out;

// wires connecting IR to other components
wire [3:0] opcode;
wire [2:0] rd_1;
wire [2:0] rd_2;
wire S;
wire [1:0] shift;
wire [2:0] rs_1;
wire [2:0] rs_2;

// wires connecting MAR/MDR to RAM
wire [15:0] MAR_to_RAM;
wire [15:0] MDR_to_RAM;
wire [15:0] RAM_to_MDR;

// wire connecting Y/shifter to ALU
wire [15:0] Y_to_ALU;

// comparator output bits routed to PSW
wire CC_N;
wire CC_Z;

// control signal index;
wire [2:0] ALU_control;
wire GPR_in;
wire GPR_out;
wire [2:0] GPR_select;
wire IR_in;
wire IR_offset_out;
wire MAR_in;
wire MDR_in;
wire MDR_out;
wire RAM_enable_read;
wire RAM_enable_write;
wire uart_done;
wire uart_in_and_send;
wire uart_out;
wire uart_receive;
wire Y_in;
wire Y_out;
wire Y_offset_in;
wire Y_shift_left;
wire Y_shift_right;
wire Z_in;
wire Z_out;

control_unit control_unit_inst0 (
    .clk(one_shot_clock),
    .reset(reset),
    .PSW_bits(PSW_reg_out),
    .instruction(IR_reg_out),
    .uart_done(uart_done),
    .ALU_control(ALU_control),
    .GPR_in(GPR_in),
    .GPR_out(GPR_out),
    .GPR_select(GPR_select),
    .IR_in(IR_in),
    .IR_offset_out(IR_offset_out),
    .MAR_in(MAR_in),
    .MDR_in(MDR_in),
    .MDR_out(MDR_out),
    .RAM_enable_read(RAM_enable_read),
    .RAM_enable_write(RAM_enable_write),
    .uart_in_and_send(uart_in_and_send),
    .uart_out(uart_out),
    .uart_receive(uart_receive),
    .Y_in(Y_in),
    .Y_out(Y_out),
    .Y_offset_in(Y_offset_in),
    .Y_shift_left(Y_shift_left),
    .Y_shift_right(Y_shift_right),
    .Z_in(Z_in),
    .Z_out(Z_out)
);

// Two inputs, one directly from bus and one from y register (after shifting)
// outputs to Z register, functionality controlled by 3-bit ALU_control
alu alu_inst0 (
    .bus(w_bus),
    .y_shifted(Y_to_ALU),
    .ALU_out(ALU_reg_out),
    .ALU_control(ALU_control)
);

// generates 2 status bits based on output from ALU
comparator comparator_inst0 (
    .from_ALU(ALU_reg_out),
    .CC_Z(CC_Z),
    .CC_N(CC_N)
);

// Eight 16-bit general purpose registers
GPR GPR_inst0 (
    .clk(one_shot_clock), 
    .reset(reset),
    .DATA(w_bus), 
    .REG_OUT_1(GPR_reg_out_1),  
    .REG_OUT_7(GPR_reg_out_7), 
    .GPR_in(GPR_in),
    .GPR_out(GPR_out),
    .GPR_select(GPR_select),
    .Rd_1(rd_1),
    .Rd_2(rd_2),
    .Rs_1(rs_1),
    .Rs_2(rs_2)
);

// instruction register, controlled input to bus, unbounded output to GPR, etc.
IR IR_inst0 (
    .clk(one_shot_clock), 
    .reset(reset),
    .DATA(w_bus), 
    .REG_OUT_IR(IR_reg_out),
    .opcode_out(opcode),
    .rd_out_1(rd_1),
    .rd_out_2(rd_2),
    .S(S),
    .shift(shift),
    .rs_1(rs_1),
    .rs_2(rs_2),
    .IR_in(IR_in),
    .IR_offset_out(IR_offset_out)
);

// memory address register
MAR MAR_inst0 (
    .clk(one_shot_clock),
    .reset(reset), 
    .DATA(w_bus), 
    .REG_OUT_MAR(MAR_to_RAM),
    .MAR_in(MAR_in),
    .r_en(RAM_enable_read),
    .w_en(RAM_enable_write)
);

// memory data register, has dual in/out ports (one to bus, one to RAM)
MDR MDR_inst0 (
    .clk(one_shot_clock), 
    .reset(reset), 
    .from_bus(w_bus),
    .MDR_bus_connect(w_bus),
    .REG_OUT_MDR(MDR_reg_out),
    .read_data(RAM_to_MDR),
    .write_data(MDR_to_RAM),
    .MDR_in(MDR_in),
    .MDR_out(MDR_out),
    .write_to_MM(RAM_enable_write),
    .read_from_MM(RAM_enable_read)
);

// contains condition codes and privileged bit
PSW PSW_inst0 (
    .clk(one_shot_clock),
    .reset(reset),
    .REG_OUT_PSW(PSW_reg_out), 
    .Z_in(Z_in),
    .IR_opcode(opcode),
    .IR_S(S),
    .ALU_control(ALU_control),
    .CC_Z_in(CC_Z),
    .CC_N_in(CC_N)
);

// old ram design that wasn't properly synthesized by yosys
// 256 possible addresses, each address holds a 16-bit word
// 8-bit address, 16-bit data, can read or write through single inout port

// new ram design improved off the old one
// 4096 possible addresses, each address holds a 16-bit word
// 12-bit address, 16-bit data, can read or write but not both
ram #(   
    .INIT_FILE("ram_init.txt")
) ram_inst0 (
    .clk(one_shot_clock),
    .w_en(RAM_enable_write),
    .r_en(RAM_enable_read),
    .addr(MAR_to_RAM[11:0]),
    .w_data(MDR_to_RAM),
    .r_data(RAM_to_MDR)
);

// shifts value between Y and ALU
shifter shifter_inst0 (
    .from_Y(Y_reg_out),
    .Y_shifted(Y_to_ALU),
    .Y_shift_left(Y_shift_left),
    .Y_shift_right(Y_shift_right),
    .shift_amount(shift)
);

// uart communication module, contains register that can either 
// send (tx) or receive (rx), not both at the same time
uart uart_inst0 (
    .clk(clk),
	.reset(reset),
    .uart_in_and_send(uart_in_and_send),
	.uart_out(uart_out),
    .uart_receive(uart_receive),
    .rx(rx),
    .tx(tx),
    .uart_done(uart_done),
    .DATA(w_bus)
);

// input register for ALU (other input is bus)
Y Y_inst0 (
    .clk(one_shot_clock),
    .reset(reset), 
    .DATA(w_bus), 
    .REG_OUT_Y(Y_reg_out),
    .Y_in(Y_in),
    .Y_out(Y_out),
    .Y_offset_in(Y_offset_in)
);

// output register for ALU in primary/replica config such that
// Z_in and Z_out can happen simultaneously
Z Z_inst0 (
    .clk(one_shot_clock),
    .reset(reset),
    .from_ALU(ALU_reg_out),
    .out_to_bus(w_bus),
    .Z_in(Z_in),
    .Z_out(Z_out)
);

assign one_shot_clock = clk; // use this OR clock divider, not both
// clock divider
/*
clock_pulser clock_pulser_inst0 (
    .clk(clk),
    .reset(reset),
    .clock_divided(one_shot_clock)
);
*/

// outputs the lowest 4-order bits of PC to LEDs on FPGA
leds_out leds_out_inst0(
    .in(GPR_reg_out_7),
    .clock_divided(one_shot_clock),
    .leds(led)
);

// outputs the lowest 7-order bits of GPR[1] (display-out register) to 7seg display
assign top_left = GPR_reg_out_1[6];
assign top = GPR_reg_out_1[5];
assign top_right = GPR_reg_out_1[4];
assign middle = GPR_reg_out_1[3];
assign bottom_left = GPR_reg_out_1[2];
assign bottom = GPR_reg_out_1[1];
assign bottom_right = GPR_reg_out_1[0];


endmodule