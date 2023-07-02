// inspired by shawn hymel's video on a metastable clock:
// https://www.youtube.com/watch?v=dXU1py-Od1g&pp=ygUZc2hhd24gaHltZWwgbWV0YXN0YWJpbGl0eQ%3D%3D
module clock_pulser #(
    parameter MODULO = 300000
) (
    input clk,
    input reset,
    output reg clock_divided
);

// Calculate number of bits needed for the counter
localparam WIDTH = (MODULO == 1) ? 1 : $clog2(MODULO);

// Internal storage elements
reg [WIDTH-1:0] count = 0;

// acts as a pulse on every positive and negative edge of clock signal (2 pulses per clock cycle)
wire edge_trigger;
assign edge_trigger = (count == MODULO - 1) ? 1'b1 : 1'b0;

// Counter resets on edge trigger
always @ (posedge clk) begin
    if (edge_trigger == 1'b1) begin
        count <= 0;
    end else begin
        count <= count + 1;
    end
end

// edge trigger pulse switches clock from 1 to 0 and vice versa
always @ (posedge edge_trigger) begin
    if (reset) clock_divided <= 0;
    clock_divided <= ~clock_divided;
end
    
endmodule