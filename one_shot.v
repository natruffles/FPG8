// from Phil Does Tech's video tutorial
// generates a single clock pulse when button is depressed

module one_shot (
    input clk,
    input button,
    output reg pulse
);

// instantiation template
/*
one_shot one_shot_inst0 (
    .clk(),
    .button(),
    .pulse()
);
*/

reg q;

always @(posedge button or posedge pulse) begin
    if (pulse) begin
        q <= 0;
    end else begin
        q <= 1;
    end
end

always @(posedge clk) begin
    pulse <= q;
end

endmodule