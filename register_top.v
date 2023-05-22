module register_top (
    output [4:0] led,
    input b1, b2, b3, b4, clk
);

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

wire [15:0] reg_out;

clock_pulser clock_pulser_inst0 (
    .clk(clk),
    .button(button),
    .one_clock_pulse(one_shot_clock)
);

register register_inst0 (
    .clk(one_shot_clock),
    .reset(reset),
    .DATA(w_bus),
    .REG_OUT(reg_out),  
    .latch(latch), 
    .enable(enable)  
);

register GPR (
    .clk(one_shot_clock),
    .reset(reset),
    .DATA(w_bus),
    .REG_OUT(GPR_reg_out),  
    .latch(GPR_latch), 
    .enable(GPR_enable)  
);

register MDR (
    .clk(one_shot_clock),
    .reset(reset),
    .DATA(w_bus),
    .REG_OUT(MDR_reg_out),  
    .latch(MDR_latch), 
    .enable(MDR_enable)  
);

register IR (
    .clk(one_shot_clock),
    .reset(reset),
    .DATA(w_bus),
    .REG_OUT(IR_reg_out),  
    .latch(IR_latch), 
    .enable(IR_enable)  
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

// w_drive_r drives the bus if latched, otherwise is high impedancex
assign w_bus = (latch) ? w_drive_r : 16'bZZZZZZZZZZZZZZZZ;

endmodule