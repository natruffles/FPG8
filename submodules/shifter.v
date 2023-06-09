module shifter (
    input [15:0] from_Y,
    output reg [15:0] Y_shifted,
    input Y_shift_left,
    input Y_shift_right,
    input [1:0] shift_amount
);

// instantiation template
/*
shifter shifter_inst0 (
    .from_Y(),
    .Y_shifted(),
    .Y_shift_left(),
    .Y_shift_right(),
    .shift_amount()
);
*/

always @( * ) begin
    if (shift_left) begin
        Y_shifted <= (from_Y <<< shift_amount);
    end else if (shift_right) begin
        Y_shifted <= (from_Y >>> shift_amount);
    end else begin
        Y_shifted <= from_Y
    end
end

endmodule