// low-order 5 bits of 16-bit word are displayed on LEDs

module leds_out(in, leds);

// instantiation template
/*
leds_out leds_out_inst0(
    .in(),
    .leds()
);
*/

input [15:0] in;
output reg [4:0] leds;

always @(*) begin
    leds = in[4:0];
end

endmodule