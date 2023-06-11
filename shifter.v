// need input and output to be signed for arithmetic right bit shift to work

module shifter (
    input signed [15:0] from_Y,
    output reg signed [15:0] Y_shifted,
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
    if (Y_shift_left) begin
        Y_shifted <= (from_Y <<< shift_amount);
    end else if (Y_shift_right) begin
        Y_shifted <= (from_Y >>> shift_amount);
    end else begin
        Y_shifted <= from_Y;
    end
end

endmodule