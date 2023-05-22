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