// from Phil Does Tech's video tutorial

module debounce (
    input clk,
    input sw_in,
    output sw_debounced
);

// instantiation template
/*
debounce_inst0 (
.clk(),
.sw_in(),
.sw_debounced()
);
*/

// 500k clock ticks is 1/24 seconds on 12MHz clock
parameter DEBOUNCE_TIME = 500000;

// number of bits necessary to store 500000
reg [23:0] debounce_counter;
reg state;

// wait until a button has been in the same state for DEBOUNCE_TIME
// number of clock pulses before actually changing state 
always @(posedge clk) begin
    if (sw_in !== state && debounce_counter < DEBOUNCE_TIME) begin
        debounce_counter <= debounce_counter + 1;
    end else if (debounce_counter == DEBOUNCE_TIME) begin
        state <= sw_in;
        debounce_counter <= 0;
    end else begin
        debounce_counter <= 0;
    end
end

assign sw_debounced = state;

endmodule

