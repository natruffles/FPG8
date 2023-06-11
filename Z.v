// consists of 2 registers in a primary/replica configuration

module Z (
    input clk,
    input reset,
    input [15:0] from_ALU,
    output [15:0] REG_OUT_Z1,  // for debugging
    output [15:0] REG_OUT_Z2,  // for debugging
    output [15:0] out_to_bus,
    input Z_in,
    input Z_out
);

// instantiation template 
/*
Z Z_inst0 (
    .clk(),
    .reset(),
    .from_ALU(),
    .REG_OUT_Z1(), 
    .REG_OUT_Z2(),
    .out_to_bus(),
    .Z_in(),
    .Z_out()
);
*/

reg [15:0] Z1;
reg [15:0] Z2;

// register is either set by latch or reset by reset
always @(posedge clk) begin
    if (reset) begin
        Z1 <= 0;
        Z2 <= 0;
    end else if (Z_in) begin
        Z1 <= from_ALU;
    end
    Z2 <= Z1;
end

// Z2 drives bus wire if Z_out is high
assign out_to_bus = (Z_out)? Z2 : 16'bZZZZZZZZZZZZZZZZ;

assign REG_OUT_Z1 = Z1;
assign REG_OUT_Z2 = Z2;

endmodule