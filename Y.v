module Y (
    input clk, // data read/written on positive clock edges
    input reset, // reset all registers to a certain value
    inout [15:0] DATA,  // in and out from bus line
    output [15:0] REG_OUT_Y,  // for debugging, to RAM
    input Y_in,
    input Y_out,
    input Y_offset_in
);

// instantiation template 
/*
Y Y_inst0 (
    .clk(),
    .reset(), 
    .DATA(), 
    .REG_OUT_Y(),
    .Y_in(),
    .Y_out(),
    .Y_offset_in()
);
*/

reg [15:0] r;

// input from bus, or from bus but offset bits sign extended
always @(posedge clk) begin
    if (reset) begin
        r <= 0;
    end else if (Y_in) begin
        r <= DATA;
    end else if (Y_offset_in) begin
        r[8:0] <= DATA[8:0];
        r[15:9] <= {7{DATA[8]}};
    end
end

// if Y_out, r is driven to data port, else no connection (high impedance)
assign DATA = (Y_out)? r : 16'bZZZZZZZZZZZZZZZZ;
assign REG_OUT_Y = r;

endmodule