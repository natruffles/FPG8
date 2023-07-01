// low-order 5 bits of 16-bit word are displayed on LEDs

module leds_out(
    input [15:0] in, 
    input clock_divided,
    output [4:0] leds

);

// instantiation template
/*
leds_out leds_out_inst0(
    .in(),
    .clock_divided(),
    .leds()
);
*/

assign leds[3:0] = in[3:0];
assign leds[4] = clock_divided;

endmodule