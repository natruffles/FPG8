module fpg8 (
    output [4:0] led,
    input top_button, top_middle_button, bottom_middle_button, bottom_button, clk
);

// physical buttons
wire one_shot_clock;
wire reset = ~top_button;
wire clock_button = ~bottom_button;

// bus wire and register to drive the bus
wire [15:0] w_bus;

// output debugging registers
wire [15:0] GPR_reg_out_0;
wire [15:0] GPR_reg_out_1;
wire [15:0] GPR_reg_out_2;
wire [15:0] GPR_reg_out_3;
wire [15:0] GPR_reg_out_4;
wire [15:0] GPR_reg_out_5;
wire [15:0] GPR_reg_out_6;
wire [15:0] GPR_reg_out_7;
wire [15:0] IR_reg_out;
wire [15:0] Y_reg_out;
wire [15:0] ALU_reg_out;
wire [15:0] Z1_reg_out;
wire [15:0] Z2_reg_out;
wire [15:0] timer_reg_out;
wire [15:0] PSW_reg_out;
wire [4:0] control_unit_reg_out;
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
wire timeout;
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
    .opcode(opcode),
    .PSW_bits(PSW_reg_out[2:0]),
    .IR_Rs2(rs_2),
    .timeout(timeout),
    .instruction(IR_reg_out),
    .REG_OUT_CONTROL_UNIT(control_unit_reg_out),
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

// outputs value of "8" to the bus when enabled
constant_ROM constant_ROM_inst0 (
    .DATA(w_bus),
    .reset_to_constant_val(reset),
    .enable(con_ROM_out)
);

// Eight 16-bit general purpose registers
GPR GPR_inst0 (
    .clk(one_shot_clock), 
    .reset(reset),
    .DATA(w_bus), 
    .REG_OUT_0(GPR_reg_out_0),  
    .REG_OUT_1(GPR_reg_out_1), 
    .REG_OUT_2(GPR_reg_out_2), 
    .REG_OUT_3(GPR_reg_out_3), 
    .REG_OUT_4(GPR_reg_out_4), 
    .REG_OUT_5(GPR_reg_out_5), 
    .REG_OUT_6(GPR_reg_out_6), 
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
    .IR_in(IR_in)
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

PSW PSW_inst0 (
    .clk(one_shot_clock),
    .reset(reset),
    .DATA(w_bus),  
    .REG_OUT_PSW(PSW_reg_out), 
    .latch(PSW_in), 
    .enable(PSW_out), 
    .IR_opcode(opcode),
    .IR_S(S),
    .Z_in(Z_in),
    .ALU_control(ALU_control),
    .CC_Z_in(CC_Z),
    .CC_N_in(CC_N)
);

// old ram design that wasn't properly synthesized by yosys
// 256 possible addresses, each address holds a 16-bit word
// 8-bit address, 16-bit data, can read or write through single inout port
/*
ram #(   
    .MEM_WIDTH(16), 
    .MEM_DEPTH(256), 
    .INIT_FILE("ram_mem_init.txt")
) ram_inst0 (
    .clk(one_shot_clock),
    .w_en(RAM_enable_write),
    .r_en(RAM_enable_read),
    .addr(MAR_to_RAM[7:0]),
    .MDR_RAM_connect(MDR_RAM_connect),
    .write_data(MDR_RAM_connect),
    .RAM_REG_OUT(RAM_reg_out)
);
*/

// new ram design improved off the old one
ram #(   
    .MEM_WIDTH(16), 
    .MEM_DEPTH(4096), 
    .INIT_FILE("ram_mem_init.txt")
) ram_inst0 (
    .clk(one_shot_clock),
    .w_en(RAM_enable_write),
    .r_en(RAM_enable_read),
    .w_addr(MAR_to_RAM[11:0]),
    .r_addr(MAR_to_RAM[11:0]),
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

// generates timeout signal when timer counts down to 0
// timeout signal will remain high until timer value is reset, input with nonzero value
timer timer_inst0 (
    .clk(one_shot_clock),
    .reset(reset), 
    .DATA(w_bus), 
    .REG_OUT_TIMER(timer_reg_out), 
    .timer_in(timer_in),
    .timeout(timeout)
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
    .REG_OUT_Z1(Z1_reg_out), 
    .REG_OUT_Z2(Z2_reg_out),
    .out_to_bus(w_bus),
    .Z_in(Z_in),
    .Z_out(Z_out)
);

// handles generating a clock pulse every time button is pressed
clock_pulser clock_pulser_inst0 (
    .clk(clk),
    .button(clock_button),
    .one_clock_pulse(one_shot_clock)
);

// outputs the lowest 5-order bits to LEDs on FPGA
leds_out leds_out_inst0(
    .in(GPR_reg_out_7),
    .leds(led)
);

endmodule