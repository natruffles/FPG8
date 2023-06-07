module fpg8 (
    output [4:0] led,
    input b1, b2, b3, b4, clk
);

// physical buttons
wire one_shot_clock;
wire reset = ~b1;
wire latch = ~b2;
wire enable = ~b3;
wire button = ~b4;

// bus wire and register to drive the bus
wire [15:0] w_bus;
// w_drive_r does not have functionality of typical registers,
// control functionality handled in code
reg [15:0] w_drive_r;

// output debugging register for debug register lol
wire [15:0] reg_out;

// output debugging registers for GPR
wire [15:0] GPR_reg_out_0;
wire [15:0] GPR_reg_out_1;
wire [15:0] GPR_reg_out_2;
wire [15:0] GPR_reg_out_3;
wire [15:0] GPR_reg_out_4;
wire [15:0] GPR_reg_out_5;
wire [15:0] GPR_reg_out_6;
wire [15:0] GPR_reg_out_7;

// output debugging register for IR
wire [15:0] IR_reg_out;

// wires connecting IR to other components
wire [3:0] opcode;
wire [2:0] rd_1;
wire [2:0] rd_2;
wire S;
wire [1:0] shift;
wire [2:0] rs_1;
wire [2:0] rs_2;

// control signal index;
wire [2:0] ALU_control;
wire GPR_in;
wire GPR_out;
wire [2:0] GPR_select;
wire IR_in;
wire RAM_enable_read;
wire RAM_enable_write;

// handles using button to pulse clock
clock_pulser clock_pulser_inst0 (
    .clk(clk),
    .button(button),
    .one_clock_pulse(one_shot_clock)
);

// debugging register attached to bus
register register_inst0 (
    .clk(one_shot_clock),
    .reset(reset),
    .DATA(w_bus),
    .REG_OUT(reg_out),  
    .latch(latch), 
    .enable(enable)  
);

// Two inputs, one directly from bus and one from y register (after shifting)
// outputs to Z register, functionality controlled by 3-bit ALU_control
alu ALU(
    .bus(w_bus),
    .y_shifted(...),
    .ALU_out(...),
    .ALU_control(ALU_control)
);

// Eight 16-bit general purpose registers
GPR GPR (
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
    .Rd_1(...),
    .Rd_2(...),
    .Rs_1(...),
    .Rs_2(...)
);


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

// 256 possible addresses, each address holds a 16-bit word
// 8-bit address, 16-bit data, reading and writing on same clock
// cycle supported but not recommended
ram #(   
    .MEM_WIDTH(16), 
    .MEM_DEPTH(256), 
    .INIT_FILE("mem_init.txt")
) RAM (
    .clk(one_shot_clock),
    .w_en(RAM_enable_write),
    .r_en(RAM_enable_read),
    .w_addr(...),
    .r_addr(...),
    .w_data(...),
    .r_data(...)
);

/*
register MDR (
    .clk(one_shot_clock),
    .reset(reset),
    .DATA(w_bus),
    .REG_OUT(MDR_reg_out),  
    .latch(MDR_latch), 
    .enable(MDR_enable)  
);

register timer (
    .clk(one_shot_clock),
    .reset(reset),
    .DATA(w_bus),
    .REG_OUT(timer_reg_out),  
    .latch(timer_latch), 
    .enable(timer_enable)  
);

register conrom (
    .clk(one_shot_clock),
    .reset(reset),
    .DATA(w_bus),
    .REG_OUT(conrom_reg_out),  
    .latch(conrom_latch), 
    .enable(conrom_enable)  
);

register MAR (
    .clk(one_shot_clock),
    .reset(reset),
    .DATA(w_bus),
    .REG_OUT(MAR_reg_out),  
    .latch(MAR_latch), 
    .enable(MAR_enable)  
);

register Y (
    .clk(one_shot_clock),
    .reset(reset),
    .DATA(w_bus),
    .REG_OUT(Y_reg_out),  
    .latch(Y_latch), 
    .enable(Y_enable)  
);

register Z (
    .clk(one_shot_clock),
    .reset(reset),
    .DATA(w_bus),
    .REG_OUT(Z_reg_out),  
    .latch(Z_latch), 
    .enable(Z_enable)  
);

register PSW (
    .clk(one_shot_clock),
    .reset(reset),
    .DATA(w_bus),
    .REG_OUT(PSW_reg_out),  
    .latch(PSW_latch), 
    .enable(PSW_enable)  
);
*/


leds_out leds_out_inst0(
    .in(reg_out),
    .leds(led)
);

// logic to handle contents of w_drive_r
always @(posedge one_shot_clock) begin
    if (reset) begin
        w_drive_r <= 16'b0101010100000000;
    end else if (latch) begin
        w_drive_r <= w_drive_r + 1;
    end
end

// w_drive_r drives the bus if latched, otherwise is high impedance
assign w_bus = (latch) ? w_drive_r : 16'bZZZZZZZZZZZZZZZZ;

endmodule