module timer (
    input clk,
    input reset, 
    input [15:0] DATA, 
    output [15:0] REG_OUT_TIMER, 
    input timer_in,
    output timeout
);

// instantiation template 
/*
timer timer_inst0 (
    .clk(),
    .reset(), 
    .DATA(), 
    .REG_OUT_TIMER(), 
    .timer_in(),
    .timeout()
);
*/

reg [15:0] r;

// register is either reset, input with DATA, or decremented by one on positive clock edge
always @(posedge clk) begin
    if (reset) begin
        r <= 16'b1111111111111111;
    end else begin
        if (timer_in) begin
            r <= DATA;
        end else if (r > 0) begin
            r <= r - 1;
        end
    end
end

// timout signal remains high until r is reset to a nonzero value
assign timeout = (r == 0)? 1 : 0;
assign REG_OUT_TIMER = r;

endmodule