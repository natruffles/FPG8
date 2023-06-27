module MDR (
    input clk, 
    input reset, 
    input [15:0] from_bus,
    inout [15:0] MDR_bus_connect,
    output [15:0] REG_OUT_MDR,
    input [15:0] read_data,
    output [15:0] write_data,
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
    .read_data(),
    .write_data(),
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
        r <= read_data;
    end
end

// FIXME: MDR_out must be commanded clock cycle after read_from_MM
// MDR drives bus wire if MDR is commanded out
assign MDR_bus_connect = (MDR_out)? read_data : 16'bZZZZZZZZZZZZZZZZ;

// MDR drives RAM wire, but RAM wire can also be driven directly from bus in certain instances
//assign MDR_RAM_connect = (write_to_MM & ~MDR_in)? r : 
//                         (write_to_MM & MDR_in)? from_bus :
//                         16'bZZZZZZZZZZZZZZZZ;
                         
assign write_data = (~write_to_MM) ? 16'b0000000000000000 : 
                    (~MDR_in)? r :
                    from_bus;

assign REG_OUT_MDR = r;

endmodule