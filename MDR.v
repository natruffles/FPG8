module MDR (
    input clk, 
    input reset, 
    input [15:0] from_bus,
    inout [15:0] MDR_bus_connect,
    output [15:0] REG_OUT_MDR,
    inout [15:0] MDR_RAM_connect,
    input MDR_in,
    input MDR_out,
    input write_to_MM,
    input read_from_MM
);

// instantiation template
/*
MDR MDR_inst0 (
    .clk(), 
    .reset(), 
    .from_bus(),
    .MDR_bus_connect(),
    .REG_OUT_MDR(),
    .MDR_RAM_connect(),
    .MDR_in(),
    .MDR_out(),
    .write_to_MM(),
    .read_from_MM()
);
*/

reg [15:0] r;

// register is either set by latch or reset by reset
always @(posedge clk) begin
    if (reset) begin
        r <= 0;
    end else if (MDR_in) begin
        r <= MDR_bus_connect;
    end else if (read_from_MM) begin
        r <= MDR_RAM_connect;
    end
end

// MDR drives bus wire if MDR is commanded out
assign MDR_bus_connect = (MDR_out)? r : 16'bZZZZZZZZZZZZZZZZ;

// MDR drives RAM wire, but RAM wire can also be driven directly from bus in certain instances
assign MDR_RAM_connect = (write_to_MM & ~MDR_in)? r : 
                         (write_to_MM & MDR_in)? from_bus :
                         16'bZZZZZZZZZZZZZZZZ;

assign REG_OUT_MDR = (write_to_MM & MDR_in) ? from_bus : r;

endmodule