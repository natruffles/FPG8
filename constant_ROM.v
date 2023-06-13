module constant_ROM (
    output [15:0] DATA,  // output to bus line
    input reset_to_constant_val,
    input enable  // allows data output onto bus
);

// instantiation template 
/*
constant_ROM constant_ROM_inst0 (
    .DATA(),
    .reset_to_constant_val()
    .enable()
);
*/

reg [15:0] r;

always @(posedge reset_to_constant_val) begin
    r <= 16'b0000000000001000;
end

// if enable, r is driven to data port, else no connection (high impedance)
assign DATA = (enable)? r : 16'bZZZZZZZZZZZZZZZZ;

endmodule