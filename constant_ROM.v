module constant_ROM (
    output [15:0] DATA,  // output to bus line
    input enable  // allows data output onto bus
);

// instantiation template 
/*
constant_ROM constant_ROM_inst0 (
    .DATA(),
    .enable()
);
*/

reg [15:0] r;

// initialize memory from file if available
initial begin
    $readmemb("constant_ROM_init.txt", r);
end

// if enable, r is driven to data port, else no connection (high impedance)
assign DATA = (enable)? r : 16'bZZZZZZZZZZZZZZZZ;

endmodule