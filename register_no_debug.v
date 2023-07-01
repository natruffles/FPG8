module register_no_debug (
    input clk,
    input reset,
    inout [15:0] DATA,  // in and out from bus line
    input latch, // allows data input into register
    input enable  // allows data output onto bus
);

// instantiation template 
/*
register register_inst0 (
    .clk(),
    .reset(),
    .DATA(), 
    .latch(), 
    .enable()  
);
*/

reg [15:0] r;

// register is either set by latch or reset by reset
always @(posedge clk) begin
    if (reset) begin
        r <= 0;
    end else begin
        if (latch) begin
            r <= DATA;
        end
    end
end

// if enable, r is driven to data port, else no connection (high impedance)
assign DATA = (enable)? r : 16'bZZZZZZZZZZZZZZZZ;

endmodule